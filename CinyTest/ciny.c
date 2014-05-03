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
struct assert_state {
    const char *file;
    int line;
    const char *failure;
    char message[ASSERTMESSAGE_LENGTH];
};
static struct assert_state CurrentAssertState;
static jmp_buf AssertBreak;

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

static void print_runfooter(const struct ct_testsuite *suite, const time_t * restrict start_time, const time_t * restrict end_time)
{
    char formatted_datetime[DATE_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATE_FORMAT_LENGTH, DateFormatString, localtime(end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    double elapsed_time = difftime(*start_time, *end_time);
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite->count, elapsed_time, 0lu, 0lu, 0lu);
    
    print_delimiter("End");
}

static void reset_assertstate(struct assert_state *assert_state)
{
    assert_state->file = NULL;
    assert_state->line = 0;
    assert_state->failure = NULL;
    assert_state->message[0] = '\0';
}

static void print_assertstate(const struct assert_state *assert_state, const struct ct_testcase *current_test)
{
    printf("[\u2718] - '%s' failure\n", current_test->name);
    printf("%s L.%d : %s\n", assert_state->file, assert_state->line, assert_state->failure);
    if (printf("%s", assert_state->message)) {
        printf("\n");
    }
}

static void run_testcase(const struct ct_testsuite *test_suite, size_t index)
{
    struct ct_testcase *test_case = &test_suite->tests[index];
    if (!test_case->test) {
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
    
    printf("[\u2714] - '%s' success\n", test_case->name);
}

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    size_t failure_count = 0;
    time_t start_time = time(NULL);
    print_runheader(suite, &start_time);
    
    for (size_t i = 0; i < suite->count; ++i) {
        reset_assertstate(&CurrentAssertState);
        
        if (setjmp(AssertBreak)) {
            ++failure_count;
            print_assertstate(&CurrentAssertState, &suite->tests[i]);
        } else {
            run_testcase(suite, i);
        }
    }
    
    time_t end_time = time(NULL);
    print_runfooter(suite, &start_time, &end_time);
    
    return failure_count;
}

_Noreturn void ct_assertfail_full(const char *file, int line, const char *format, ...)
{
    CurrentAssertState.file = file;
    CurrentAssertState.line = line;
    CurrentAssertState.failure = "failure asserted";
    
    va_list format_args;
    va_start(format_args, format);
    if (vsnprintf(CurrentAssertState.message, ASSERTMESSAGE_LENGTH, format, format_args) >= ASSERTMESSAGE_LENGTH) {
        static const char * const ellipsis = "\u2026";
        size_t ellipsis_length = strlen(ellipsis);
        CurrentAssertState.message[ASSERTMESSAGE_LENGTH - 1 - ellipsis_length] = '\0';
        strcat(CurrentAssertState.message, ellipsis);
    }
    va_end(format_args);
    
    longjmp(AssertBreak, 1);
}
