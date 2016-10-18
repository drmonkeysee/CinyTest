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
#include <inttypes.h>
#include "ciny.h"

/////
// Platform-specific Definitions
/////

uint64_t get_currentmsecs(void);

/////
// Type and Data Definitions
/////

#define DATE_FORMAT_SIZE 30
#define green_text(s) "\033[0;32m" s "\033[0m"
#define red_text(s) "\033[0;31m" s "\033[0m"
#define cyan_text(s) "\033[0;36m" s "\033[0m"
static const char * const restrict DateFormatString = "%F %T";
static const char * const restrict InvalidDateFormat = "Invalid Date (formatted output may have exceeded buffer size)";
static const char IgnoredTestChar = '?';

#define COMPVALUE_STR_SIZE 75
enum assert_type {
    ASSERT_UNKNOWN,
    ASSERT_FAILURE,
    ASSERT_IGNORE
};
static struct {
    const char *file;
    int line;
    enum assert_type type;
    char description[200 + (COMPVALUE_STR_SIZE * 2)];
    char message[1002];
} AssertState;
static jmp_buf AssertSignal;

static const size_t InvalidSuite = 0;
struct runledger {
    size_t passed;
    size_t failed;
    size_t ignored;
};

/////
// Inline Function Call Sites
/////

extern inline struct ct_testcase ct_maketest_named(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_setup_teardown_named(const char * restrict, const struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);
extern inline struct ct_comparable_value ct_makevalue_integer(int, intmax_t);
extern inline struct ct_comparable_value ct_makevalue_uinteger(int, uintmax_t);
extern inline struct ct_comparable_value ct_makevalue_floatingpoint(int, long double);
extern inline struct ct_comparable_value ct_makevalue_complex(int, long double complex);
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

static void print_runfooter(const struct ct_testsuite *suite, time_t end_time, uint64_t elapsed_msecs, const struct runledger *ledger)
{
    static const double ms_per_sec = 1000.0;
    char formatted_datetime[DATE_FORMAT_SIZE];
    size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, DateFormatString, localtime(&end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    printf("Ran %zu tests (%.3f seconds): " green_text("%zu passed") ", " red_text("%zu failed") ", " cyan_text("%zu ignored") ".\n", suite->count, elapsed_msecs / ms_per_sec, ledger->passed, ledger->failed, ledger->ignored);
    
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
    static const char * const restrict ellipsis = "\u2026";
    const size_t ellipsis_length = strlen(ellipsis);
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

static void assertstate_reset(void)
{
    AssertState.type = ASSERT_UNKNOWN;
    AssertState.file = NULL;
    AssertState.line = 0;
    AssertState.description[0] = '\0';
    AssertState.message[0] = '\0';
}

static void assertstate_handlefailure(const char * restrict testname, struct runledger *ledger)
{
    ++ledger->failed;
    printf("[ " red_text("\u2717") " ] - '%s' failure\n", testname);
    printf("%s L.%d : %s\n", AssertState.file, AssertState.line, AssertState.description);
    print_linemessage(AssertState.message);
}

static void assertstate_handleignore(const char * restrict testname, struct runledger *ledger)
{
    ++ledger->ignored;
    printf("[ " cyan_text("%c") " ] - '%s' ignored\n", IgnoredTestChar, testname);
    print_linemessage(AssertState.message);
}

static void assertstate_handle(const char * restrict testname, struct runledger *ledger)
{
    switch (AssertState.type) {
        case ASSERT_FAILURE:
            assertstate_handlefailure(testname, ledger);
            break;
        case ASSERT_IGNORE:
            assertstate_handleignore(testname, ledger);
            break;
        default:
            fprintf(stderr, "WARNING: unknown assertion type encountered!\n");
            break;
    }
}

static void assertstate_setdescription(const char * restrict format, ...)
{
    const size_t description_size = sizeof AssertState.description;
    va_list format_args;
    va_start(format_args, format);
    int write_count = vsnprintf(AssertState.description, description_size, format, format_args);
    va_end(format_args);
    
    if ((size_t)write_count >= description_size) {
        pretty_truncate(AssertState.description, description_size);
    }
}

#define assertstate_setmessage(format) \
do { \
    va_list format_args; \
    va_start(format_args, format); \
    assertstate_setvmessage(format, format_args); \
    va_end(format_args); \
} while (false)
static void assertstate_setvmessage(const char *format, va_list format_args)
{
    const size_t message_size = sizeof AssertState.message;
    int write_count = vsnprintf(AssertState.message, message_size, format, format_args);
    
    if ((size_t)write_count >= message_size) {
        pretty_truncate(AssertState.message, message_size);
    }
}

#define assertstate_raise_signal(assert_type, test_file, test_line, format) \
do { \
    AssertState.type = assert_type; \
    AssertState.file = test_file; \
    AssertState.line = test_line; \
    assertstate_setmessage(format); \
    longjmp(AssertSignal, AssertState.type); \
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
        case CT_ANNOTATE_INTEGER:
            return "integer";
        case CT_ANNOTATE_UINTEGER:
            return "unsigned integer";
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
        case CT_ANNOTATE_INTEGER:
            return expected->integer_value == actual->integer_value;
        case CT_ANNOTATE_UINTEGER:
            return expected->uinteger_value == actual->uinteger_value;
        case CT_ANNOTATE_FLOATINGPOINT:
            return expected->floatingpoint_value == actual->floatingpoint_value;
        case CT_ANNOTATE_COMPLEX:
            return creall(expected->complex_value) == creall(actual->complex_value) && cimagl(expected->complex_value) == cimagl(actual->complex_value);
        default:
            return false;
    }
}

static void comparable_value_valuedescription(const struct ct_comparable_value *value, char * restrict buffer, size_t size)
{
    int write_count = 0;
    
    switch (value->type) {
        case CT_ANNOTATE_INTEGER:
            write_count = snprintf(buffer, size, "%"PRIdMAX, value->integer_value);
            break;
        case CT_ANNOTATE_UINTEGER:
            write_count = snprintf(buffer, size, "%"PRIuMAX, value->uinteger_value);
            break;
        case CT_ANNOTATE_FLOATINGPOINT:
            write_count = snprintf(buffer, size, "%.*Lg", DECIMAL_DIG, value->floatingpoint_value);
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
    
    if ((size_t)write_count >= size) {
        pretty_truncate(buffer, size);
    }
}

/////
// Test Suite and Test Case
/////

static void testcase_run(const struct ct_testcase *self, void * restrict testcontext, size_t index, struct runledger *ledger)
{
    if (!self->test) {
        ++ledger->ignored;
        printf("[ " cyan_text("%c") " ] - ignored test at index %zu (NULL function pointer found)\n", IgnoredTestChar, index);
        return;
    }
    
    self->test(testcontext);
    
    ++ledger->passed;
    printf("[ " green_text("\u2713") " ] - '%s' success\n", self->name);
}

static void testsuite_runcase(const struct ct_testsuite *self, size_t index, struct runledger *ledger)
{
    assertstate_reset();
    const struct ct_testcase *current_test = &self->tests[index];
    
    void *testcontext = NULL;
    if (self->setup) {
        self->setup(&testcontext);
    }
    
    if (setjmp(AssertSignal)) {
        assertstate_handle(current_test->name, ledger);
    } else {
        testcase_run(current_test, testcontext, index, ledger);
    }
    
    if (self->teardown) {
        self->teardown(&testcontext);
    }
}

/////
// Public Functions
/////

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    if (!suite || !suite->tests) {
        fprintf(stderr, "NULL test suite or NULL test list detected! No tests run.\n");
        return InvalidSuite;
    }
    
    uint64_t start_msecs = get_currentmsecs();
    print_runheader(suite, time(NULL));
    
    struct runledger ledger = { .passed = 0 };
    for (size_t i = 0; i < suite->count; ++i) {
        testsuite_runcase(suite, i, &ledger);
    }
    
    uint64_t elapsed_msecs = get_currentmsecs() - start_msecs;
    print_runfooter(suite, time(NULL), elapsed_msecs, &ledger);
    
    return ledger.failed;
}

_Noreturn void ct_internal_ignore(const char * restrict format, ...)
{
    assertstate_raise_signal(ASSERT_IGNORE, NULL, 0, format);
}

_Noreturn void ct_internal_assertfail(const char * restrict file, int line, const char * restrict format, ...)
{
    assertstate_setdescription("%s", "asserted unconditional failure");
    assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
}

void ct_internal_asserttrue(bool expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (!expression) {
        assertstate_setdescription("(%s) is true failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertfalse(bool expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is false failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnull(const void * restrict expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is NULL failed: (%p)", stringized_expression, expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotnull(const void * restrict expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (!expression) {
        assertstate_setdescription("(%s) is not NULL failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertequal(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription("(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (!comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        char valuestr_actual[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        comparable_value_valuedescription(&actual, valuestr_actual, sizeof valuestr_actual);
        assertstate_setdescription("(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotequal(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription("(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        assertstate_setdescription("(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertaboutequal(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char * restrict file, int line, const char * restrict format, ...)
{
    long double diff = fabsl(expected - actual);
    if (isgreater(diff, fabsl(precision)) || isnan(diff) || isnan(precision)) {
        assertstate_setdescription("(%s) differs from (%s) by greater than \u00b1 (%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotaboutequal(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char * restrict file, int line, const char * restrict format, ...)
{
    long double diff = fabsl(expected - actual);
    if (islessequal(diff, fabsl(precision))) {
        assertstate_setdescription("(%s) differs from (%s) by less than or equal to \u00b1 (%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertsame(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expected != actual) {
        assertstate_setdescription("(%s) is not the same as (%s): expected (%p), actual (%p)", stringized_expected, stringized_actual, expected, actual);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotsame(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expected == actual) {
        assertstate_setdescription("(%s) is the same as (%s): (%p)", stringized_expected, stringized_actual, expected);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertequalstrn(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char * restrict file, int line, const char * restrict format, ...)
{
    if ((expected && !actual) || (!expected && actual)
        || (expected && actual && (strncmp(expected, actual, n) != 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        char valuestr_actual[COMPVALUE_STR_SIZE];
        if ((size_t)snprintf(valuestr_expected, sizeof valuestr_expected, "%s", expected) >= sizeof valuestr_expected) {
            pretty_truncate(valuestr_expected, sizeof valuestr_expected);
        }
        if ((size_t)snprintf(valuestr_actual, sizeof valuestr_actual, "%s", actual) >= sizeof valuestr_actual) {
            pretty_truncate(valuestr_actual, sizeof valuestr_actual);
        }
        assertstate_setdescription("(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotequalstrn(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char * restrict file, int line, const char * restrict format, ...)
{
    if ((!expected && !actual) || (expected && actual && (strncmp(expected, actual, n) == 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        if ((size_t)snprintf(valuestr_expected, sizeof valuestr_expected, "%s", expected) >= sizeof valuestr_expected) {
            pretty_truncate(valuestr_expected, sizeof valuestr_expected);
        }
        assertstate_setdescription("(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}
