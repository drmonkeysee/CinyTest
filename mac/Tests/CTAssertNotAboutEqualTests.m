//
//  CTAssertNotAboutEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 7/4/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAboutEqualAssertionTestBase.h"
#include <float.h>
#include <math.h>
#include <stddef.h>
#include "ciny.h"

@interface CTAssertNotAboutEqualTests : CTAboutEqualAssertionTestBase

@end

static void notabout_equality_test(void *context)
{
    CTAssertNotAboutEqualTests *testObject = (__bridge CTAssertNotAboutEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotaboutequal(get_test_arg(testObject.expectedType, ARG_EXPECTED), get_test_arg(testObject.actualType, ARG_ACTUAL), get_test_arg(testObject.precisionType, ARG_PRECISION));
    
    testObject.sawPostAssertCode = YES;
}

static void notabout_equality_test_withmessage(void *context)
{
    CTAssertNotAboutEqualTests *testObject = (__bridge CTAssertNotAboutEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotaboutequal(10.5, 10.2, 0.5, "Too close!");
    
    testObject.sawPostAssertCode = YES;
}

static void notabout_equality_test_withformatmessage(void *context)
{
    CTAssertNotAboutEqualTests *testObject = (__bridge CTAssertNotAboutEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotaboutequal(10.5, 10.2, 0.5, "%f is too much like %f", 10.5, 10.2);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNotAboutEqualTests

#pragma mark - Equal

- (void)test_ctnotaboutequal_ComparesEqual_IfEqualValues
{
    ad_values[ARG_EXPECTED] = 4.5;
    ad_values[ARG_ACTUAL] = 4.5;
    ad_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfWithinPrecision
{
    ad_values[ARG_EXPECTED] = 4.5;
    ad_values[ARG_ACTUAL] = 4.3;
    ad_values[ARG_PRECISION] = 0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfExactlyOnPrecision
{
    ad_values[ARG_EXPECTED] = 4.5;
    ad_values[ARG_ACTUAL] = 4.51;
    ad_values[ARG_PRECISION] = 0.01;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfNegativePrecision
{
    ad_values[ARG_EXPECTED] = 4.5;
    ad_values[ARG_ACTUAL] = 4.3;
    ad_values[ARG_PRECISION] = -0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfPrecisionIsGreaterThanValues
{
    ad_values[ARG_EXPECTED] = 1.5;
    ad_values[ARG_ACTUAL] = 2.3;
    ad_values[ARG_PRECISION] = 3.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfDifferentWidthsAndBigEnoughPrecision
{
    af_values[ARG_EXPECTED] = 34.235f;
    ald_values[ARG_ACTUAL] = 34.246l;
    ad_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_ForFloats
{
    af_values[ARG_EXPECTED] = 0.82f;
    af_values[ARG_ACTUAL] = 0.78f;
    af_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_ForLongDoubles
{
    ald_values[ARG_EXPECTED] = 0.82l;
    ald_values[ARG_ACTUAL] = 0.78l;
    ald_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithNegativeValues
{
    ad_values[ARG_EXPECTED] = -2.4;
    ad_values[ARG_ACTUAL] = -2.42;
    ad_values[ARG_PRECISION] = 0.04;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_AroundZero
{
    ad_values[ARG_EXPECTED] = -0.5;
    ad_values[ARG_ACTUAL] = 0.2;
    ad_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedZero
{
    ad_values[ARG_EXPECTED] = 0.0;
    ad_values[ARG_ACTUAL] = 0.6;
    ad_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualZero
{
    ad_values[ARG_EXPECTED] = 1.0;
    ad_values[ARG_ACTUAL] = 0.0;
    ad_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinFloat
{
    const int exponent = ilogbf(FLT_MIN);
    af_values[ARG_EXPECTED] = FLT_MIN;
    af_values[ARG_ACTUAL] = FLT_MIN + ldexpf(0.05f, exponent);
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinFloat
{
    const int exponent = ilogbf(FLT_MIN);
    af_values[ARG_EXPECTED] = FLT_MIN + ldexpf(0.05f, exponent);
    af_values[ARG_ACTUAL] = FLT_MIN;
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = FLT_MAX;
    af_values[ARG_ACTUAL] = FLT_MAX - ldexpf(0.05f, exponent);
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = FLT_MAX - ldexpf(0.05f, exponent);
    af_values[ARG_ACTUAL] = FLT_MAX;
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinDouble
{
    const int exponent = ilogb(DBL_MIN);
    ad_values[ARG_EXPECTED] = DBL_MIN;
    ad_values[ARG_ACTUAL] = DBL_MIN + ldexp(0.05, exponent);
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinDouble
{
    const int exponent = ilogb(DBL_MIN);
    ad_values[ARG_EXPECTED] = DBL_MIN + ldexp(0.05, exponent);
    ad_values[ARG_ACTUAL] = DBL_MIN;
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = DBL_MAX;
    ad_values[ARG_ACTUAL] = DBL_MAX - ldexp(0.05, exponent);
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = DBL_MAX - ldexp(0.05, exponent);
    ad_values[ARG_ACTUAL] = DBL_MAX;
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinLongDouble
{
    const int exponent = ilogbl(LDBL_MIN);
    ald_values[ARG_EXPECTED] = LDBL_MIN;
    ald_values[ARG_ACTUAL] = LDBL_MIN + ldexpl(0.05l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinLongDouble
{
    const int exponent = ilogbl(LDBL_MIN);
    ald_values[ARG_EXPECTED] = LDBL_MIN + ldexpl(0.05l, exponent);
    ald_values[ARG_ACTUAL] = LDBL_MIN;
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = LDBL_MAX;
    ald_values[ARG_ACTUAL] = LDBL_MAX - ldexpl(0.05l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = LDBL_MAX - ldexpl(0.05l, exponent);
    ald_values[ARG_ACTUAL] = LDBL_MAX;
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinFloat
{
    const int exponent = ilogbf(-FLT_MIN);
    af_values[ARG_EXPECTED] = -FLT_MIN;
    af_values[ARG_ACTUAL] = -FLT_MIN - ldexpf(0.05f, exponent);
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinFloat
{
    const int exponent = ilogbf(-FLT_MIN);
    af_values[ARG_EXPECTED] = -FLT_MIN - ldexpf(0.05f, exponent);
    af_values[ARG_ACTUAL] = -FLT_MIN;
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = -FLT_MAX;
    af_values[ARG_ACTUAL] = -FLT_MAX + ldexpf(0.05f, exponent);
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = -FLT_MAX + ldexpf(0.05f, exponent);
    af_values[ARG_ACTUAL] = -FLT_MAX;
    af_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinDouble
{
    const int exponent = ilogb(-DBL_MIN);
    ad_values[ARG_EXPECTED] = -DBL_MIN;
    ad_values[ARG_ACTUAL] = -DBL_MIN + ldexp(0.05, exponent);
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinDouble
{
    const int exponent = ilogb(-DBL_MIN);
    ad_values[ARG_EXPECTED] = -DBL_MIN + ldexp(0.05, exponent);
    ad_values[ARG_ACTUAL] = -DBL_MIN;
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = -DBL_MAX;
    ad_values[ARG_ACTUAL] = -DBL_MAX + ldexp(0.05, exponent);
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = -DBL_MAX + ldexp(0.05, exponent);
    ad_values[ARG_ACTUAL] = -DBL_MAX;
    ad_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinLongDouble
{
    const int exponent = ilogbl(-LDBL_MIN);
    ald_values[ARG_EXPECTED] = -LDBL_MIN;
    ald_values[ARG_ACTUAL] = -LDBL_MIN + ldexpl(0.05l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinLongDouble
{
    const int exponent = ilogbl(-LDBL_MIN);
    ald_values[ARG_EXPECTED] = -LDBL_MIN + ldexpl(0.05l, exponent);
    ald_values[ARG_ACTUAL] = -LDBL_MIN;
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = -LDBL_MAX;
    ald_values[ARG_ACTUAL] = -LDBL_MAX + ldexpl(0.05l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = -LDBL_MAX + ldexpl(0.05l, exponent);
    ald_values[ARG_ACTUAL] = -LDBL_MAX;
    ald_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithInfinitePrecision
{
    ad_values[ARG_EXPECTED] = DBL_MIN;
    ad_values[ARG_ACTUAL] = DBL_MAX;
    ad_values[ARG_PRECISION] = INFINITY;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

#pragma mark - Not Equal

- (void)test_ctnotaboutequal_ComparesNotEqual_IfDifferentWidthsAndZeroPrecision
{
    af_values[ARG_EXPECTED] = 22.0f / 7.0f;
    ad_values[ARG_ACTUAL] = 22.0 / 7.0;
    ad_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_IfOutsideOfPrecision
{
    ad_values[ARG_EXPECTED] = 5.2;
    ad_values[ARG_ACTUAL] = 5.9;
    ad_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_IfJustBeyondPrecision
{
    ad_values[ARG_EXPECTED] = 5.4;
    ad_values[ARG_ACTUAL] = 5.5001;
    ad_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_ForFloats
{
    af_values[ARG_EXPECTED] = 0.82f;
    af_values[ARG_ACTUAL] = 0.78f;
    af_values[ARG_PRECISION] = 0.01f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_ForLongDoubles
{
    ald_values[ARG_EXPECTED] = 0.82l;
    ald_values[ARG_ACTUAL] = 0.78l;
    ald_values[ARG_PRECISION] = 0.01l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeValues
{
    ad_values[ARG_EXPECTED] = -2.4;
    ad_values[ARG_ACTUAL] = -2.5;
    ad_values[ARG_PRECISION] = 0.05;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_AroundZero
{
    ad_values[ARG_EXPECTED] = -0.5;
    ad_values[ARG_ACTUAL] = 0.4;
    ad_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedZero
{
    ad_values[ARG_EXPECTED] = 0.0;
    ad_values[ARG_ACTUAL] = 2.5;
    ad_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualZero
{
    ad_values[ARG_EXPECTED] = 2.0;
    ad_values[ARG_ACTUAL] = 0.0;
    ad_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinFloat
{
    const int exponent = ilogbf(FLT_MIN);
    af_values[ARG_EXPECTED] = FLT_MIN;
    af_values[ARG_ACTUAL] = FLT_MIN + ldexpf(5.7f, exponent);
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinFloat
{
    const int exponent = ilogbf(FLT_MIN);
    af_values[ARG_EXPECTED] = FLT_MIN + ldexpf(5.7f, exponent);
    af_values[ARG_ACTUAL] = FLT_MIN;
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = FLT_MAX;
    af_values[ARG_ACTUAL] = FLT_MAX - ldexpf(5.7f, exponent);
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = FLT_MAX - ldexpf(5.7f, exponent);
    af_values[ARG_ACTUAL] = FLT_MAX;
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinDouble
{
    const int exponent = ilogb(DBL_MIN);
    ad_values[ARG_EXPECTED] = DBL_MIN;
    ad_values[ARG_ACTUAL] = DBL_MIN + ldexp(5.7, exponent);
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinDouble
{
    const int exponent = ilogb(DBL_MIN);
    ad_values[ARG_EXPECTED] = DBL_MIN + ldexp(5.7, exponent);
    ad_values[ARG_ACTUAL] = DBL_MIN;
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = DBL_MAX;
    ad_values[ARG_ACTUAL] = DBL_MAX - ldexp(5.7, exponent);
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = DBL_MAX - ldexp(5.7, exponent);
    ad_values[ARG_ACTUAL] = DBL_MAX;
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinLongDouble
{
    const int exponent = ilogbl(LDBL_MIN);
    ald_values[ARG_EXPECTED] = LDBL_MIN;
    ald_values[ARG_ACTUAL] = LDBL_MIN + ldexpl(5.7l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinLongDouble
{
    const int exponent = ilogbl(LDBL_MIN);
    ald_values[ARG_EXPECTED] = LDBL_MIN + ldexpl(5.7l, exponent);
    ald_values[ARG_ACTUAL] = LDBL_MIN;
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = LDBL_MAX;
    ald_values[ARG_ACTUAL] = LDBL_MAX - ldexpl(5.7l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = LDBL_MAX - ldexpl(5.7l, exponent);
    ald_values[ARG_ACTUAL] = LDBL_MAX;
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithOverflow
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = LDBL_MAX;
    ald_values[ARG_ACTUAL] = ldexpl(-5.7l, exponent);
    ald_values[ARG_PRECISION] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedInfinity
{
    ad_values[ARG_EXPECTED] = INFINITY;
    ad_values[ARG_ACTUAL] = DBL_MAX;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualInfinity
{
    ad_values[ARG_EXPECTED] = DBL_MAX;
    ad_values[ARG_ACTUAL] = INFINITY;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNaN
{
    ad_values[ARG_EXPECTED] = NAN;
    ad_values[ARG_ACTUAL] = 45.2;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNaN
{
    ad_values[ARG_EXPECTED] = 27.9;
    ad_values[ARG_ACTUAL] = NAN;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithPrecisionNaN
{
    ad_values[ARG_EXPECTED] = 27.9;
    ad_values[ARG_ACTUAL] = 27.9;
    ad_values[ARG_PRECISION] = NAN;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinFloat
{
    const int exponent = ilogbf(-FLT_MIN);
    af_values[ARG_EXPECTED] = -FLT_MIN;
    af_values[ARG_ACTUAL] = -FLT_MIN - ldexpf(5.7f, exponent);
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinFloat
{
    const int exponent = ilogbf(-FLT_MIN);
    af_values[ARG_EXPECTED] = -FLT_MIN - ldexpf(5.7f, exponent);
    af_values[ARG_ACTUAL] = -FLT_MIN;
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = -FLT_MAX;
    af_values[ARG_ACTUAL] = -FLT_MAX + ldexpf(5.7f, exponent);
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    af_values[ARG_EXPECTED] = -FLT_MAX + ldexpf(5.7f, exponent);
    af_values[ARG_ACTUAL] = -FLT_MAX;
    af_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinDouble
{
    const int exponent = ilogb(-DBL_MIN);
    ad_values[ARG_EXPECTED] = -DBL_MIN;
    ad_values[ARG_ACTUAL] = -DBL_MIN + ldexp(5.7, exponent);
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinDouble
{
    const int exponent = ilogb(-DBL_MIN);
    ad_values[ARG_EXPECTED] = -DBL_MIN + ldexp(5.7, exponent);
    ad_values[ARG_ACTUAL] = -DBL_MIN;
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = -DBL_MAX;
    ad_values[ARG_ACTUAL] = -DBL_MAX + ldexp(5.7, exponent);
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    ad_values[ARG_EXPECTED] = -DBL_MAX + ldexp(5.7, exponent);
    ad_values[ARG_ACTUAL] = -DBL_MAX;
    ad_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinLongDouble
{
    const int exponent = ilogbl(-LDBL_MIN);
    ald_values[ARG_EXPECTED] = -LDBL_MIN;
    ald_values[ARG_ACTUAL] = -LDBL_MIN + ldexpl(5.7l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinLongDouble
{
    const int exponent = ilogbl(-LDBL_MIN);
    ald_values[ARG_EXPECTED] = -LDBL_MIN + ldexpl(5.7l, exponent);
    ald_values[ARG_ACTUAL] = -LDBL_MIN;
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = -LDBL_MAX;
    ald_values[ARG_ACTUAL] = -LDBL_MAX + ldexpl(5.7l, exponent);
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ald_values[ARG_EXPECTED] = -LDBL_MAX + ldexpl(5.7l, exponent);
    ald_values[ARG_ACTUAL] = -LDBL_MAX;
    ald_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeExpectedInfinity
{
    ad_values[ARG_EXPECTED] = -INFINITY;
    ad_values[ARG_ACTUAL] = -DBL_MAX;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeActualInfinity
{
    ad_values[ARG_EXPECTED] = -DBL_MAX;
    ad_values[ARG_ACTUAL] = -INFINITY;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeExpectedNaN
{
    ad_values[ARG_EXPECTED] = -NAN;
    ad_values[ARG_ACTUAL] = -45.2;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeActualNaN
{
    ad_values[ARG_EXPECTED] = -27.9;
    ad_values[ARG_ACTUAL] = -NAN;
    ad_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativePrecisionNaN
{
    ad_values[ARG_EXPECTED] = -27.9;
    ad_values[ARG_ACTUAL] = -27.9;
    ad_values[ARG_PRECISION] = -NAN;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

#pragma mark - Messages

- (void)test_ctnotaboutequal_FiresAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test_withmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctnotaboutequal_FiresAssertion_WithFormatMessage
{
    const struct ct_testcase tests[] = { ct_maketest(notabout_equality_test_withformatmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
