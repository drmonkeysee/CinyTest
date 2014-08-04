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
 @file
 Header file for CinyTest type and function definitions
 */

/**
 @defgroup public Public types and functions
 @{
 */

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
#define ct_maketest(test_function) ct_maketest_named(#test_function, test_function)
/**
 Make a test case with a name.
 @param name The name of the test case.
 @param test The unit test function for the test case.
 @return A test case.
 */
inline struct ct_testcase ct_maketest_named(const char *name, ct_test_function test)
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
            ct_makesuite_setup_teardown_named(__func__, \
                                test_list, \
                                ((test_list) ? (sizeof (test_list) / sizeof (test_list)[0]) : 0), \
                                setup_function, \
                                teardown_function)
/**
 Make a test suite with a setup function, teardown function, and a name.
 @param name The name of the test suite.
 @param tests The collection of test cases.
 @param count The number of test cases.
 @param setup The setup function. Runs before each test case. Can be NULL.
 @param teardown The teardown function. Runs after each test case. Can be NULL.
 @return A test suite.
 */
inline struct ct_testsuite ct_makesuite_setup_teardown_named(const char *name,
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
size_t ct_runsuite(const struct ct_testsuite *suite);

/**
 Mark a test as ignored.
 To prevent possible side-effects add this assertion as the first line of the test.
 @param message A printf-style format string with optional arguments to display when the test is ignored.
 */
#define ct_ignore(...) ct_internal_ignore("" __VA_ARGS__)

/**
 Assert failure unconditionally.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertfail(...) ct_internal_assertfail(__FILE__, __LINE__, "" __VA_ARGS__)

/**
 Assert whether an expression is true.
 @param expression The expression to evaluate against the value true.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_asserttrue(expression, ...) ct_internal_asserttrue(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether an expression is false.
 @param expression The expression to evaluate against the value false.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertfalse(expression, ...) ct_internal_assertfalse(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)

/**
 Assert whether an expression is NULL.
 @param expression The expression to evaluate against the value NULL.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnull(expression, ...) ct_internal_assertnull(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether an expression is not NULL.
 @param expression The expression to evaluate against the value !NULL.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnotnull(expression, ...) ct_internal_assertnotnull(expression, #expression, __FILE__, __LINE__, "" __VA_ARGS__)

/**
 Assert whether two values are equal.
 Compares any two basic value types but does not handle pointers, structs, unions, arrays, or function pointers.
 @see ct_assertequalp for pointer equality.
 @see ct_assertequalstr for string equality.
 @param expected The expected value.
 @param actual The actual value.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertequal(expected, actual, ...) \
            do { \
                ct_checkvalue(expected); \
                ct_checkvalue(actual); \
                ct_internal_assertequal(ct_makevalue(expected), #expected, ct_makevalue(actual), #actual, __FILE__, __LINE__, "" __VA_ARGS__); \
            } while (0)
/**
 Assert whether two values are not equal.
 Compares any two basic value types but does not handle pointers, structs, unions, arrays, or function pointers.
 @see ct_assertequalp for pointer equality.
 @see ct_assertequalstr for string equality.
 @param expected The expected value.
 @param actual The actual value.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnotequal(expected, actual, ...) \
            do { \
                ct_checkvalue(expected); \
                ct_checkvalue(actual); \
                ct_internal_assertnotequal(ct_makevalue(expected), #expected, ct_makevalue(actual), #actual, __FILE__, __LINE__, "" __VA_ARGS__); \
            } while (0)

/**
 Assert whether two values are equal within plus or minus a degree of error.
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param precision The range of precision within which expected and actual may be considered equal.
 */
#define ct_assertaboutequal(expected, actual, precision, ...) ct_internal_assertaboutequal(expected, #expected, actual, #actual, precision, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether two values are not equal within plus or minus a degree of error.
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param precision The range of precision within which expected and actual may be considered not equal.
 */
#define ct_assertnotaboutequal(expected, actual, precision, ...) ct_internal_assertnotaboutequal(expected, #expected, actual, #actual, precision, __FILE__, __LINE__, "" __VA_ARGS__)

/**
 Assert whether two pointers refer to the same object.
 @param expected The expected pointer.
 @param actual The actual pointer.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertsame(expected, actual, ...) ct_internal_assertsame(expected, #expected, actual, #actual, __FILE__, __LINE__, "" __VA_ARGS__)
/**
 Assert whether two pointers refer to different objects.
 @param expected The expected pointer.
 @param actual The actual pointer.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnotsame(expected, actual, ...) ct_internal_assertnotsame(expected, #expected, actual, #actual, __FILE__, __LINE__, "" __VA_ARGS__)

/**
 Assert whether two strings are equal.
 The first argument is a string literal to prevent inadvertent buffer overrun during equality comparison.
 @param expected The expected string. Must be a string literal expression.
 @param actual The actual string.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertequalstr(expected, actual, ...) ct_internal_assertequalstrn("" expected, #expected, actual, #actual, sizeof (expected), __FILE__, __LINE__, "" __VA_ARGS__);
/**
 Assert whether two strings are equal.
 Compares up to length characters for equality.
 @param expected The expected string.
 @param actual The actual string.
 @param n The maximum number of characters to compare for equality. Must not be greater than the size of expected.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertequalstrn(expected, actual, n, ...) ct_internal_assertequalstrn(expected, #expected, actual, #actual, n, __FILE__, __LINE__, "" __VA_ARGS__);
/**
 Assert whether two strings are not equal.
 The first argument is a string literal to prevent inadvertent buffer overrun during equality comparison.
 @param expected The expected string. Must be a string literal expression.
 @param actual The actual string.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnotequalstr(expected, actual, ...) ct_internal_assertnotequalstrn("" expected, #expected, actual, #actual, sizeof (expected), __FILE__, __LINE__, "" __VA_ARGS__);
/**
 Assert whether two strings are not equal.
 Compares up to length characters for inequality.
 @param expected The expected string.
 @param actual The actual string.
 @param n The maximum number of characters to compare for inequality. Must not be greater than the size of expected.
 @param message A printf-style format string with optional arguments to display when the assertion fails.
 */
#define ct_assertnotequalstrn(expected, actual, n, ...) ct_internal_assertnotequalstrn(expected, #expected, actual, #actual, n, __FILE__, __LINE__, "" __VA_ARGS__);

/**
 @}
 */

/**
 @defgroup internal Internal types and functions
 @{
 */
/**
 Value type annotation.
 An enumeration of possible simple-value types used for equality assertions.
 */
enum ct_valuetype_annotation {
    CT_ANNOTATE_INVALID,            /**< Expression did not evaluate to a valid value type. */
    CT_ANNOTATE_INTEGRAL,           /**< Value is a signed integral type. */
    CT_ANNOTATE_UNSIGNEDINTEGRAL,   /**< Value is an unsigned integral type. */
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
    struct ct_comparable_value cv = { .uintegral_value = value, .type = CT_ANNOTATE_UNSIGNEDINTEGRAL };
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
#define ct_checkvalue(v) _Static_assert(_Generic(&ct_makevalue_factory(v), struct ct_comparable_value (*)(int, ...): 0, default: 1), "(" #v ") is an invalid value type; use ct_assert[not]same for pointer types, ct_assert[not]equalstr for string types, or custom comparisons with ct_asserttrue/false for structs, unions, and arrays.")

/**
 Mark a test as ignored.
 To prevent possible side-effects add this assertion as the first line of the test.
 Intended for internal use only.
 @see ct_ignore
 @param format The printf-style format string to display when the test is ignored.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_internal_ignore(const char *, ...);

/**
 Assert failure unconditionally with contextual details and message.
 Intended for internal use only.
 @see ct_assertfail
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_internal_assertfail(const char *, int, const char *, ...);

/**
 Assert whether the expression is true, with contextual details and message.
 Intended for internal use only.
 @see ct_asserttrue
 @param expression The expression to evaluate against the value true.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_asserttrue(_Bool, const char *, const char *, int, const char *, ...);

/**
 Assert whether the expression is false, with contextual details and message.
 Intended for internal use only.
 @see ct_assertfalse
 @param expression The expression to evaluate against the value false.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertfalse(_Bool, const char *, const char *, int, const char *, ...);

/**
 Assert whether the expression is NULL, with contextual details and message.
 Intended for internal use only.
 @see ct_assertnull
 @param expression The expression to evaluate against the value NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnull(const void *, const char *, const char *, int, const char *, ...);

/**
 Assert whether the expression is not NULL, with contextual details and message.
 Intended for internal use only.
 @see ct_assertnotnull
 @param expression The expression to evaluate against the value !NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotnull(const void *, const char *, const char *, int, const char *, ...);

/**
 Assert whether two values are equal, with contextual details and message.
 Intended for internal use only.
 @see ct_assertequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertequal(struct ct_comparable_value, const char *, struct ct_comparable_value, const char *, const char *, int, const char *, ...);

/**
 Assert whether two values are not equal, with contextual details and message.
 Intended for internal use only.
 @see ct_assertnotequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotequal(struct ct_comparable_value, const char *, struct ct_comparable_value, const char *, const char *, int, const char *, ...);

/**
 Assert whether two values are equal within plus or minus a degree of error, with contextual details and message.
 Intended for internal use only.
 @see ct_assertaboutequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param precision The range of precision within which expected and actual may be considered equal.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertaboutequal(long double, const char *, long double, const char *, long double, const char *, int, const char *, ...);

/**
 Assert whether two values are not equal within plus or minus a degree of error, with contextual details and message.
 Intended for internal use only.
 @see ct_assertnotaboutequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value expression.
 @param precision The range of precision within which expected and actual may be considered not equal.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotaboutequal(long double, const char *, long double, const char *, long double, const char *, int, const char *, ...);

/**
 Assert whether two pointers refer to the same object, with contextual details and message.
 Intended for internal use only.
 @see ct_assertsame
 @param expected The expected pointer.
 @param stringized_expected The string representation of the expected pointer expression.
 @param actual The actual pointer.
 @param stringized_actual The string representation of the actual pointer expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertsame(const void *, const char *, const void *, const char *, const char *, int, const char *, ...);

/**
 Assert whether two pointers refer to different objects, with contextual details and message.
 Intended for internal use only.
 @see ct_assertsame
 @param expected The expected pointer.
 @param stringized_expected The string representation of the expected pointer expression.
 @param actual The actual pointer.
 @param stringized_actual The string representation of the actual pointer expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotsame(const void *, const char *, const void *, const char *, const char *, int, const char *, ...);

/**
 Assert whether two strings are equal, with contextual details and message.
 Intended for internal use only.
 @see ct_assertequalstr
 @see ct_assertequalstrn
 @param expected The expected string.
 @param stringized_expected The string representation of the expected string expression.
 @param actual The actual string.
 @param stringized_actual The string representation of the actual string expression.
 @param n The maximum number of characters to compare for equality. Must not be greater than the size of expected.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertequalstrn(const char *, const char *, const char *, const char *, size_t, const char *, int, const char *, ...);

/**
 Assert whether two strings are not equal, with contextual details and message.
 Intended for internal use only.
 @see ct_assertequalstr
 @see ct_assertequalstrn
 @param expected The expected string.
 @param stringized_expected The string representation of the expected string expression.
 @param actual The actual string.
 @param stringized_actual The string representation of the actual string expression.
 @param n The maximum number of characters to compare for inequality. Must not be greater than the size of expected.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotequalstrn(const char *, const char *, const char *, const char *, size_t, const char *, int, const char *, ...);

/**
 @}
 */

#endif
