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
#include <limits.h>

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

/**
 Value type annotation.
 An enumeration of possible simple-value types used for equality assertions.
 */
enum ct_valuetype_annotation {
    CT_ANNOTATE_INVALID,            /**< Expression did not evaluate to a valid value type. */
    CT_ANNOTATE_INTEGRAL,           /**< Value is a signed integral type. */
    CT_ANNOTATE_UNSIGNED_INTEGRAL,  /**< Value is an unsigned integral type. */
    CT_ANNOTATE_FLOATINGPOINT,      /**< Value is a floating point type. */
    CT_ANNOTATE_COMPLEX             /**< Value is a complex number type. */
};
/**
 A comparable value.
 A general-purpose structure for respresenting expressions that can be compared for simple-value equality assertions.
 */
struct ct_comparable_value {
    union {
        long long integral_value;           /**< Access the value as a signed integral. */
        unsigned long long uintegral_value; /**< Access the value as an unsigned integral. */
        long double floating_value;         /**< Access the value as a floating point. */
        long double _Complex complex_value; /**< Access the value as a complex number. */
    };
    enum ct_valuetype_annotation type;      /**< Designates the correct type of the value. If type is CT_ANNOTATE_INVALID then the value is undefined. */
};

/**
 Convert a value expression into a comparable value type.
 @param v The value expression to convert.
 @return A comparable value structure for the given value expression.
 */
#define ct_makevalue(v) ct_makevalue_factory(v)(0, v)
/**
 Select a makevalue function for converting the given value expression into a comparable value type.
 @param v The value expression for which to select the comparable value creation function.
 @return A function pointer to a typed makevalue function.
 */
#define ct_makevalue_factory(v) _Generic(v, \
                                    ct_valuetype_variants(signed char,          ct_makevalue_integral), \
                                    ct_valuetype_variants(short,                ct_makevalue_integral), \
                                    ct_valuetype_variants(int,                  ct_makevalue_integral), \
                                    ct_valuetype_variants(long,                 ct_makevalue_integral), \
                                    ct_valuetype_variants(long long,            ct_makevalue_integral), \
                                    ct_valuetype_variants(char,                 ct_makevalue_char), \
                                    ct_valuetype_variants(_Bool,                ct_makevalue_uintegral), \
                                    ct_valuetype_variants(unsigned char,        ct_makevalue_uintegral), \
                                    ct_valuetype_variants(unsigned short,       ct_makevalue_uintegral), \
                                    ct_valuetype_variants(unsigned int,         ct_makevalue_uintegral), \
                                    ct_valuetype_variants(unsigned long,        ct_makevalue_uintegral), \
                                    ct_valuetype_variants(unsigned long long,   ct_makevalue_uintegral), \
                                    ct_valuetype_variants(float,                ct_makevalue_floating), \
                                    ct_valuetype_variants(double,               ct_makevalue_floating), \
                                    ct_valuetype_variants(long double,          ct_makevalue_floating), \
                                    ct_valuetype_variants(float _Complex,       ct_makevalue_complex), \
                                    ct_valuetype_variants(double _Complex,      ct_makevalue_complex), \
                                    ct_valuetype_variants(long double _Complex, ct_makevalue_complex), \
                                    default:                                    ct_makevalue_invalid)
/**
 Generate all unique value-type variants for a generic selection.
 @param T The compile-time type for which to generate the variants.
 @param e The expression to use in the generic selection for all type variants.
 */
#define ct_valuetype_variants(T, e) T: e, const T: e, volatile T: e, _Atomic T: e, const volatile T: e, const _Atomic T: e, volatile _Atomic T: e, const volatile _Atomic T: e

/**
 Create a char comparable value structure based on whether char is signed or unsigned.
 */
#if CHAR_MIN < 0
#define ct_makevalue_char ct_makevalue_integral
#else
#define ct_makevalue_char ct_makevalue_uintegral
#endif
/**
 Create a signed integral comparable value structure.
 @param placeholder An unused paramater to match arity for all makevalue functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the signed integral value to be converted.
 @return A comparable value structure for the signed integral value.
 */
inline struct ct_comparable_value ct_makevalue_integral(int placeholder, long long value)
{
    struct ct_comparable_value cv = { .integral_value = value, .type = CT_ANNOTATE_INTEGRAL };
    return cv;
}
/**
 Create an unsigned integral comparable value structure.
 @param placeholder An unused paramater to match arity for all makevalue functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the unsigned integral value to be converted.
 @return A comparable value structure for the unsigned integral value.
 */
inline struct ct_comparable_value ct_makevalue_uintegral(int placeholder, unsigned long long value)
{
    struct ct_comparable_value cv = { .uintegral_value = value, .type = CT_ANNOTATE_UNSIGNED_INTEGRAL };
    return cv;
}
/**
 Create a floating point comparable value structure.
 @param placeholder An unused paramater to match arity for all makevalue functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the floating point value to be converted.
 @return A comparable value structure for the floating point value.
 */
inline struct ct_comparable_value ct_makevalue_floating(int placeholder, long double value)
{
    struct ct_comparable_value cv = { .floating_value = value, .type = CT_ANNOTATE_FLOATINGPOINT };
    return cv;
}
/**
 Create a complex number comparable value structure.
 @param placeholder An unused paramater to match arity for all makevalue functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the complex number value to be converted.
 @return A comparable value structure for the complex number value.
 */
inline struct ct_comparable_value ct_makevalue_complex(int placeholder, long double _Complex value)
{
    struct ct_comparable_value cv = { .complex_value = value, .type = CT_ANNOTATE_COMPLEX };
    return cv;
}
/**
 Create a comparable value structure for an expression that cannot be converted into a simple value type.
 @param placeholder An unused paramater to allow for a variadic paramater. May be any value as it is ignored by the function.
 @param expression The non-value type expression that cannot be represented as a comparable value structure. Ignored by the function.
 @return An invalid comparable value structure used for checking a mismatched equality assertion.
 */
inline struct ct_comparable_value ct_makevalue_invalid(int placeholder, ...)
{
    struct ct_comparable_value cv = { .type = CT_ANNOTATE_INVALID };
    return cv;
}

/**
 Verify whether the expression can be converted into a valid value type.
 Failure raises a static assertion listing the offending expression and lists possible remedies.
 @param v The expression to verify as a simple value type.
 */
#define ct_checkvalue(v) _Static_assert(_Generic(&ct_makevalue_factory(v), struct ct_comparable_value (*)(int, ...): 0, default: 1), "(" #v ") is an invalid value type; use ct_assertequalp for pointer types, ct_assertequalstr for string types, or custom comparisons with ct_asserttrue for structs, unions, and arrays.")

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
