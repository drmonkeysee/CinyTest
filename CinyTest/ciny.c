//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
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

#define DATE_FORMAT_SIZE 30
static const char * const DateFormatString = "%F %T";
static const char * const InvalidDateFormat = "Invalid Date (formatted output may have exceeded buffer size)";

#define COMPVALUE_STR_SIZE 75
enum assert_type { ASSERT_UNKNOWN, ASSERT_FAILURE, ASSERT_IGNORE };
struct assert_state {
    enum assert_type type;
    const char *file;
    int line;
    char description[200 + (COMPVALUE_STR_SIZE * 2)];
    char message[1000];
};
static struct assert_state CurrentAssertState;
static jmp_buf AssertFired;

#define IGNORED_TEST_GLYPH "?"

struct run_ledger {
    size_t passed;
    size_t failed;
    size_t ignored;
};

// call sites for inline functions
extern inline struct ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_full(const char *, struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);

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

static void print_runfooter(const struct ct_testsuite *suite, time_t start_time, time_t end_time, const struct run_ledger *ledger)
{
    char formatted_datetime[DATE_FORMAT_SIZE];
    size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, DateFormatString, localtime(&end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    double elapsed_time = difftime(start_time, end_time);
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite->count, elapsed_time, ledger->passed, ledger->failed, ledger->ignored);
    
    print_delimiter("End");
}

static void reset_assertstate(struct assert_state *assert_state)
{
    assert_state->type = ASSERT_UNKNOWN;
    assert_state->file = NULL;
    assert_state->line = 0;
    assert_state->description[0] = '\0';
    assert_state->message[0] = '\0';
}

static void print_assertmessage(const char *message)
{
    if (printf("%s", message)) {
        printf("\n");
    }
}

static void handle_assertfailure(const struct assert_state *assert_state, const char *testname, struct run_ledger *ledger)
{
    ++ledger->failed;
    printf("[\u2718] - '%s' failure\n", testname);
    printf("%s L.%d : %s\n", assert_state->file, assert_state->line, assert_state->description);
    print_assertmessage(assert_state->message);
}

static void handle_assertignore(const struct assert_state *assert_state, const char *testname, struct run_ledger *ledger)
{
    ++ledger->ignored;
    printf("[" IGNORED_TEST_GLYPH "] - '%s' ignored\n", testname);
    print_assertmessage(assert_state->message);
}

static void handle_assertion(const struct assert_state *assert_state, const char *testname, struct run_ledger *ledger)
{
    switch (assert_state->type) {
        case ASSERT_FAILURE:
            handle_assertfailure(assert_state, testname, ledger);
            break;
            
        case ASSERT_IGNORE:
            handle_assertignore(assert_state, testname, ledger);
            break;
            
        default:
            fprintf(stderr, "WARNING: unknown assertion type encountered!\n");
            break;
    }
}

static void run_testcase(const struct ct_testcase *testcase, void *testcontext, size_t index, struct run_ledger *ledger)
{
    if (!testcase->test) {
        ++ledger->ignored;
        printf("[" IGNORED_TEST_GLYPH "] - ignored test at index %zu (NULL function pointer found)\n", index);
        return;
    }
    
    testcase->test(testcontext);
    
    ++ledger->passed;
    printf("[\u2714] - '%s' success\n", testcase->name);
}

static void run_test(size_t index, const struct ct_testsuite *suite, struct run_ledger *ledger)
{
    reset_assertstate(&CurrentAssertState);
    struct ct_testcase *current_test = &suite->tests[index];
    
    void *testcontext = NULL;
    if (suite->setup) {
        suite->setup(&testcontext);
    }
    
    if (setjmp(AssertFired)) {
        handle_assertion(&CurrentAssertState, current_test->name, ledger);
    } else {
        run_testcase(current_test, testcontext, index, ledger);
    }
    
    if (suite->teardown) {
        suite->teardown(&testcontext);
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

static void set_assertdescription(struct assert_state *assert_state, const char *format, ...)
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

#define capture_assertmessage(assert_state, format) \
            do { \
                va_list format_args; \
                va_start(format_args, (format)); \
                capture_assertmessage_full((assert_state), (format), format_args); \
                va_end(format_args); \
            } while (0)
static void capture_assertmessage_full(struct assert_state *assert_state, const char *format, va_list format_args)
{
    size_t message_size = sizeof assert_state->message;
    int write_count = vsnprintf(assert_state->message, message_size, format, format_args);
    
    if (write_count >= message_size) {
        pretty_truncate(assert_state->message, message_size);
    }
}

static bool comparablevalue_comparetypes(struct ct_comparable_value *expected, struct ct_comparable_value *actual)
{
    return expected->type == actual->type;
}

static const char *comparablevalue_typedescription(struct ct_comparable_value *value)
{
    switch (value->type) {
        case CT_ANNOTATE_INTEGRAL:
            return "integral";
        case CT_ANNOTATE_UNSIGNED_INTEGRAL:
            return "unsigned integral";
        case CT_ANNOTATE_FLOATINGPOINT:
            return "floating point";
        case CT_ANNOTATE_COMPLEX:
            return "complex";
        default:
            return "invalid value type";
    }
}

static bool comparablevalue_comparevalues(struct ct_comparable_value *expected, struct ct_comparable_value *actual)
{
    switch (expected->type) {
        case CT_ANNOTATE_INTEGRAL:
            return expected->integral_value == actual->integral_value;
        case CT_ANNOTATE_UNSIGNED_INTEGRAL:
            return expected->uintegral_value == actual->uintegral_value;
        case CT_ANNOTATE_FLOATINGPOINT:
            return expected->floating_value == actual->floating_value;
        case CT_ANNOTATE_COMPLEX:
            return creall(expected->complex_value) == creall(actual->complex_value) && cimagl(expected->complex_value) == cimagl(actual->complex_value);
        default:
            return false;
    }
}

static void comparablevalue_valuedescription(struct ct_comparable_value *value, char *buffer, size_t size)
{
    int write_count = 0;
    long double i_value;
    
    switch (value->type) {
        case CT_ANNOTATE_INTEGRAL:
            write_count = snprintf(buffer, size, "%lld", value->integral_value);
            break;
        case CT_ANNOTATE_UNSIGNED_INTEGRAL:
            write_count = snprintf(buffer, size, "%llu", value->uintegral_value);
            break;
        case CT_ANNOTATE_FLOATINGPOINT:
            write_count = snprintf(buffer, size, "%.*Lg", DECIMAL_DIG, value->floating_value);
            break;
        case CT_ANNOTATE_COMPLEX:
            i_value = cimagl(value->complex_value);
            if (i_value < 0.0) {
                write_count = snprintf(buffer, size, "%.*Lg - %.*Lgi", DECIMAL_DIG, creall(value->complex_value), DECIMAL_DIG, fabsl(i_value));
            } else {
                write_count = snprintf(buffer, size, "%.*Lg + %.*Lgi", DECIMAL_DIG, creall(value->complex_value), DECIMAL_DIG, i_value);
            }
            break;
        default:
            write_count = snprintf(buffer, size, "invalid value");
            break;
    }
    
    if (write_count >= size) {
        pretty_truncate(buffer, size);
    }
}

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    time_t start_time = time(NULL);
    print_runheader(suite, start_time);
    
    struct run_ledger ledger = { 0, 0, 0 };
    for (size_t i = 0; i < suite->count; ++i) {
        run_test(i, suite, &ledger);
    }
    
    time_t end_time = time(NULL);
    print_runfooter(suite, start_time, end_time, &ledger);
    
    return ledger.failed;
}

_Noreturn void ct_ignore_full(const char *format, ...)
{
    CurrentAssertState.type = ASSERT_IGNORE;
    capture_assertmessage(&CurrentAssertState, format);
    
    longjmp(AssertFired, CurrentAssertState.type);
}

_Noreturn void ct_assertfail_full(const char *file, int line, const char *format, ...)
{
    CurrentAssertState.type = ASSERT_FAILURE;
    CurrentAssertState.file = file;
    CurrentAssertState.line = line;
    set_assertdescription(&CurrentAssertState, "%s", "asserted unconditional failure");
    capture_assertmessage(&CurrentAssertState, format);
    
    longjmp(AssertFired, CurrentAssertState.type);
}

void ct_asserttrue_full(bool expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (!expression) {
        CurrentAssertState.type = ASSERT_FAILURE;
        CurrentAssertState.file = file;
        CurrentAssertState.line = line;
        set_assertdescription(&CurrentAssertState, "(%s) is true failed", stringized_expression);
        capture_assertmessage(&CurrentAssertState, format);
        
        longjmp(AssertFired, CurrentAssertState.type);
    }
}

void ct_assertfalse_full(bool expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (expression) {
        CurrentAssertState.type = ASSERT_FAILURE;
        CurrentAssertState.file = file;
        CurrentAssertState.line = line;
        set_assertdescription(&CurrentAssertState, "(%s) is false failed", stringized_expression);
        capture_assertmessage(&CurrentAssertState, format);
        
        longjmp(AssertFired, CurrentAssertState.type);
    }
}

void ct_assertnull_full(void *expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (expression) {
        CurrentAssertState.type = ASSERT_FAILURE;
        CurrentAssertState.file = file;
        CurrentAssertState.line = line;
        set_assertdescription(&CurrentAssertState, "(%s) is NULL failed: (%p)", stringized_expression, expression);
        capture_assertmessage(&CurrentAssertState, format);
        
        longjmp(AssertFired, CurrentAssertState.type);
    }
}

void ct_assertnotnull_full(void *expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
{
    if (!expression) {
        CurrentAssertState.type = ASSERT_FAILURE;
        CurrentAssertState.file = file;
        CurrentAssertState.line = line;
        set_assertdescription(&CurrentAssertState, "(%s) is not NULL failed", stringized_expression);
        capture_assertmessage(&CurrentAssertState, format);
        
        longjmp(AssertFired, CurrentAssertState.type);
    }
}

void ct_assertequal_full(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char *file, int line, const char *format, ...)
{
    if (!comparablevalue_comparetypes(&expected, &actual)) {
        set_assertdescription(&CurrentAssertState, "(%s) is not equal to (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparablevalue_typedescription(&expected), comparablevalue_typedescription(&actual));
    } else if (!comparablevalue_comparevalues(&expected, &actual)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        char valuestr_actual[COMPVALUE_STR_SIZE];
        comparablevalue_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        comparablevalue_valuedescription(&actual, valuestr_actual, sizeof valuestr_actual);
        set_assertdescription(&CurrentAssertState, "(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
    }
    
    if (CurrentAssertState.description[0]) {
        CurrentAssertState.type = ASSERT_FAILURE;
        CurrentAssertState.file = file;
        CurrentAssertState.line = line;
        capture_assertmessage(&CurrentAssertState, format);
        
        longjmp(AssertFired, CurrentAssertState.type);
    }
}
