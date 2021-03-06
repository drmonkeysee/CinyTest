//
//  CTAssertEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTEqualAssertionTestBase.h"

#include "ciny.h"

#include <complex.h>
#include <float.h>
#include <limits.h>
#include <stddef.h>

@interface CTAssertEqualTests : CTEqualAssertionTestBase

@end

static void equality_test(void *context)
{
    CTAssertEqualTests *testObject =
        (__bridge CTAssertEqualTests *)(TestClass);

    testObject.invokedTest = YES;

    switch (testObject.expectedType) {
    case TAT_SCHAR:
    case TAT_SHORT:
    case TAT_INT:
    case TAT_LONG:
    case TAT_LONG_LONG:
    case TAT_SMAX:
        switch (testObject.actualType) {
        case TAT_SCHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
        case TAT_SMAX:
            ct_assertequal(get_integer_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_integer_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        case TAT_BOOL:
        case TAT_UCHAR:
        case TAT_USHORT:
        case TAT_UINT:
        case TAT_ULONG:
        case TAT_ULONG_LONG:
        case TAT_UMAX:
            ct_assertequal(get_integer_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_uinteger_test_arg(testObject.actualType,
                                                 ARG_ACTUAL));
            break;
        case TAT_FLOAT:
        case TAT_DOUBLE:
        case TAT_LDOUBLE:
            ct_assertequal(get_integer_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_float_test_arg(testObject.actualType,
                                              ARG_ACTUAL));
            break;
        case TAT_FCOMPLEX:
        case TAT_COMPLEX:
        case TAT_LCOMPLEX:
            ct_assertequal(get_integer_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_complex_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        }
        break;
    case TAT_BOOL:
    case TAT_UCHAR:
    case TAT_USHORT:
    case TAT_UINT:
    case TAT_ULONG:
    case TAT_ULONG_LONG:
    case TAT_UMAX:
        switch (testObject.actualType) {
        case TAT_SCHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
        case TAT_SMAX:
            ct_assertequal(get_uinteger_test_arg(testObject.expectedType,
                                                 ARG_EXPECTED),
                           get_integer_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        case TAT_BOOL:
        case TAT_UCHAR:
        case TAT_USHORT:
        case TAT_UINT:
        case TAT_ULONG:
        case TAT_ULONG_LONG:
        case TAT_UMAX:
            ct_assertequal(get_uinteger_test_arg(testObject.expectedType,
                                                 ARG_EXPECTED),
                           get_uinteger_test_arg(testObject.actualType,
                                                 ARG_ACTUAL));
            break;
        case TAT_FLOAT:
        case TAT_DOUBLE:
        case TAT_LDOUBLE:
            ct_assertequal(get_uinteger_test_arg(testObject.expectedType,
                                                 ARG_EXPECTED),
                           get_float_test_arg(testObject.actualType,
                                              ARG_ACTUAL));
            break;
        case TAT_FCOMPLEX:
        case TAT_COMPLEX:
        case TAT_LCOMPLEX:
            ct_assertequal(get_uinteger_test_arg(testObject.expectedType,
                                                 ARG_EXPECTED),
                           get_complex_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        }
        break;
    case TAT_FLOAT:
    case TAT_DOUBLE:
    case TAT_LDOUBLE:
        switch (testObject.actualType) {
        case TAT_SCHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
        case TAT_SMAX:
            ct_assertequal(get_float_test_arg(testObject.expectedType,
                                              ARG_EXPECTED),
                           get_integer_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        case TAT_BOOL:
        case TAT_UCHAR:
        case TAT_USHORT:
        case TAT_UINT:
        case TAT_ULONG:
        case TAT_ULONG_LONG:
        case TAT_UMAX:
            ct_assertequal(get_float_test_arg(testObject.expectedType,
                                              ARG_EXPECTED),
                           get_uinteger_test_arg(testObject.actualType,
                                                 ARG_ACTUAL));
            break;
        case TAT_FLOAT:
        case TAT_DOUBLE:
        case TAT_LDOUBLE:
            ct_assertequal(get_float_test_arg(testObject.expectedType,
                                              ARG_EXPECTED),
                           get_float_test_arg(testObject.actualType,
                                              ARG_ACTUAL));
            break;
        case TAT_FCOMPLEX:
        case TAT_COMPLEX:
        case TAT_LCOMPLEX:
            ct_assertequal(get_float_test_arg(testObject.expectedType,
                                              ARG_EXPECTED),
                           get_complex_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        }
        break;
    case TAT_FCOMPLEX:
    case TAT_COMPLEX:
    case TAT_LCOMPLEX:
        switch (testObject.actualType) {
        case TAT_SCHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
        case TAT_SMAX:
            ct_assertequal(get_complex_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_integer_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        case TAT_BOOL:
        case TAT_UCHAR:
        case TAT_USHORT:
        case TAT_UINT:
        case TAT_ULONG:
        case TAT_ULONG_LONG:
        case TAT_UMAX:
            ct_assertequal(get_complex_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_uinteger_test_arg(testObject.actualType,
                                                 ARG_ACTUAL));
            break;
        case TAT_FLOAT:
        case TAT_DOUBLE:
        case TAT_LDOUBLE:
            ct_assertequal(get_complex_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_float_test_arg(testObject.actualType,
                                              ARG_ACTUAL));
            break;
        case TAT_FCOMPLEX:
        case TAT_COMPLEX:
        case TAT_LCOMPLEX:
            ct_assertequal(get_complex_test_arg(testObject.expectedType,
                                                ARG_EXPECTED),
                           get_complex_test_arg(testObject.actualType,
                                                ARG_ACTUAL));
            break;
        }
        break;
    }

    testObject.sawPostAssertCode = YES;
}

static void equality_test_withmessage(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);

    testObject.invokedTest = YES;

    ct_assertequal(10, 20, "Oh dear, an inequality message!");

    testObject.sawPostAssertCode = YES;
}

static void equality_test_withformatmessage(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);

    testObject.invokedTest = YES;

    int e = -9, i = 5;

    ct_assertequal(e, i, "Turns out %d is not equal to %d", e, i);

    testObject.sawPostAssertCode = YES;
}

static void equality_test_withtypevariants(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);

    testObject.invokedTest = YES;

    const int ci = 10;
    int i = 10;

    ct_assertequal(ci, i, "const ints and ints should be equal");

    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertEqualTests

#pragma mark - Integer Equality

- (void)test_ctassertequal_ComparesEqual_IfSameIntegerTypes
{
    i_values[ARG_EXPECTED] = 34503;
    i_values[ARG_ACTUAL] = 34503;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentIntegerTypes
{
    sc_values[ARG_EXPECTED] = 42;
    ll_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_SCHAR;
    self.actualType = TAT_LONG_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeIntegerValues
{
    i_values[ARG_EXPECTED] = -5673;
    i_values[ARG_ACTUAL] = -5673;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeIntegerValuesWithDifferentTypes
{
    s_values[ARG_EXPECTED] = -5673;
    l_values[ARG_ACTUAL] = -5673;
    self.expectedType = TAT_SHORT;
    self.actualType = TAT_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroIntegerValues
{
    i_values[ARG_EXPECTED] = 0;
    i_values[ARG_ACTUAL] = 0;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroIntegerValuesWithDifferentTypes
{
    sc_values[ARG_EXPECTED] = 0;
    s_values[ARG_ACTUAL] = 0;
    self.expectedType = TAT_SCHAR;
    self.actualType = TAT_SHORT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestIntegerValue
{
    ll_values[ARG_EXPECTED] = LLONG_MAX;
    ll_values[ARG_ACTUAL] = LLONG_MAX;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfMaxIntegerValue
{
    smx_values[ARG_EXPECTED] = INTMAX_MAX;
    smx_values[ARG_ACTUAL] = INTMAX_MAX;
    self.expectedType = TAT_SMAX;
    self.actualType = TAT_SMAX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestIntegerValue
{
    ll_values[ARG_EXPECTED] = LLONG_MIN;
    ll_values[ARG_ACTUAL] = LLONG_MIN;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfMinIntegerValue
{
    smx_values[ARG_EXPECTED] = INTMAX_MIN;
    smx_values[ARG_ACTUAL] = INTMAX_MIN;
    self.expectedType = TAT_SMAX;
    self.actualType = TAT_SMAX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentIntegerValues
{
    i_values[ARG_EXPECTED] = 560;
    i_values[ARG_ACTUAL] = -346;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentIntegerValuesAndTypes
{
    s_values[ARG_EXPECTED] = 560;
    l_values[ARG_ACTUAL] = -4574234;
    self.expectedType = TAT_SHORT;
    self.actualType = TAT_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxIntegerValues
{
    smx_values[ARG_EXPECTED] = INTMAX_MIN;
    smx_values[ARG_ACTUAL] = INTMAX_MAX;
    self.expectedType = TAT_SMAX;
    self.actualType = TAT_SMAX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Unsigned Integer Equality

- (void)test_ctassertequal_ComparesEqual_IfSameUnsignedIntegerTypes
{
    ui_values[ARG_EXPECTED] = 34503;
    ui_values[ARG_ACTUAL] = 34503;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentUnsignedIntegerTypes
{
    b_values[ARG_EXPECTED] = 1;
    ull_values[ARG_ACTUAL] = 1;
    self.expectedType = TAT_BOOL;
    self.actualType = TAT_ULONG_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroUnsignedIntegerValues
{
    ui_values[ARG_EXPECTED] = 0;
    ui_values[ARG_ACTUAL] = 0;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroUnsignedIntegerValuesWithDifferentTypes
{
    uc_values[ARG_EXPECTED] = 0;
    ul_values[ARG_ACTUAL] = 0;
    self.expectedType = TAT_UCHAR;
    self.actualType = TAT_ULONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestUnsignedIntegerValue
{
    ull_values[ARG_EXPECTED] = ULLONG_MAX;
    ull_values[ARG_ACTUAL] = ULLONG_MAX;
    self.expectedType = TAT_ULONG_LONG;
    self.actualType = TAT_ULONG_LONG;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfMaxUnsignedIntegerValue
{
    umx_values[ARG_EXPECTED] = UINTMAX_MAX;
    umx_values[ARG_ACTUAL] = UINTMAX_MAX;
    self.expectedType = TAT_UMAX;
    self.actualType = TAT_UMAX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentUnsignedIntegerValues
{
    ui_values[ARG_EXPECTED] = 560;
    ui_values[ARG_ACTUAL] = 123467;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentUnsignedIntegerValuesAndTypes
{
    us_values[ARG_EXPECTED] = 560;
    ui_values[ARG_ACTUAL] = 688334;
    self.expectedType = TAT_USHORT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxUnsignedIntegerValues
{
    umx_values[ARG_EXPECTED] = 0;
    umx_values[ARG_ACTUAL] = UINTMAX_MAX;
    self.expectedType = TAT_UMAX;
    self.actualType = TAT_UMAX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Float Equality

- (void)test_ctassertequal_ComparesEqual_IfSameFloatTypes
{
    d_values[ARG_EXPECTED] = 3.7832e21;
    d_values[ARG_ACTUAL] = 3.7832e21;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentFloatTypes
{
    f_values[ARG_EXPECTED] = 7834.0f;
    ld_values[ARG_ACTUAL] = 7834.0l;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeFloatValues
{
    d_values[ARG_EXPECTED] = -56.873201;
    d_values[ARG_ACTUAL] = -56.873201;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeFloatValuesWithDifferentTypes
{
    f_values[ARG_EXPECTED] = -52.0f;
    d_values[ARG_ACTUAL] = -52.0;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroFloatValues
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 0.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroFloatValuesWithDifferentTypes
{
    d_values[ARG_EXPECTED] = 0.0;
    ld_values[ARG_ACTUAL] = 0.0l;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestFloatValue
{
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestFloatValue
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentFloatValues
{
    d_values[ARG_EXPECTED] = 67.34;
    d_values[ARG_ACTUAL] = -902.435;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentFloatValuesAndTypes
{
    f_values[ARG_EXPECTED] = 560.093f;
    ld_values[ARG_ACTUAL] = -4574234e10l;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxFloatValues
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Complex Equality

- (void)test_ctassertequal_ComparesEqual_IfSameComplexTypes
{
    dc_values[ARG_EXPECTED] = CMPLX(5.762, 3.462);
    dc_values[ARG_ACTUAL] = CMPLX(5.762, 3.462);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentComplexTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(82.0f, 12.0f);
    ldc_values[ARG_ACTUAL] = CMPLXL(82.0l, 12.0l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(-67.345, -23e10);
    dc_values[ARG_ACTUAL] = CMPLX(-67.345, -23e10);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeComplexValuesWithDifferentTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(-23.0f, -6.0f);
    dc_values[ARG_ACTUAL] = CMPLXL(-23.0, -6.0);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(0.0, 0.0);
    dc_values[ARG_ACTUAL] = CMPLX(0.0, 0.0);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroComplexValuesWithDifferentTypes
{
    dc_values[ARG_EXPECTED] = CMPLX(0.0, 0.0);
    ldc_values[ARG_ACTUAL] = CMPLXL(0.0l, 0.0l);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestComplexValue
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MAX, LDBL_MAX);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MAX, LDBL_MAX);
    self.expectedType = TAT_LCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestComplexValue
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MIN, LDBL_MIN);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MIN, LDBL_MIN);
    self.expectedType = TAT_LCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(56.0234, 1.903);
    dc_values[ARG_ACTUAL] = CMPLX(87.34, 5.09);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexRealValues
{
    dc_values[ARG_EXPECTED] = CMPLX(56.0234, 20.5);
    dc_values[ARG_ACTUAL] = CMPLX(87.34, 20.5);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexImaginaryValues
{
    dc_values[ARG_EXPECTED] = CMPLX(76.98, 1.903);
    dc_values[ARG_ACTUAL] = CMPLX(76.98, 5.09);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(30.23f, 10e5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(-9.7l, 0.456l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexRealValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(30.23f, 2.5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(-9.7l, 2.5l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexImaginaryValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(45.0f, 10e5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(45.0l, 0.456l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxComplexValues
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MIN, LDBL_MIN);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MAX, LDBL_MAX);
    self.expectedType = TAT_LCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Type Inequality

- (void)test_ctassertequal_ComparesNotEqual_IfIntegerAndUIntegerTypes
{
    i_values[ARG_EXPECTED] = 20;
    ui_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_INT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegerAndFloatTypes
{
    i_values[ARG_EXPECTED] = 20;
    d_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_INT;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegerAndComplexTypes
{
    i_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_INT;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegerAndFloatTypes
{
    ui_values[ARG_EXPECTED] = 20;
    d_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_DOUBLE;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegerAndComplexTypes
{
    ui_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_UINT;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfFloatAndComplexTypes
{
    d_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_COMPLEX;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Bit Pattern Inequality

- (void)test_ctassertequal_ComparesNotEqual_IfIntegerAndUIntegerIdenticalBitPattern
{
    _Static_assert(sizeof(int) == sizeof(unsigned int), "int and uint not equal sizes; this test needs to be adjusted to use different types");
    i_values[ARG_EXPECTED] = -1046478848;
    ui_values[ARG_ACTUAL] = 3248488448;
    self.expectedType = TAT_INT;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegerAndFloatIdenticalBitPattern
{
    _Static_assert(sizeof(int) == sizeof(float), "int and float not equal sizes; this test needs to be adjusted to use different types");
    i_values[ARG_EXPECTED] = -1046478848;
    f_values[ARG_ACTUAL] = -2.0e1f;
    self.expectedType = TAT_INT;
    self.actualType = TAT_FLOAT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegerAndFloatIdenticalBitPattern
{
    _Static_assert(sizeof(unsigned int) == sizeof(float), "uint and float not equal sizes; this test needs to be adjusted to use different types");
    ui_values[ARG_EXPECTED] = 3248488448;
    f_values[ARG_ACTUAL] = -2.0e1f;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_FLOAT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Messages

- (void)test_ctassertequal_FiresAssertion_WithCustomMessage
{
    const struct ct_testcase tests[] = {ct_maketest(equality_test_withmessage)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

- (void)test_ctassertequal_FiresAssertion_WithCustomFormatMessage
{
    const struct ct_testcase tests[] = {ct_maketest(equality_test_withformatmessage)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    failed_assertion_expected(run_result);
}

#pragma mark - Type variants

- (void)test_ctassertequal_ComparesEqual_WithTypeVariants
{
    const struct ct_testcase tests[] = {ct_maketest(equality_test_withtypevariants)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

#pragma mark - Char

- (void)test_ctassertequal_ComparesEqual_IfCharTypes
{
    c_values[ARG_EXPECTED] = 42;
    c_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_CHAR;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    successful_assertion_expected(run_result);
}

- (void)test_ctassertequal_ComparesEqual_IfCharAndIntegerType
{
    c_values[ARG_EXPECTED] = 42;
    i_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_INT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    XCTAssertEqual(0u, run_result, "Test unexpectedly failed - possibly compiled with unsigned char option?");
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfCharAndUIntegerTypes
{
    c_values[ARG_EXPECTED] = 20;
    ui_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_UINT;
    const struct ct_testcase tests[] = {ct_maketest(equality_test)};
    const struct ct_testsuite suite = ct_makesuite(tests);

    const size_t run_result = ct_runsuite(&suite);

    XCTAssertEqual(1u, run_result, "Test unexpectedly passed - possibly compiled with unsigned char option?");
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
