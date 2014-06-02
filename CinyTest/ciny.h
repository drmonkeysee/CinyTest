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
#define ct_maketest(test_function) ct_maketest_full(#test_function, test_function)
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
#define ct_makesuite(test_list) ct_makesuite_setup(test_list, NULL)
/**
 Make a test suite with a setup function.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list should be an lvalue
 to prevent multiple-evaluation side-effects.
 @param setup_function The setup function. Runs before each test case.
 @return A test suite.
 */
#define ct_makesuite_setup(test_list, setup_function) ct_makesuite_setup_teardown(test_list, setup_function, NULL)
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
            ct_makesuite_full(__func__, \
                                test_list, \
                                ((test_list) ? (sizeof (test_list) / sizeof (test_list)[0]) : 0), \
                                setup_function, \
                                teardown_function)
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
 Mark a test as ignored.
 To prevent possible side-effects add this assertion as the first line of the test.
 @param message A printf-style format string with optional arguments to display when the test is ignored.
 */
#define ct_ignore(...) ct_ignore_full("" __VA_ARGS__)
/**
 Mark a test as ignored.
 To prevent possible side-effects add this assertion as the first line of the test.
 Not intended for direct use.
 @see ct_ignore
 @param format The printf-style format string to display when the test is ignored.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_ignore_full(const char *, ...);

/**
 Assert failure unconditionally.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertfail(...) ct_assertfail_full(__FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert failure unconditionally with contextual details and message.
 Not intended for direct use.
 @see ct_assertfail
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_assertfail_full(const char *, int, const char *, ...);

/**
 Assert whether an expression is true.
 @param expression The expression to evaluate against the value true.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_asserttrue(expression, ...) ct_asserttrue_full(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether the expression is true, with contextual details and message.
 Not intended for direct use.
 @see ct_asserttrue
 @param expression The expression to evaluate against the value true.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
void ct_asserttrue_full(_Bool, const char *, const char *, int, const char *, ...);

/**
 Assert whether an expression is false.
 @param expression The expression to evaluate against the value false.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertfalse(expression, ...) ct_assertfalse_full(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether the expression is false, with contextual details and message.
 Not intended for direct use.
 @see ct_assertfalse
 @param expression The expression to evaluate against the value false.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
void ct_assertfalse_full(_Bool, const char *, const char *, int, const char *, ...);

/**
 Assert whether an expression is NULL.
 @param expression The expression to evaluate against the value NULL.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertnull(expression, ...) ct_assertnull_full(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether the expression is NULL, with contextual details and message.
 Not intended for direct use.
 @see ct_assertnull
 @param expression The expression to evaluate against the value NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
void ct_assertnull_full(void *, const char *, const char *, int, const char *, ...);

/**
 Assert whether an expression is not NULL.
 @param expression The expression to evaluate against the value !NULL.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertnotnull(expression, ...) ct_assertnotnull_full(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether the expression is not NULL, with contextual details and message.
 Not intended for direct use.
 @see ct_assertnotnull
 @param expression The expression to evaluate against the value !NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
void ct_assertnotnull_full(void *, const char *, const char *, int, const char *, ...);

enum ct_valuetype_annotation {
    CT_ANNOTATE_INVALID,
    CT_ANNOTATE_INTEGRAL,
    CT_ANNOTATE_UNSIGNED_INTEGRAL,
    CT_ANNOTATE_FLOATINGPOINT,
    CT_ANNOTATE_COMPLEX
};
struct ct_comparable_value {
    union {
        long long integral_value;
        unsigned long long uintegral_value;
        long double floating_value;
        long double _Complex complex_value;
    };
    enum ct_valuetype_annotation type;
};

#define ct_makevalue(v) ct_makevalue_annotated(v, ct_valuetype_annotation(v))
#define ct_makevalue_annotated(v, T) ((T) == CT_ANNOTATE_INTEGRAL ? ct_makevalue_integral(v) \
                                        : (T) == CT_ANNOTATE_UNSIGNED_INTEGRAL ? ct_makevalue_uintegral(v) \
                                        : (T) == CT_ANNOTATE_FLOATINGPOINT ? ct_makevalue_floating(v) \
                                        : (T) == CT_ANNOTATE_COMPLEX ? ct_makevalue_complex(v) \
                                        : ct_makevalue_invalid())
#define ct_checkvalue(v) _Static_assert(ct_valuetype_annotation(v), "invalid value type; use ct_assertequalp for pointer types, ct_assertequalstr for string types, or custom comparisons with ct_asserttrue for structs, unions, and arrays.")
// TODO: how do i annotate char?
#define ct_valuetype_annotation(v) _Generic(v, \
                                        signed char: CT_ANNOTATE_INTEGRAL, \
                                        short: CT_ANNOTATE_INTEGRAL, \
                                        int: CT_ANNOTATE_INTEGRAL, \
                                        long: CT_ANNOTATE_INTEGRAL, \
                                        long long: CT_ANNOTATE_INTEGRAL, \
                                        _Bool: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        unsigned char: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        unsigned short: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        unsigned int: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        unsigned long: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        unsigned long long: CT_ANNOTATE_UNSIGNED_INTEGRAL, \
                                        float: CT_ANNOTATE_FLOATINGPOINT, \
                                        double: CT_ANNOTATE_FLOATINGPOINT, \
                                        long double: CT_ANNOTATE_FLOATINGPOINT, \
                                        float _Complex: CT_ANNOTATE_COMPLEX, \
                                        double _Complex: CT_ANNOTATE_COMPLEX, \
                                        long double _Complex: CT_ANNOTATE_COMPLEX, \
                                        default: CT_ANNOTATE_INVALID)
inline struct ct_comparable_value ct_makevalue_integral(long long value)
{
    struct ct_comparable_value cv = { .integral_value = value, .type = CT_ANNOTATE_INTEGRAL };
    return cv;
}
inline struct ct_comparable_value ct_makevalue_uintegral(unsigned long long value)
{
    struct ct_comparable_value cv = { .uintegral_value = value, .type = CT_ANNOTATE_UNSIGNED_INTEGRAL };
    return cv;
}
inline struct ct_comparable_value ct_makevalue_floating(long double value)
{
    struct ct_comparable_value cv = { .floating_value = value, .type = CT_ANNOTATE_FLOATINGPOINT };
    return cv;
}
inline struct ct_comparable_value ct_makevalue_complex(long double _Complex value)
{
    struct ct_comparable_value cv = { .complex_value = value, .type = CT_ANNOTATE_COMPLEX };
    return cv;
}
inline struct ct_comparable_value ct_makevalue_invalid(void)
{
    struct ct_comparable_value cv = { .type = CT_ANNOTATE_INVALID };
    return cv;
}

/**
 Assert whether two values are equal.
 Compares any two basic value types but does not handle pointers, structs, unions, arrays, or function pointers.
 @see ct_assertequalp for pointer equality.
 @see ct_assertequalstr for string equality.
 @param expected The expected value.
 @param actual The actual value.
 @param message A printf-style format string with optional arguments to display when the assertion fires.
 */
#define ct_assertequal(expected, actual, ...) \
            do { \
                ct_checkvalue(expected); \
                ct_checkvalue(actual); \
                ct_assertequal_full(ct_makevalue(expected), #expected, ct_makevalue(actual), #actual, __FILE__, __LINE__, "" __VA_ARGS__); \
            } while (0)
/**
 Assert whether two values are equal, with contextual details and message.
 Not intended for direct use.
 @see ct_assertequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fires.
 @param format_args Format arguments for the format string.
 */
void ct_assertequal_full(struct ct_comparable_value, const char *, struct ct_comparable_value, const char *, const char *, int, const char *, ...);

#define ct_assertequalp(expected, actual, ...) ()

#define ct_assertequalstr(expected, actual, ...) ()

#endif
