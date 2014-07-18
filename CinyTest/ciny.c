//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <setjmp.h>
#include <complex.h>
#include <stdbool.h>
#include <float.h>
#include <math.h>
#include "ciny.h"

/////
// Type and Data Definitions
/////

#define DATE_FORMAT_SIZE 30
static const char * const DateFormatString = "%F %T";
static const char * const InvalidDateFormat = "Invalid Date (formatted output may have exceeded buffer size)";

#define COMPVALUE_STR_SIZE 75
enum assert_type {
    ASSERT_UNKNOWN,
    ASSERT_FAILURE,
    ASSERT_IGNORE
};
struct assertstate {
    enum assert_type type;
    const char *file;
    int line;
    char description[200 + (COMPVALUE_STR_SIZE * 2)];
    char message[1000];
};
static struct assertstate CurrentAssertState;
static jmp_buf AssertFired;
static const char IgnoredTestGlyph = '?';

struct runledger {
    size_t passed;
    size_t failed;
    size_t ignored;
};

/////
// Inline Function Call Sites
/////

extern inline struct ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_full(const char *, struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);
extern inline struct ct_comparable_value ct_makevalue_integral(int, long long);
extern inline struct ct_comparable_value ct_makevalue_uintegral(int, unsigned long long);
extern inline struct ct_comparable_value ct_makevalue_floating(int, long double);
extern inline struct ct_comparable_value ct_makevalue_complex(int, long double _Complex);
extern inline struct ct_comparable_value ct_makevalue_invalid(int, ...);

/////
// Printing and Text Manipulation
/////

static void print_delimiter(const char *message)
{
    printf("====-- CinyTest %s --====\n", message);
}

static void print_runheader(const struct ct_testsuite *suite, time_t start_time)
{
    print_delimiter("Run");
    
    char formatted_datetime[DATE_FORMAT_SIZE];
    size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, DateFormatString, localtime(&start_time));
    printf("Starting test suite '%s' at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    printf("Running %zu tests:\n", suite->count);
}

static void print_runfooter(const struct ct_testsuite *suite, time_t start_time, time_t end_time, const struct runledger *ledger)
{
    char formatted_datetime[DATE_FORMAT_SIZE];
    size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, DateFormatString, localtime(&end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    double elapsed_time = difftime(start_time, end_time);
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite->count, elapsed_time, ledger->passed, ledger->failed, ledger->ignored);
    
    print_delimiter("End");
}

static void print_linemessage(const char *message)
{
    if (printf("%s", message) > 0) {
        printf("\n");
    }
}

static bool pretty_truncate(char *str, size_t size)
{
    static const char * const ellipsis = "\u2026";
    size_t ellipsis_length = strlen(ellipsis);
    ptrdiff_t truncation_index = size - 1 - ellipsis_length;
    
    bool can_fit_ellipsis = truncation_index >= 0;
    if (can_fit_ellipsis) {
        str[truncation_index] = '\0';
        strcat(str, ellipsis);
    }
    
    return can_fit_ellipsis;
}

/////
// Assert State
/////

static void assertstate_reset(struct assertstate *assert_state)
{
    assert_state->type = ASSERT_UNKNOWN;
    assert_state->file = NULL;
    assert_state->line = 0;
    assert_state->description[0] = '\0';
    assert_state->message[0] = '\0';
}

static void assertstate_handlefailure(const struct assertstate *assert_state, const char *testname, struct runledger *ledger)
{
    ++ledger->failed;
    printf("[\u2718] - '%s' failure\n", testname);
    printf("%s L.%d : %s\n", assert_state->file, assert_state->line, assert_state->description);
    print_linemessage(assert_state->message);
}

static void assertstate_handleignore(const struct assertstate *assert_state, const char *testname, struct runledger *ledger)
{
    ++ledger->ignored;
    printf("[%c] - '%s' ignored\n", IgnoredTestGlyph, testname);
    print_linemessage(assert_state->message);
}

static void assertstate_handle(const struct assertstate *assert_state, const char *testname, struct runledger *ledger)
{
    switch (assert_state->type) {
        case ASSERT_FAILURE:
            assertstate_handlefailure(assert_state, testname, ledger);
            break;
        case ASSERT_IGNORE:
            assertstate_handleignore(assert_state, testname, ledger);
            break;
        default:
            fprintf(stderr, "WARNING: unknown assertion type encountered!\n");
            break;
    }
}

static void assertstate_setdescription(struct assertstate *assert_state, const char *format, ...)
{
    size_t description_size = sizeof assert_state->description;
    va_list format_args;
    va_start(format_args, format);
    int write_count = vsnprintf(assert_state->description, description_size, format, format_args);
    va_end(format_args);
    
    if (write_count >= description_size) {
        pretty_truncate(assert_state->description, description_size);
    }
}

#define assertstate_setmessage(assert_state, format) \
            do { \
                va_list format_args; \
                va_start(format_args, format); \
                assertstate_setvmessage(&assert_state, format, format_args); \
                va_end(format_args); \
            } while (false)
static void assertstate_setvmessage(struct assertstate *assert_state, const char *format, va_list format_args)
{
    size_t message_size = sizeof assert_state->message;
    int write_count = vsnprintf(assert_state->message, message_size, format, format_args);
    
    if (write_count >= message_size) {
        pretty_truncate(assert_state->message, message_size);
    }
}

#define assertstate_raise_signal(assert_state, assert_type, signal, test_file, test_line, format) \
            do { \
                assert_state.type = assert_type; \
                assert_state.file = test_file; \
                assert_state.line = test_line; \
                assertstate_setmessage(assert_state, format); \
                longjmp(signal, assert_state.type); \
            } while(false)

/////
// Comparable Value
/////

static bool comparable_value_equaltypes(const struct ct_comparable_value *expected, const struct ct_comparable_value *actual)
{
    return expected->type == actual->type;
}

static const char *comparable_value_typedescription(const struct ct_comparable_value *value)
{
    switch (value->type) {
        case CT_ANNOTATE_INTEGRAL:
            return "integral";
        case CT_ANNOTATE_UNSIGNEDINTEGRAL:
            return "unsigned integral";
        case CT_ANNOTATE_FLOATINGPOINT:
            return "floating point";
        case CT_ANNOTATE_COMPLEX:
            return "complex";
        default:
            return "invalid value type";
    }
}

static bool comparable_value_equalvalues(const struct ct_comparable_value *expected, const struct ct_comparable_value *actual, enum ct_valuetype_annotation type)
{
    switch (type) {
        case CT_ANNOTATE_INTEGRAL:
            return expected->integral_value == actual->integral_value;
        case CT_ANNOTATE_UNSIGNEDINTEGRAL:
            return expected->uintegral_value == actual->uintegral_value;
        case CT_ANNOTATE_FLOATINGPOINT:
            return expected->floating_value == actual->floating_value;
        case CT_ANNOTATE_COMPLEX:
            return creall(expected->complex_value) == creall(actual->complex_value) && cimagl(expected->complex_value) == cimagl(actual->complex_value);
        default:
            return false;
    }
}

static void comparable_value_valuedescription(const struct ct_comparable_value *value, char *buffer, size_t size)
{
    int write_count = 0;
    
    switch (value->type) {
        case CT_ANNOTATE_INTEGRAL:
            write_count = snprintf(buffer, size, "%lld", value->integral_value);
            break;
        case CT_ANNOTATE_UNSIGNEDINTEGRAL:
            write_count = snprintf(buffer, size, "%llu", value->uintegral_value);
            break;
        case CT_ANNOTATE_FLOATINGPOINT:
            write_count = snprintf(buffer, size, "%.*Lg", DECIMAL_DIG, value->floating_value);
            break;
        case CT_ANNOTATE_COMPLEX: {
            long double imagin_value = cimagl(value->complex_value);
            char sign = '+';
            if (imagin_value < 0.0) {
                sign = '-';
                imagin_value = fabsl(imagin_value);
            }
            write_count = snprintf(buffer, size, "%.*Lg %c %.*Lgi", DECIMAL_DIG, creall(value->complex_value), sign, DECIMAL_DIG, imagin_value);
            break;
        }
        default:
            write_count = snprintf(buffer, size, "invalid value");
            break;
    }
    
    if (write_count >= size) {
        pretty_truncate(buffer, size);
    }
}

/////
// Test Suite and Test Case
/////

static void testcase_run(const struct ct_testcase *testcase, void *testcontext, size_t index, struct runledger *ledger)
{
    if (!testcase->test) {
        ++ledger->ignored;
        printf("[%c] - ignored test at index %zu (NULL function pointer found)\n", IgnoredTestGlyph, index);
        return;
    }
    
    testcase->test(testcontext);
    
    ++ledger->passed;
    printf("[\u2714] - '%s' success\n", testcase->name);
}

static void testsuite_run(const struct ct_testsuite *suite, size_t index, struct runledger *ledger)
{
    assertstate_reset(&CurrentAssertState);
    struct ct_testcase *current_test = &suite->tests[index];
    
    void *testcontext = NULL;
    if (suite->setup) {
        suite->setup(&testcontext);
    }
    
    if (setjmp(AssertFired)) {
        assertstate_handle(&CurrentAssertState, current_test->name, ledger);
    } else {
        testcase_run(current_test, testcontext, index, ledger);
    }
    
    if (suite->teardown) {
        suite->teardown(&testcontext);
    }
}

/////
// Public Functions
/////

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    time_t start_time = time(NULL);
    print_runheader(suite, start_time);
    
    struct runledger ledger = { 0, 0, 0 };
    for (size_t i = 0; i < suite->count; ++i) {
        testsuite_run(suite, i, &ledger);
    }
    
    time_t end_time = time(NULL);
    print_runfooter(suite, start_time, end_time, &ledger);
    
    return ledger.failed;
}

_Noreturn void ct_ignore_full(const char *format, ...)
{
    assertstate_raise_signal(CurrentAssertState, ASSERT_IGNORE, AssertFired, NULL, 0, format);
}

_Noreturn void ct_assertfail_full(const char *file, int line, const char *format, ...)
{
    assertstate_setdescription(&CurrentAssertState, "%s", "asserted unconditional failure");
    assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
}

void ct_asserttrue_full(bool expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (!expression) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is true failed", stringized_expression);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertfalse_full(bool expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (expression) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is false failed", stringized_expression);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnull_full(const void *expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (expression) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is NULL failed: (%p)", stringized_expression, expression);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnotnull_full(const void *expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (!expression) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is not NULL failed", stringized_expression);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertequal_full(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char *file, int line, const char *format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (!comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        char valuestr_actual[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        comparable_value_valuedescription(&actual, valuestr_actual, sizeof valuestr_actual);
        assertstate_setdescription(&CurrentAssertState, "(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnotequal_full(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char *file, int line, const char *format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        assertstate_setdescription(&CurrentAssertState, "(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertaboutequal_full(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char *file, int line, const char *format, ...)
{
    long double diff = fabsl(expected - actual);
    if (isgreater(diff, fabsl(precision)) || isnan(diff) || isnan(precision)) {
        assertstate_setdescription(&CurrentAssertState, "(%s) differs from (%s) by greater than \u00b1 (%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnotaboutequal_full(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char *file, int line, const char *format, ...)
{
    long double diff = fabsl(expected - actual);
    if (islessequal(diff, fabsl(precision))) {
        assertstate_setdescription(&CurrentAssertState, "(%s) differs from (%s) by less than or equal to \u00b1 (%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertsame_full(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char *file, int line, const char *format, ...)
{
    if (expected != actual) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is not the same as (%s): expected (%p), actual (%p)", stringized_expected, stringized_actual, expected, actual);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnotsame_full(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char *file, int line, const char *format, ...)
{
    if (expected == actual) {
        assertstate_setdescription(&CurrentAssertState, "(%s) is the same as (%s): (%p)", stringized_expected, stringized_actual, expected);
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertequalstrn_full(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char *file, int line, const char *format, ...)
{
    if ((expected && !actual) || (!expected && actual)
        || (expected && actual && (strncmp(expected, actual, n) != 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        char valuestr_actual[COMPVALUE_STR_SIZE];
        if (snprintf(valuestr_expected, COMPVALUE_STR_SIZE, "%s", expected) >= COMPVALUE_STR_SIZE) {
            pretty_truncate(valuestr_expected, COMPVALUE_STR_SIZE);
        }
        if (snprintf(valuestr_actual, COMPVALUE_STR_SIZE, "%s", actual) >= COMPVALUE_STR_SIZE) {
            pretty_truncate(valuestr_actual, COMPVALUE_STR_SIZE);
        }
        assertstate_setdescription(&CurrentAssertState, "(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}

void ct_assertnotequalstrn_full(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char *file, int line, const char *format, ...)
{
    if ((!expected && !actual) || (expected && actual && (strncmp(expected, actual, n) == 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        if (snprintf(valuestr_expected, COMPVALUE_STR_SIZE, "%s", expected) >= COMPVALUE_STR_SIZE) {
            pretty_truncate(valuestr_expected, COMPVALUE_STR_SIZE);
        }
        assertstate_setdescription(&CurrentAssertState, "(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        
        assertstate_raise_signal(CurrentAssertState, ASSERT_FAILURE, AssertFired, file, line, format);
    }
}
