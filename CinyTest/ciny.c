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

// call sites for inline functions
extern inline struct ct_testcase ct_maketest_full(const char *, ct_test_function);
extern inline struct ct_testsuite ct_makesuite_full(const char *, struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);

size_t ct_runsuite(struct ct_testsuite suite)
{
    time_t start_time = time(NULL);
    printf("Starting test suite '%s' at %s", suite.name, ctime(&start_time));
    printf("Running %zu tests:\n", suite.count);
    
    time_t end_time = time(NULL);
    double elapsed_time = difftime(start_time, end_time);
    printf("Test suite '%s' completed at %s", suite.name, ctime(&end_time));
    printf("Ran %zu tests (%.3f seconds): %zu passed, %zu failed, %zu ignored.\n", suite.count, elapsed_time, 0lu, 0lu, 0lu);
    
    return 0;
}