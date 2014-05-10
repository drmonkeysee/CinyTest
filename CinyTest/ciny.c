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
#include "ciny.h"

#define DATE_FORMAT_LENGTH 30
static const char * const DateFormatString = "%F %T";
static const char * const InvalidDateFormat = "Invalid Date (formatted output may have exceeded buffer size)";

#define ASSERTDESCRIPTION_LENGTH 200
#define ASSERTMESSAGE_LENGTH 1000
enum assert_type { ASSERT_UNKNOWN, ASSERT_FAILURE, ASSERT_IGNORE };
struct assert_state {
    enum assert_type type;
    const char *file;
    int line;
    char description[ASSERTDESCRIPTION_LENGTH];
    char message[ASSERTMESSAGE_LENGTH];
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
    
    char formatted_datetime[DATE_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATE_FORMAT_LENGTH, DateFormatString, localtime(&start_time));
    printf("Starting test suite '%s' at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    printf("Running %zu tests:\n", suite->count);
}

static void print_runfooter(const struct ct_testsuite *suite, time_t start_time, time_t end_time, const struct run_ledger *ledger)
{
    char formatted_datetime[DATE_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATE_FORMAT_LENGTH, DateFormatString, localtime(&end_time));
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

static _Bool pretty_truncate(char *str, size_t size)
{
    static const char * const ellipsis = "\u2026";
    size_t ellipsis_length = strlen(ellipsis);
    ptrdiff_t truncation_index = size - 1 - ellipsis_length;
    
    _Bool can_fit_ellipsis = truncation_index >= 0;
    if (can_fit_ellipsis) {
        str[truncation_index] = '\0';
        strcat(str, ellipsis);
    }
    
    return can_fit_ellipsis;
}

static void set_assertdescription(struct assert_state *assert_state, const char *format, ...)
{
    va_list format_args;
    va_start(format_args, format);
    int write_count = vsnprintf(assert_state->description, ASSERTDESCRIPTION_LENGTH, format, format_args);
    va_end(format_args);
    
    if (write_count >= ASSERTDESCRIPTION_LENGTH) {
        pretty_truncate(assert_state->description, ASSERTDESCRIPTION_LENGTH);
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
    int write_count = vsnprintf(assert_state->message, ASSERTMESSAGE_LENGTH, format, format_args);
    
    if (write_count >= ASSERTMESSAGE_LENGTH) {
        pretty_truncate(assert_state->message, ASSERTMESSAGE_LENGTH);
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

void ct_asserttrue_full(_Bool expression, const char *stringized_expression, const char *file, int line, const char *format, ...)
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
