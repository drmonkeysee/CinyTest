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

#define DATETIME_FORMAT_LENGTH 30
static const char * const DateFormatString = "%F %T";
static const char * const InvalidDateFormat = "Unknown DateTime";

// call sites for inline functions
extern inline struct ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_full(const char *, struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);

static void print_suiteheader(const struct ct_testsuite *suite, const time_t *start_time)
{
    printf("=====- CT RUN -=====\n");
    
    char formatted_datetime[DATETIME_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATETIME_FORMAT_LENGTH, DateFormatString, localtime(start_time));
    printf("Starting test suite '%s' at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    printf("Running %zu tests:\n", suite->count);
}

static void print_suitefooter(const struct ct_testsuite *suite, const time_t * restrict start_time, const time_t * restrict end_time)
{
    char formatted_datetime[DATETIME_FORMAT_LENGTH];
    size_t format_length = strftime(formatted_datetime, DATETIME_FORMAT_LENGTH, DateFormatString, localtime(end_time));
    printf("Test suite '%s' completed at %s\n", suite->name, format_length ? formatted_datetime : InvalidDateFormat);
    
    double elapsed_time = difftime(*start_time, *end_time);
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite->count, elapsed_time, 0lu, 0lu, 0lu);
    
    printf("=====- CT END -=====\n");
}

size_t ct_runsuite(struct ct_testsuite suite)
{
    time_t start_time = time(NULL);
    print_suiteheader(&suite, &start_time);
    
    time_t end_time = time(NULL);
    print_suitefooter(&suite, &start_time, &end_time);
    
    return 0;
}