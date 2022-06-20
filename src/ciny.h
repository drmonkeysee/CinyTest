//
//  ciny.h
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#ifndef CinyTest_ciny_h
#define CinyTest_ciny_h

#include <limits.h>
#include <stddef.h>
#include <stdint.h>

/**
 @file
 CinyTest type and function definitions.
 */

/**
 @defgroup public Public types and functions
 The public API for CinyTest.
 Guaranteed to be stable within a major version.
 @{
 */

/**
 A semantic version structure.
 */
struct ct_version {
    uint8_t major,  /**< The major part. */
            minor,  /**< The minor part. */
            patch;  /**< The patch part. */
};
/**
 Get the current version of CinyTest as a semantic version structure.
 @return Version structure populated with the current version.
 */
inline struct ct_version ct_getversion(void)
{
    return (struct ct_version){9, 0, 6};
}
/**
 Convert a semantic verson to hexadecimal form for easy numeric comparisons.
 The upper byte is always zero followed by MAJOR, MINOR, then PATCH.
 @param version The semantic version structure to convert to a number.
 @return A numeric representation of the version.
 */
inline uint32_t ct_versionhex(const struct ct_version *version)
{
    return 0 | version->major << 16 | version->minor << 8 | version->patch;
}

/**
 Type definition for a unit test function.
 @param context Test context created in a suite's setup function.
 */
typedef void ct_test_function(void *);

/**
 Type definition for a unit test setup or teardown function.
 @param context Non-null pointer to a test context for initialization
 or destruction.
 The test context will be passed to all unit tests for a given suite.
 */
typedef void ct_setupteardown_function(void **);

/**
 A test case.
 A named function that executes a single unit test.
 */
struct ct_testcase {
    const char *name;       /**< The function name of the test. */
    ct_test_function *test; /**< The test function. */
};

/**
 Make a test case.
 Uses the name of the unit test function as the name of the test case.
 @param test The unit test function for the test case.
 @return A test case.
 */
#define ct_maketest(test) ct_maketest_named(#test, test)
/**
 Make a test case with a name.
 Implemented as a macro to allow use as a static initializer.
 @param name The name of the test case.
 @param test The unit test function for the test case.
 @return A test case.
 */
#define ct_maketest_named(name, test) (struct ct_testcase){name, test}

/**
 A test suite.
 A named collection of test cases with optional setup and teardown functions.
 */
struct ct_testsuite {
    const char *name;                   /**< The name of the test suite. */
    size_t count;                       /**< The number of tests to be run. */
    const struct ct_testcase *tests;    /**< The collection of tests to run. */
    ct_setupteardown_function
        *setup,                         /**< The test setup function. Runs before each test case. May be NULL. */
        *teardown;                      /**< The test teardown function. Runs after each test case. May be NULL. */
};

/**
 Make a test suite for the list of tests.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list must be an
 array value.
 @return A test suite.
 */
#define ct_makesuite(test_list) ct_makesuite_setup(test_list, NULL)
/**
 Make a test suite with a setup function.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list must be an
 array value.
 @param setup_function The setup function. Runs before each test case.
 @return A test suite.
 */
#define ct_makesuite_setup(test_list, setup_function) \
ct_makesuite_setup_teardown(test_list, setup_function, NULL)
/**
 Make a test suite with a setup and teardown function.
 Uses the enclosing function as the test suite name.
 @param test_list The list of tests to run.
 The size of the test array is calculated inline so test_list must be an
 array value.
 @param setup_function The setup function. Runs before each test case.
 @param teardown_function The teardown function. Runs after each test case.
 @return A test suite.
 */
#define ct_makesuite_setup_teardown(test_list, setup_function, \
                                    teardown_function) \
ct_makesuite_setup_teardown_named(__func__, \
                                  sizeof (test_list) / sizeof (test_list)[0], \
                                  test_list, setup_function, teardown_function)
/**
 Make a test suite with a setup function, teardown function, and a name.
 @param name The name of the test suite.
 @param count The number of test cases.
 @param tests The collection of test cases.
 @param setup The setup function. Runs before each test case. Can be NULL.
 @param teardown The teardown function. Runs after each test case. Can be NULL.
 @return A test suite.
 */
inline struct ct_testsuite
    ct_makesuite_setup_teardown_named(const char *name, size_t count,
                                      const struct ct_testcase tests[count],
                                      ct_setupteardown_function *setup,
                                      ct_setupteardown_function *teardown)
{
    return (struct ct_testsuite){name, count, tests, setup, teardown};
}

/**
 Run multiple unit test suites.
 @param suites The test suites to run.
 The size of the test suites array is calculated inline so suites must be an
 array value.
 @return The total number of failed tests.
 */
#define ct_run(suites) ct_run_withargs(suites, 0, NULL)
/**
 Run multiple unit test suites with command line arguments.
 @param suites The test suites to run.
 The size of the test suites array is calculated inline so suites must be an
 array value.
 @param argc The command line argument count.
 @param argv The command line argument strings.
 @return The total number of failed tests.
 */
#define ct_run_withargs(suites, argc, argv) \
ct_runcount_withargs(sizeof (suites) / sizeof (suites)[0], suites, argc, argv)
/**
 Run unit test suites with count and command line arguments.
 The command line arguments are mutable to match the signature of main but are guaranteed
 not to be mutated by this function.
 @param count The number of test suites.
 @param suites The test suites to run.
 @param argc The command line argument count.
 @param argv The command line argument strings.
 @return The total number of failed tests.
 */
size_t ct_runcount_withargs(size_t count,
                            const struct ct_testsuite suites[count],
                            int argc, char *argv[argc+1]);

/**
 Run a unit test suite with command line arguments.
 The command line arguments are mutable to match the signature of main but are guaranteed
 not to be mutated by this function.
 @param suite The test suite to run.
 @param argc The command line argument count.
 @param argv The command line argument strings.
 @return The number of failed tests.
 */
inline size_t ct_runsuite_withargs(const struct ct_testsuite *suite,
                                   int argc, char *argv[argc+1])
{
    return ct_runcount_withargs(1, suite, argc, argv);
}

/**
 Run a unit test suite.
 @param suite The test suite to run.
 @return The number of failed tests.
 */
inline size_t ct_runsuite(const struct ct_testsuite *suite)
{
    return ct_runsuite_withargs(suite, 0, NULL);
}

/**
 Mark a test as ignored.
 To prevent unnecessary test execution this assertion should be the first
 statement of the test function.
 @param message A printf-style format string literal with optional arguments
 to display when the test is ignored.
 */
#define ct_ignore(...) \
ct_internal_ignore(ct_va_string(__VA_ARGS__), ct_va_rest(__VA_ARGS__))

/**
 Assert failure unconditionally.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertfail(...) \
ct_internal_assertfail(__FILE__, __LINE__, ct_va_string(__VA_ARGS__), \
                       ct_va_rest(__VA_ARGS__))

/**
 Assert whether an expression is true.
 @param expression The expression to evaluate against the value true.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_asserttrue(expression, ...) \
ct_internal_asserttrue(expression, #expression, __FILE__, __LINE__, \
                       ct_va_string(__VA_ARGS__), ct_va_rest(__VA_ARGS__))
/**
 Assert whether an expression is false.
 @param expression The expression to evaluate against the value false.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertfalse(expression, ...) \
ct_internal_assertfalse(expression, #expression, __FILE__, __LINE__, \
                        ct_va_string(__VA_ARGS__), ct_va_rest(__VA_ARGS__))

/**
 Assert whether an expression is NULL.
 @param expression The expression to evaluate against the value NULL.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnull(expression, ...) \
ct_internal_assertnull(expression, #expression, __FILE__, __LINE__, \
                       ct_va_string(__VA_ARGS__), ct_va_rest(__VA_ARGS__))
/**
 Assert whether an expression is not NULL.
 @param expression The expression to evaluate against the value !NULL.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotnull(expression, ...) \
ct_internal_assertnotnull(expression, #expression, __FILE__, __LINE__, \
                          ct_va_string(__VA_ARGS__), ct_va_rest(__VA_ARGS__))

/**
 Assert whether two values are equal.
 Compares any two basic value types but does not handle pointers, structs,
 unions, arrays, or function pointers.
 @see ct_assertsame for pointer equality.
 @see ct_assertequalstr for string equality.
 @param expected The expected value.
 @param actual The actual value.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertequal(expected, actual, ...) \
do { \
    ct_checkvalue(expected); \
    ct_checkvalue(actual); \
    ct_internal_assertequal(ct_makevalue(expected), #expected, \
                            ct_makevalue(actual), #actual, __FILE__, \
                            __LINE__, ct_va_string(__VA_ARGS__), \
                            ct_va_rest(__VA_ARGS__)); \
} while (0)
/**
 Assert whether two values are not equal.
 Compares any two basic value types but does not handle pointers, structs,
 unions, arrays, or function pointers.
 @see ct_assertnotsame for pointer equality.
 @see ct_assertnotequalstr for string equality.
 @param expected The expected value.
 @param actual The actual value.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotequal(expected, actual, ...) \
do { \
    ct_checkvalue(expected); \
    ct_checkvalue(actual); \
    ct_internal_assertnotequal(ct_makevalue(expected), #expected, \
                               ct_makevalue(actual), #actual, __FILE__, \
                               __LINE__, ct_va_string(__VA_ARGS__), \
                               ct_va_rest(__VA_ARGS__)); \
} while (0)

/**
 Assert whether two floating point values are equal within plus or minus
 a degree of error.
 @param expected The expected value.
 @param actual The actual value.
 @param precision The range of precision within which expected and actual
 may be considered equal.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertaboutequal(expected, actual, precision, ...) \
ct_internal_assertaboutequal(expected, #expected, actual, #actual, \
                             precision, __FILE__, __LINE__, \
                             ct_va_string(__VA_ARGS__), \
                             ct_va_rest(__VA_ARGS__))
/**
 Assert whether two floating point values are not equal within plus or minus
 a degree of error.
 @param expected The expected value.
 @param actual The actual value.
 @param precision The range of precision within which expected and actual
 may be considered not equal.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotaboutequal(expected, actual, precision, ...) \
ct_internal_assertnotaboutequal(expected, #expected, actual, #actual, \
                                precision, __FILE__, __LINE__, \
                                ct_va_string(__VA_ARGS__), \
                                ct_va_rest(__VA_ARGS__))

/**
 Assert whether two pointers refer to the same object.
 @param expected The expected pointer.
 @param actual The actual pointer.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertsame(expected, actual, ...) \
ct_internal_assertsame(expected, #expected, actual, #actual, __FILE__, \
                       __LINE__, ct_va_string(__VA_ARGS__), \
                       ct_va_rest(__VA_ARGS__))
/**
 Assert whether two pointers refer to different objects.
 @param expected The expected pointer.
 @param actual The actual pointer.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotsame(expected, actual, ...) \
ct_internal_assertnotsame(expected, #expected, actual, #actual, __FILE__, \
                          __LINE__, ct_va_string(__VA_ARGS__), \
                          ct_va_rest(__VA_ARGS__))

/**
 Assert whether two strings are equal.
 The first argument is a string literal used to automatically determine
 the number of characters to compare.
 If the first argument cannot be a string literal @see ct_assertequalstrn.
 @param expected The expected string. Must be a string literal expression.
 @param actual The actual string.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertequalstr(expected, actual, ...) \
ct_internal_assertequalstrn("" expected "", #expected, actual, #actual, \
                            sizeof (expected), __FILE__, __LINE__, \
                            ct_va_string(__VA_ARGS__), \
                            ct_va_rest(__VA_ARGS__))
/**
 Assert whether two strings are equal.
 Compares up to n characters for equality.
 @param expected The expected string.
 @param actual The actual string.
 @param n The maximum number of characters to compare for equality. Must not
 be greater than the size of expected.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertequalstrn(expected, actual, n, ...) \
ct_internal_assertequalstrn(expected, #expected, actual, #actual, n, \
                            __FILE__, __LINE__, ct_va_string(__VA_ARGS__), \
                            ct_va_rest(__VA_ARGS__))
/**
 Assert whether two strings are not equal.
 The first argument is a string literal used to automatically determine
 the number of characters to compare.
 If the first argument cannot be a string literal @see ct_assertnotequalstrn.
 @param expected The expected string. Must be a string literal expression.
 @param actual The actual string.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotequalstr(expected, actual, ...) \
ct_internal_assertnotequalstrn("" expected "", #expected, actual, #actual, \
                               sizeof (expected), __FILE__, __LINE__, \
                               ct_va_string(__VA_ARGS__), \
                               ct_va_rest(__VA_ARGS__))
/**
 Assert whether two strings are not equal.
 Compares up to n characters for inequality.
 @param expected The expected string.
 @param actual The actual string.
 @param n The maximum number of characters to compare for inequality. Must not
 be greater than the size of expected.
 @param message A printf-style format string literal with optional arguments
 to display when the assertion fails.
 */
#define ct_assertnotequalstrn(expected, actual, n, ...) \
ct_internal_assertnotequalstrn(expected, #expected, actual, #actual, n, \
                               __FILE__, __LINE__, ct_va_string(__VA_ARGS__), \
                               ct_va_rest(__VA_ARGS__))

/**
 @}
 */

/**
 @defgroup internal Internal types and functions
 Implementation details of CinyTest.
 These functions and types provide a greater degree of control over how
 assertion comparisons are defined and displayed. They are not intended for
 direct use over the public API and may change in the future without revving
 the major version. Regardless, full documentation is provided since they are
 defined in the public header and as long as all parameter constraints are
 observed these functions and types are safe to use.
 @{
 */

/**
 @defgroup compatibility Cross-platform compatibility
 In order to support cross-platform builds for CinyTest some implementation
 details require compatibility shims. These are not intended for direct use
 and are not part of the public API.
 @{
 */
#ifdef _WIN64
#include <complex.h>                        // win types must be visible
typedef _Fcomplex ct_fcomplex;              /**< Float complex number type. */
typedef _Dcomplex ct_complex;               /**< Double complex number type. */
typedef _Lcomplex ct_lcomplex;              /**< Long double complex number type. */
#else
typedef float _Complex ct_fcomplex;         /**< Float complex number type. */
typedef double _Complex ct_complex;         /**< Double complex number type. */
typedef long double _Complex ct_lcomplex;   /**< Long double complex number type. */
#endif
/**
 @}
 */

/**
 Value type annotation.
 An enumeration of possible simple value types used for equality assertions.
 */
enum ct_valuetype_annotation {
    CT_ANNOTATE_INVALID,            /**< Expression did not evaluate to a valid value type. */
    CT_ANNOTATE_INTEGER,            /**< Value is a signed integer type. */
    CT_ANNOTATE_UINTEGER,           /**< Value is an unsigned integer type. */
    CT_ANNOTATE_FLOATINGPOINT,      /**< Value is a floating point type. */
    CT_ANNOTATE_COMPLEX,            /**< Value is a complex number type. */
};
/**
 A comparable value.
 A unified type structure over simple value types to aid in equality assertions.
 */
struct ct_comparable_value {
    union {
        intmax_t integer_value;             /**< Access the value as a signed integer. */
        uintmax_t uinteger_value;           /**< Access the value as an unsigned integer. */
        long double floatingpoint_value;    /**< Access the value as a floating point. */
        ct_lcomplex complex_value;          /**< Access the value as a complex number. */
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
 Select a makevalue function for converting the given value expression
 into a comparable value type.
 @param v The value expression for which to select the comparable value
 creation function.
 @return A function pointer to a typed makevalue function.
 */
#define ct_makevalue_factory(v) \
_Generic(v, \
         signed char:            ct_makevalue_integer, \
         short:                  ct_makevalue_integer, \
         int:                    ct_makevalue_integer, \
         long:                   ct_makevalue_integer, \
         long long:              ct_makevalue_integer, \
         char:                   ct_makevalue_char, \
         _Bool:                  ct_makevalue_uinteger, \
         unsigned char:          ct_makevalue_uinteger, \
         unsigned short:         ct_makevalue_uinteger, \
         unsigned int:           ct_makevalue_uinteger, \
         unsigned long:          ct_makevalue_uinteger, \
         unsigned long long:     ct_makevalue_uinteger, \
         float:                  ct_makevalue_floatingpoint, \
         double:                 ct_makevalue_floatingpoint, \
         long double:            ct_makevalue_floatingpoint, \
         ct_fcomplex:            ct_makevalue_complex, \
         ct_complex:             ct_makevalue_complex, \
         ct_lcomplex:            ct_makevalue_complex, \
         default:                ct_makevalue_invalid)

/**
 Create a char comparable value structure based on whether char is signed
 or unsigned.
 */
#if CHAR_MIN < 0
#define ct_makevalue_char ct_makevalue_integer
#else
#define ct_makevalue_char ct_makevalue_uinteger
#endif
/**
 Create a signed integer comparable value structure.
 @param placeholder An unused parameter to match arity for all makevalue
 functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the signed integer value
 to be converted.
 @return A comparable value structure for the signed integer value.
 */
inline struct ct_comparable_value ct_makevalue_integer(int placeholder,
                                                       intmax_t value)
{
    (void)placeholder;
    return (struct ct_comparable_value){
        .integer_value = value,
        .type = CT_ANNOTATE_INTEGER,
    };
}
/**
 Create an unsigned integer comparable value structure.
 @param placeholder An unused parameter to match arity for all makevalue
 functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the unsigned integer value
 to be converted.
 @return A comparable value structure for the unsigned integer value.
 */
inline struct ct_comparable_value ct_makevalue_uinteger(int placeholder,
                                                        uintmax_t value)
{
    (void)placeholder;
    return (struct ct_comparable_value){
        .uinteger_value = value,
        .type = CT_ANNOTATE_UINTEGER,
    };
}
/**
 Create a floating point comparable value structure.
 @param placeholder An unused parameter to match arity for all makevalue
 functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the floating point value
 to be converted.
 @return A comparable value structure for the floating point value.
 */
inline struct ct_comparable_value ct_makevalue_floatingpoint(int placeholder,
                                                             long double value)
{
    (void)placeholder;
    return (struct ct_comparable_value){
        .floatingpoint_value = value,
        .type = CT_ANNOTATE_FLOATINGPOINT,
    };
}
/**
 Create a complex number comparable value structure.
 @param placeholder An unused parameter to match arity for all makevalue
 functions. May be any value as it is ignored by the function.
 @param value The widest possible expression of the complex number value
 to be converted.
 @return A comparable value structure for the complex number value.
 */
inline struct ct_comparable_value ct_makevalue_complex(int placeholder,
                                                       ct_lcomplex value)
{
    (void)placeholder;
    return (struct ct_comparable_value){
        .complex_value = value,
        .type = CT_ANNOTATE_COMPLEX,
    };
}
/**
 Create a comparable value structure for an expression that cannot be
 converted into a simple value type.
 @param placeholder An unused parameter to allow for a variadic parameter.
 May be any value as it is ignored by the function.
 @param expression The expression that cannot be represented as a comparable
 value structure. Ignored by the function.
 @return An invalid comparable value structure used for checking a mismatched
 equality assertion.
 */
inline struct ct_comparable_value ct_makevalue_invalid(int placeholder, ...)
{
    (void)placeholder;
    return (struct ct_comparable_value){.type = CT_ANNOTATE_INVALID};
}

/**
 Verify whether the expression can be converted into a valid value type.
 Failure raises a static assertion listing the offending expression and
 lists possible remedies.
 @param v The expression to verify as a simple value type.
 */
#define ct_checkvalue(v) \
_Static_assert(_Generic(&ct_makevalue_factory(v), \
                        struct ct_comparable_value (*)(int, ...): 0, \
                        default: 1), \
               "(" #v ") is an invalid value type; use ct_assert[not]same for" \
               " pointer types, ct_assert[not]equalstr for string types, or" \
               " custom comparisons with ct_asserttrue/false for structs," \
               " unions, and arrays.")

/**
 Ensure the first argument of a variadic macro argument list is a string
 literal expression.
 Assumes this call will always be followed by a call to ct_va_rest.
 @see ct_va_rest
 @param va_args The argument list.
 @return The first variadic argument coerced into a printf-style format string.
 The format string assumes consumption of a zero-width integer placeholder
 generated by a paired call to ct_va_rest.
 An empty argument list will generate a format expression consisting only of
 the zero-width integer placeholder.
 */
#define ct_va_string(...) ("" ct_va_head(__VA_ARGS__) "%.d")
/**
 Trim the first argument from a variadic macro argument list.
 Assumes this call will always be preceeded by a call to ct_va_string.
 @see ct_va_string
 @param va_args The argument list.
 @return The rest of the variadic arguments appended with a placeholder zero.
 Assumes the placeholder zero will be consumed by the format string generated
 by ct_va_string.
 An empty argument list will generate a single argument consisting of the
 placeholder zero.
 */
#define ct_va_rest(...) ct_va_tail(__VA_ARGS__, 0)
/**
 Return the first argument of a variadic macro argument list.
 @param head The first argument.
 @param rest The rest of the arguments.
 @return The first argument.
 */
#define ct_va_head(head, ...) head
/**
 Trim the first argument from a variadic macro argument list.
 @param head The first argument.
 @param rest The rest of the arguments.
 @return The rest of the arguments.
 */
#define ct_va_tail(head, ...) __VA_ARGS__

/**
 Mark a test as ignored.
 To prevent unnecessary test execution this assertion should be the first
 statement of the test function.
 @see ct_ignore
 @param format The printf-style format string to display when the test is
 ignored.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_internal_ignore(const char *restrict, ...);

/**
 Assert failure unconditionally with contextual details and message.
 @see ct_assertfail
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the
 assertion fails.
 @param format_args Format arguments for the format string.
 */
_Noreturn void ct_internal_assertfail(const char *restrict, int,
                                      const char *restrict, ...);

/**
 Assert whether the expression is true, with contextual details and message.
 @see ct_asserttrue
 @param expression The expression to evaluate against the value true.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_asserttrue(_Bool, const char *, const char *restrict, int,
                            const char *restrict, ...);

/**
 Assert whether the expression is false, with contextual details and message.
 @see ct_assertfalse
 @param expression The expression to evaluate against the value false.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertfalse(_Bool, const char *, const char *restrict, int,
                             const char *restrict, ...);

/**
 Assert whether the expression is NULL, with contextual details and message.
 @see ct_assertnull
 @param expression The expression to evaluate against the value NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnull(const void *restrict, const char *,
                            const char *restrict, int, const char *restrict,
                            ...);

/**
 Assert whether the expression is not NULL, with contextual details and
 message.
 @see ct_assertnotnull
 @param expression The expression to evaluate against the value !NULL.
 @param stringized_expression The string representation of the expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotnull(const void *restrict, const char *,
                               const char *restrict, int, const char *restrict,
                               ...);

/**
 Assert whether two values are equal, with contextual details and message.
 @see ct_assertequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value
 expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value
 expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertequal(struct ct_comparable_value, const char *,
                             struct ct_comparable_value, const char *,
                             const char *restrict, int, const char *restrict,
                             ...);

/**
 Assert whether two values are not equal, with contextual details and message.
 @see ct_assertnotequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value
 expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value
 expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotequal(struct ct_comparable_value, const char *,
                                struct ct_comparable_value, const char *,
                                const char *restrict, int,
                                const char *restrict, ...);

/**
 Assert whether two floating point values are equal within plus or minus
 a degree of error, with contextual details and message.
 @see ct_assertaboutequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value
 expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value
 expression.
 @param precision The range of precision within which expected and actual may
 be considered equal.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertaboutequal(long double, const char *, long double,
                                  const char *, long double,
                                  const char *restrict, int,
                                  const char *restrict, ...);

/**
 Assert whether two floating point values are not equal within plus or minus
 a degree of error, with contextual details and message.
 @see ct_assertnotaboutequal
 @param expected The expected value.
 @param stringized_expected The string representation of the expected value
 expression.
 @param actual The actual value.
 @param stringized_actual The string representation of the actual value
 expression.
 @param precision The range of precision within which expected and actual may
 be considered not equal.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotaboutequal(long double, const char *, long double,
                                     const char *, long double,
                                     const char *restrict, int,
                                     const char *restrict, ...);

/**
 Assert whether two pointers refer to the same object, with contextual
 details and message.
 @see ct_assertsame
 @param expected The expected pointer.
 @param stringized_expected The string representation of the expected pointer
 expression.
 @param actual The actual pointer.
 @param stringized_actual The string representation of the actual pointer
 expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertsame(const void *, const char *, const void *,
                            const char *, const char *restrict, int,
                            const char *restrict, ...);

/**
 Assert whether two pointers refer to different objects, with contextual
 details and message.
 @see ct_assertnotsame
 @param expected The expected pointer.
 @param stringized_expected The string representation of the expected pointer
 expression.
 @param actual The actual pointer.
 @param stringized_actual The string representation of the actual pointer
 expression.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotsame(const void *, const char *, const void *,
                               const char *, const char *restrict, int,
                               const char *restrict, ...);

/**
 Assert whether two strings are equal, with contextual details and message.
 @see ct_assertequalstr
 @see ct_assertequalstrn
 @param expected The expected string.
 @param stringized_expected The string representation of the expected string
 expression.
 @param actual The actual string.
 @param stringized_actual The string representation of the actual string
 expression.
 @param n The maximum number of characters to compare for equality. Must not
 be greater than the size of expected.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertequalstrn(const char *, const char *, const char *,
                                 const char *, size_t, const char *restrict,
                                 int, const char *restrict, ...);

/**
 Assert whether two strings are not equal, with contextual details and message.
 @see ct_assertnotequalstr
 @see ct_assertnotequalstrn
 @param expected The expected string.
 @param stringized_expected The string representation of the expected string
 expression.
 @param actual The actual string.
 @param stringized_actual The string representation of the actual string
 expression.
 @param n The maximum number of characters to compare for inequality. Must not
 be greater than the size of expected.
 @param file The name of the file in which the assert fired.
 @param line The line number on which the assert fired.
 @param format The printf-style format string to display when the assertion
 fails.
 @param format_args Format arguments for the format string.
 */
void ct_internal_assertnotequalstrn(const char *, const char *, const char *,
                                    const char *, size_t, const char *restrict,
                                    int, const char *restrict, ...);

/**
 @}
 */

#endif
