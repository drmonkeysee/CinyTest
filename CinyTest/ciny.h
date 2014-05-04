//
//  ciny.h
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
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
struct ct_testcase {
    const char *name;       /**< The function name of the test. */
    ct_test_function test;  /**< The test function. */
};

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
inline struct ct_testcase ct_maketest_full(const char *name, ct_test_function test)
{
    return (struct ct_testcase){ name, test };
}

/**
 A test suite.
 A named collection of test cases with optional setup and teardown functions.
 */
struct ct_testsuite {
    const char *name;                       /**< The name of the test suite. */
    struct ct_testcase *tests;              /**< The collection of tests to run. */
    size_t count;                           /**< The number of tests to be run. */
    ct_setupteardown_function setup;        /**< The test setup function. Run before each test case. May be NULL. */
    ct_setupteardown_function teardown;     /**< The test teardown function. Runs after each test case. May be NULL. */
};

/**
 Make a test suite for the list of tests.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list should be an lvalue
 to prevent multiple-evaluation side-effects.
 @return A test suite.
 */
#define ct_makesuite(test_list) (ct_makesuite_setup(test_list, NULL))
/**
 Make a test suite with a setup function.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list should be an lvalue
 to prevent multiple-evaluation side-effects.
 @param setup_function The setup function. Runs before each test case.
 @return A test suite.
 */
#define ct_makesuite_setup(test_list, setup_function) (ct_makesuite_setup_teardown(test_list, setup_function, NULL))
/**
 Make a test suite with a setup and teardown function.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list should be an lvalue
 to prevent multiple-evaluation side-effects.
 @param setup_function The setup function. Runs before each test case.
 @param teardown_function The teardown function. Runs after each test case.
 @return A test suite.
 */
#define ct_makesuite_setup_teardown(test_list, setup_function, teardown_function) \
            (ct_makesuite_full(__func__, \
                                test_list, \
                                ((test_list) ? (sizeof (test_list) / sizeof (test_list)[0]) : 0), \
                                setup_function, \
                                teardown_function))
/**
 Make a test suite with a full set of arguments.
 @param name The name of the test suite.
 @param tests The collection of test cases.
 @param count The number of test cases.
 @param setup The setup function. Runs before each test case. Can be NULL.
 @param teardown The teardown function. Runs after each test case. Can be NULL.
 @return A test suite.
 */
inline struct ct_testsuite ct_makesuite_full(const char *name,
                                             struct ct_testcase tests[],
                                             size_t count,
                                             ct_setupteardown_function setup,
                                             ct_setupteardown_function teardown)
{
    return (struct ct_testsuite){ name, tests, count, setup, teardown };
}

/**
 Run a unit test suite.
 @param suite The test suite to run.
 @return The number of failed tests.
 */
size_t ct_runsuite(const struct ct_testsuite *);

/**
 Assert failure unconditionally.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertfail(...) (ct_assertfail_full(__FILE__, __LINE__, "" __VA_ARGS__))
/**
 Assert failure unconditionally with contextual details and message.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_assertfail_full(const char *, int, const char *, ...);

#endif
