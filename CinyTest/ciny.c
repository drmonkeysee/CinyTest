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

#define ASSERTMESSAGE_LENGTH 1000
enum assert_type { ASSERT_UNKNOWN, ASSERT_FAILURE, ASSERT_IGNORE };
struct assert_state {
    enum assert_type type;
    const char *file;
    int line;
    const char *description;
    char message[ASSERTMESSAGE_LENGTH];
};
static struct assert_state CurrentAssertState;
static jmp_buf AssertFired;

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

static void print_runheader(const struct ct_testsuite *suite, const time_t *start_time)
{
    print_delimiter("Run");
    
    char formatted_datetime[DATE_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATE_FORMAT_LENGTH, DateFormatString, localtime(start_time));
    printf("Starting test suite '%s' at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    printf("Running %zu tests:\n", suite->count);
}

static void print_runfooter(const struct ct_testsuite *suite, const time_t * restrict start_time, const time_t * restrict end_time, const struct run_ledger *ledger)
{
    char formatted_datetime[DATE_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATE_FORMAT_LENGTH, DateFormatString, localtime(end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    double elapsed_time = difftime(*start_time, *end_time);
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite->count, elapsed_time, ledger->passed, ledger->failed, ledger->ignored);
    
    print_delimiter("End");
}

static void reset_assertstate(struct assert_state *assert_state)
{
    assert_state->type = ASSERT_UNKNOWN;
    assert_state->file = NULL;
    assert_state->line = 0;
    assert_state->description = NULL;
    assert_state->message[0] = '\0';
}

static void print_assertstate(const struct assert_state *assert_state, const struct ct_testcase *current_test)
{
    printf("[\u2718] - '%s' failure\n", current_test->name);
    printf("%s L.%d : %s\n", assert_state->file, assert_state->line, assert_state->description);
    if (printf("%s", assert_state->message)) {
        printf("\n");
    }
}

static void run_testcase(const struct ct_testsuite *test_suite, size_t index, struct run_ledger *ledger)
{
    struct ct_testcase *test_case = &test_suite->tests[index];
    if (!test_case->test) {
        ++ledger->ignored;
        printf("[?] - ignored test at index %zu (NULL function pointer found)\n", index);
        return;
    }
    
    void *test_context = NULL;
    if (test_suite->setup) {
        test_suite->setup(&test_context);
    }
    
    test_case->test(test_context);
    
    if (test_suite->teardown) {
        test_suite->teardown(&test_context);
    }
    
    ++ledger->passed;
    printf("[\u2714] - '%s' success\n", test_case->name);
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
        static const char * const ellipsis = "\u2026";
        size_t ellipsis_length = strlen(ellipsis);
        assert_state->message[ASSERTMESSAGE_LENGTH - 1 - ellipsis_length] = '\0';
        strcat(assert_state->message, ellipsis);
    }
}

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    time_t start_time = time(NULL);
    print_runheader(suite, &start_time);
    
    struct run_ledger ledger = { 0, 0, 0 };
    for (size_t i = 0; i < suite->count; ++i) {
        reset_assertstate(&CurrentAssertState);
        
        if (setjmp(AssertFired)) {
            ++ledger.failed;
            print_assertstate(&CurrentAssertState, &suite->tests[i]);
        } else {
            run_testcase(suite, i, &ledger);
        }
    }
    
    time_t end_time = time(NULL);
    print_runfooter(suite, &start_time, &end_time, &ledger);
    
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
    CurrentAssertState.description = "failure asserted";
    capture_assertmessage(&CurrentAssertState, format);
    
    longjmp(AssertFired, CurrentAssertState.type);
}
