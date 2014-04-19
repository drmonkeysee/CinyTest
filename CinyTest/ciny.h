//
//  ciny.h
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#ifndef CinyTest_ciny_h
#define CinyTest_ciny_h

#include <stddef.h>

/**
 Type definition for a unit test function.
 @param context Test context created in a suite's setup function.
 */
typedef void (*ct_test_function)(void *);

/**
 Type definition for a unit test setup or teardown function.
 @param context Pointer to a test context for initialization or destruction.
 The test context will be passed to all unit tests for a given suite.
 */
typedef void (*ct_setupteardown_function)(void **);

/**
 A test case structure.
 */
typedef struct {
    const char * const name;        /**< The function name of the test. */
    const ct_test_function test;    /**< The test function. */
} ct_testcase;

/**
 Create a test case out of a unit test function pointer.
 @param test_function The unit test function pointer from which to create the unit test.
 @return A test case.
 */
#define ct_maketest(test_function) ((ct_testcase){ #test_function, test_function })

/**
 Run a list of unit tests.
 Calculates the test list length automatically, therefore
 the tests argument should be an lvalue to prevent multiple-evaluation side-effects.
 @param tests The list of tests to run.
 @return The number of tests that failed.
 */
#define ct_runtests(tests) (ctp_runtests(tests, tests ? (sizeof tests / sizeof tests[0]) : 0))
int ctp_runtests(ct_testcase[], size_t);

//void atest(void *);
//
//int testblock(void)
//{
//    ct_testcase foo = ct_maketest(atest);
//    foo.test(NULL);
//    ct_testcase butts;
//    butts = ct_maketest(atest);
//    butts.test(NULL);
//    
//    return 0;
//}

#endif
