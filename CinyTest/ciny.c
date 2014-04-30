//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include <stddef.h>
#include <time.h>
#include <stdio.h>
#include "ciny.h"

#define DATE_FORMAT_LENGTH 30
static const char * const DateFormatString = "%F %T";
static const char * const InvalidDateFormat = "Unknown Date";

// call sites for inline functions
extern inline struct ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_full(const char *, struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);

static void print_runheader(const struct ct_testsuite *suite, const time_t *start_time)
{
    printf("=====- CinyTest Run -=====\n");
    
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
    
    printf("=====- CinyTest End -=====\n");
}

static void run_testcase(const struct ct_testcase *test_case, size_t index)
{
    if (test_case->test) {
        test_case->test(NULL);
        printf("[\u2714] - '%s' success\n", test_case->name);
    } else {
        printf("[?] - ignored test at index %zu (NULL function pointer found)\n", index);
    }
}

size_t ct_runsuite(const struct ct_testsuite *suite)
{
    time_t start_time = time(NULL);
    print_runheader(suite, &start_time);
    
    for (size_t i = 0; i < suite->count; ++i) {
        run_testcase(&suite->tests[i], i);
    }
    
    time_t end_time = time(NULL);
    print_runfooter(suite, &start_time, &end_time);
    
    return 0;
}
