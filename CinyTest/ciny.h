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
 A test case.
 A named function that executes a single unit test.
 */
typedef struct {
    const char * const name;        /**< The function name of the test. */
    const ct_test_function test;    /**< The test function. */
} ct_testcase;

/**
 Make a test case.
 Uses the name of the unit test function as the name of the test case.
 @param test_function The unit test function for the test case.
 @return A test case.
 */
#define ct_maketest(test_function) (ct_maketest_full(#test_function, test_function))
/**
 Make a test case with a full set of arguments.
 @param name The name of the test case.
 @param test The unit test function for the test case.
 @return A test case.
 */
inline ct_testcase ct_maketest_full(const char *name, ct_test_function test)
{
    return (ct_testcase){ name, test };
}

/**
 A test suite.
 A named collection of test cases with optional setup and teardown functions.
 */
typedef struct {
    const char * const name;                    /**< The name of the test suite. */
    const ct_testcase * const tests;            /**< The collection of tests to run. */
    const size_t count;                         /**< The number of tests to be run. */
    const ct_setupteardown_function setup;      /**< The test setup function. Run before each test case. May be NULL. */
    const ct_setupteardown_function teardown;   /**< The test teardown function. Runs after each test case. May be NULL. */
} ct_testsuite;

/**
 Make a test suite with a full set of arguments.
 @param name The name of the test suite.
 @param tests The collection of test cases.
 @param count The number of test cases.
 @param setup The setup function. Runs before each test case. Can be NULL.
 @param teardown The teardown function. Runs after each test case. Can be NULL.
 @return A test suite.
 */
inline ct_testsuite ct_makesuite_full(const char *name, ct_testcase tests[], size_t count, ct_setupteardown_function setup, ct_setupteardown_function teardown)
{
    return (ct_testsuite){ name, tests, count, setup, teardown };
}

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
//    ct_testcase blob = ct_maketest_full("blah", atest);
//    ct_testcase bort[] = { ct_maketest(atest), ct_maketest(atest) };
//    ct_testsuite *blah = ct_p_makesuite("blah", bort, sizeof bort / sizeof bort[0]);
//    ct_freesuite(blah);
//    ct_testsuite suite = { .tests = bort };
//    suite.tests[1] = ct_maketest(atest);
//    
//    return 0;
//}

#endif
