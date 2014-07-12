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

#pragma - Equal

- (void)test_ctnotaboutequal_ComparesEqual_IfEqualValues
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.5;
    d_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfWithinPrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.3;
    d_values[ARG_PRECISION] = 0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfExactlyOnPrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.51;
    d_values[ARG_PRECISION] = 0.01;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfNegativePrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.3;
    d_values[ARG_PRECISION] = -0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfPrecisionIsGreaterThanValues
{
    d_values[ARG_EXPECTED] = 1.5;
    d_values[ARG_ACTUAL] = 2.3;
    d_values[ARG_PRECISION] = 3.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_IfDifferentWidthsAndBigEnoughPrecision
{
    f_values[ARG_EXPECTED] = 34.235f;
    ld_values[ARG_ACTUAL] = 34.246l;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_ForFloats
{
    f_values[ARG_EXPECTED] = 0.82f;
    f_values[ARG_ACTUAL] = 0.78f;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_ForLongDoubles
{
    ld_values[ARG_EXPECTED] = 0.82l;
    ld_values[ARG_ACTUAL] = 0.78l;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithNegativeValues
{
    d_values[ARG_EXPECTED] = -2.4;
    d_values[ARG_ACTUAL] = -2.42;
    d_values[ARG_PRECISION] = 0.04;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_AroundZero
{
    d_values[ARG_EXPECTED] = -0.5;
    d_values[ARG_ACTUAL] = 0.2;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedZero
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 0.6;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualZero
{
    d_values[ARG_EXPECTED] = 1.0;
    d_values[ARG_ACTUAL] = 0.0;
    d_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinFloat
{
    int exponent = ilogbf(FLT_MIN);
    f_values[ARG_EXPECTED] = FLT_MIN;
    f_values[ARG_ACTUAL] = FLT_MIN + ldexpf(0.05f, exponent);
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinFloat
{
    int exponent = ilogbf(FLT_MIN);
    f_values[ARG_EXPECTED] = FLT_MIN + ldexpf(0.05f, exponent);
    f_values[ARG_ACTUAL] = FLT_MIN;
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = FLT_MAX;
    f_values[ARG_ACTUAL] = FLT_MAX - ldexpf(0.05f, exponent);
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = FLT_MAX - ldexpf(0.05f, exponent);
    f_values[ARG_ACTUAL] = FLT_MAX;
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinDouble
{
    int exponent = ilogb(DBL_MIN);
    d_values[ARG_EXPECTED] = DBL_MIN;
    d_values[ARG_ACTUAL] = DBL_MIN + ldexp(0.05, exponent);
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinDouble
{
    int exponent = ilogb(DBL_MIN);
    d_values[ARG_EXPECTED] = DBL_MIN + ldexp(0.05, exponent);
    d_values[ARG_ACTUAL] = DBL_MIN;
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = DBL_MAX;
    d_values[ARG_ACTUAL] = DBL_MAX - ldexp(0.05, exponent);
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = DBL_MAX - ldexp(0.05, exponent);
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMinLongDouble
{
    int exponent = ilogbl(LDBL_MIN);
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN + ldexpl(0.05l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMinLongDouble
{
    int exponent = ilogbl(LDBL_MIN);
    ld_values[ARG_EXPECTED] = LDBL_MIN + ldexpl(0.05l, exponent);
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX - ldexpl(0.05l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = LDBL_MAX - ldexpl(0.05l, exponent);
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinFloat
{
    int exponent = ilogbf(-FLT_MIN);
    f_values[ARG_EXPECTED] = -FLT_MIN;
    f_values[ARG_ACTUAL] = -FLT_MIN - ldexpf(0.05f, exponent);
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinFloat
{
    int exponent = ilogbf(-FLT_MIN);
    f_values[ARG_EXPECTED] = -FLT_MIN - ldexpf(0.05f, exponent);
    f_values[ARG_ACTUAL] = -FLT_MIN;
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = -FLT_MAX;
    f_values[ARG_ACTUAL] = -FLT_MAX + ldexpf(0.05f, exponent);
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = -FLT_MAX + ldexpf(0.05f, exponent);
    f_values[ARG_ACTUAL] = -FLT_MAX;
    f_values[ARG_PRECISION] = ldexpf(0.1f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinDouble
{
    int exponent = ilogb(-DBL_MIN);
    d_values[ARG_EXPECTED] = -DBL_MIN;
    d_values[ARG_ACTUAL] = -DBL_MIN + ldexp(0.05, exponent);
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinDouble
{
    int exponent = ilogb(-DBL_MIN);
    d_values[ARG_EXPECTED] = -DBL_MIN + ldexp(0.05, exponent);
    d_values[ARG_ACTUAL] = -DBL_MIN;
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = -DBL_MAX;
    d_values[ARG_ACTUAL] = -DBL_MAX + ldexp(0.05, exponent);
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = -DBL_MAX + ldexp(0.05, exponent);
    d_values[ARG_ACTUAL] = -DBL_MAX;
    d_values[ARG_PRECISION] = ldexp(0.1, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMinLongDouble
{
    int exponent = ilogbl(-LDBL_MIN);
    ld_values[ARG_EXPECTED] = -LDBL_MIN;
    ld_values[ARG_ACTUAL] = -LDBL_MIN + ldexpl(0.05l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMinLongDouble
{
    int exponent = ilogbl(-LDBL_MIN);
    ld_values[ARG_EXPECTED] = -LDBL_MIN + ldexpl(0.05l, exponent);
    ld_values[ARG_ACTUAL] = -LDBL_MIN;
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithExpectedNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = -LDBL_MAX;
    ld_values[ARG_ACTUAL] = -LDBL_MAX + ldexpl(0.05l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithActualNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = -LDBL_MAX + ldexpl(0.05l, exponent);
    ld_values[ARG_ACTUAL] = -LDBL_MAX;
    ld_values[ARG_PRECISION] = ldexpl(0.1l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesEqual_WithInfinitePrecision
{
    d_values[ARG_EXPECTED] = DBL_MIN;
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = INFINITY;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma - Not Equal

- (void)test_ctnotaboutequal_ComparesNotEqual_IfDifferentWidthsAndZeroPrecision
{
    f_values[ARG_EXPECTED] = 22.0f / 7.0f;
    d_values[ARG_ACTUAL] = 22.0 / 7.0;
    d_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_IfOutsideOfPrecision
{
    d_values[ARG_EXPECTED] = 5.2;
    d_values[ARG_ACTUAL] = 5.9;
    d_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_IfJustBeyondPrecision
{
    d_values[ARG_EXPECTED] = 5.4;
    d_values[ARG_ACTUAL] = 5.5001;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_ForFloats
{
    f_values[ARG_EXPECTED] = 0.82f;
    f_values[ARG_ACTUAL] = 0.78f;
    f_values[ARG_PRECISION] = 0.01f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_ForLongDoubles
{
    ld_values[ARG_EXPECTED] = 0.82l;
    ld_values[ARG_ACTUAL] = 0.78l;
    ld_values[ARG_PRECISION] = 0.01l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeValues
{
    d_values[ARG_EXPECTED] = -2.4;
    d_values[ARG_ACTUAL] = -2.5;
    d_values[ARG_PRECISION] = 0.05;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_AroundZero
{
    d_values[ARG_EXPECTED] = -0.5;
    d_values[ARG_ACTUAL] = 0.4;
    d_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedZero
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 2.5;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualZero
{
    d_values[ARG_EXPECTED] = 2.0;
    d_values[ARG_ACTUAL] = 0.0;
    d_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinFloat
{
    int exponent = ilogbf(FLT_MIN);
    f_values[ARG_EXPECTED] = FLT_MIN;
    f_values[ARG_ACTUAL] = FLT_MIN + ldexpf(5.7f, exponent);
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinFloat
{
    int exponent = ilogbf(FLT_MIN);
    f_values[ARG_EXPECTED] = FLT_MIN + ldexpf(5.7f, exponent);
    f_values[ARG_ACTUAL] = FLT_MIN;
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = FLT_MAX;
    f_values[ARG_ACTUAL] = FLT_MAX - ldexpf(5.7f, exponent);
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxFloat
{
    int exponent = ilogbf(FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = FLT_MAX - ldexpf(5.7f, exponent);
    f_values[ARG_ACTUAL] = FLT_MAX;
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinDouble
{
    int exponent = ilogb(DBL_MIN);
    d_values[ARG_EXPECTED] = DBL_MIN;
    d_values[ARG_ACTUAL] = DBL_MIN + ldexp(5.7, exponent);
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinDouble
{
    int exponent = ilogb(DBL_MIN);
    d_values[ARG_EXPECTED] = DBL_MIN + ldexp(5.7, exponent);
    d_values[ARG_ACTUAL] = DBL_MIN;
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = DBL_MAX;
    d_values[ARG_ACTUAL] = DBL_MAX - ldexp(5.7, exponent);
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxDouble
{
    int exponent = ilogb(DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = DBL_MAX - ldexp(5.7, exponent);
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMinLongDouble
{
    int exponent = ilogbl(LDBL_MIN);
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN + ldexpl(5.7l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMinLongDouble
{
    int exponent = ilogbl(LDBL_MIN);
    ld_values[ARG_EXPECTED] = LDBL_MIN + ldexpl(5.7l, exponent);
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX - ldexpl(5.7l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualMaxLongDouble
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = LDBL_MAX - ldexpl(5.7l, exponent);
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithOverflow
{
    int exponent = ilogbl(LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = ldexpl(-5.7l, exponent);
    ld_values[ARG_PRECISION] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedInfinity
{
    d_values[ARG_EXPECTED] = INFINITY;
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualInfinity
{
    d_values[ARG_EXPECTED] = DBL_MAX;
    d_values[ARG_ACTUAL] = INFINITY;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNaN
{
    d_values[ARG_EXPECTED] = NAN;
    d_values[ARG_ACTUAL] = 45.2;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNaN
{
    d_values[ARG_EXPECTED] = 27.9;
    d_values[ARG_ACTUAL] = NAN;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithPrecisionNaN
{
    d_values[ARG_EXPECTED] = 27.9;
    d_values[ARG_ACTUAL] = 27.9;
    d_values[ARG_PRECISION] = NAN;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinFloat
{
    int exponent = ilogbf(-FLT_MIN);
    f_values[ARG_EXPECTED] = -FLT_MIN;
    f_values[ARG_ACTUAL] = -FLT_MIN - ldexpf(5.7f, exponent);
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinFloat
{
    int exponent = ilogbf(-FLT_MIN);
    f_values[ARG_EXPECTED] = -FLT_MIN - ldexpf(5.7f, exponent);
    f_values[ARG_ACTUAL] = -FLT_MIN;
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = -FLT_MAX;
    f_values[ARG_ACTUAL] = -FLT_MAX + ldexpf(5.7f, exponent);
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxFloat
{
    int exponent = ilogbf(-FLT_MAX);
    exponent -= exponent / 10;
    f_values[ARG_EXPECTED] = -FLT_MAX + ldexpf(5.7f, exponent);
    f_values[ARG_ACTUAL] = -FLT_MAX;
    f_values[ARG_PRECISION] = ldexpf(1.4f, exponent);
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinDouble
{
    int exponent = ilogb(-DBL_MIN);
    d_values[ARG_EXPECTED] = -DBL_MIN;
    d_values[ARG_ACTUAL] = -DBL_MIN + ldexp(5.7, exponent);
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinDouble
{
    int exponent = ilogb(-DBL_MIN);
    d_values[ARG_EXPECTED] = -DBL_MIN + ldexp(5.7, exponent);
    d_values[ARG_ACTUAL] = -DBL_MIN;
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = -DBL_MAX;
    d_values[ARG_ACTUAL] = -DBL_MAX + ldexp(5.7, exponent);
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxDouble
{
    int exponent = ilogb(-DBL_MAX);
    exponent -= exponent / 20;
    d_values[ARG_EXPECTED] = -DBL_MAX + ldexp(5.7, exponent);
    d_values[ARG_ACTUAL] = -DBL_MAX;
    d_values[ARG_PRECISION] = ldexp(1.4, exponent);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMinLongDouble
{
    int exponent = ilogbl(-LDBL_MIN);
    ld_values[ARG_EXPECTED] = -LDBL_MIN;
    ld_values[ARG_ACTUAL] = -LDBL_MIN + ldexpl(5.7l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMinLongDouble
{
    int exponent = ilogbl(-LDBL_MIN);
    ld_values[ARG_EXPECTED] = -LDBL_MIN + ldexpl(5.7l, exponent);
    ld_values[ARG_ACTUAL] = -LDBL_MIN;
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithExpectedNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = -LDBL_MAX;
    ld_values[ARG_ACTUAL] = -LDBL_MAX + ldexpl(5.7l, exponent);
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithActualNegativeMaxLongDouble
{
    int exponent = ilogbl(-LDBL_MAX);
    exponent -= exponent / 400;
    ld_values[ARG_EXPECTED] = -LDBL_MAX + ldexpl(5.7l, exponent);
    ld_values[ARG_ACTUAL] = -LDBL_MAX;
    ld_values[ARG_PRECISION] = ldexpl(1.4l, exponent);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeExpectedInfinity
{
    d_values[ARG_EXPECTED] = -INFINITY;
    d_values[ARG_ACTUAL] = -DBL_MAX;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeActualInfinity
{
    d_values[ARG_EXPECTED] = -DBL_MAX;
    d_values[ARG_ACTUAL] = -INFINITY;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeExpectedNaN
{
    d_values[ARG_EXPECTED] = -NAN;
    d_values[ARG_ACTUAL] = -45.2;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativeActualNaN
{
    d_values[ARG_EXPECTED] = -27.9;
    d_values[ARG_ACTUAL] = -NAN;
    d_values[ARG_PRECISION] = DBL_MAX;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_ComparesNotEqual_WithNegativePrecisionNaN
{
    d_values[ARG_EXPECTED] = -27.9;
    d_values[ARG_ACTUAL] = -27.9;
    d_values[ARG_PRECISION] = -NAN;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

#pragma mark - Messages

- (void)test_ctnotaboutequal_FiresAssertion_WithMessage
{
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctnotaboutequal_FiresAssertion_WithFormatMessage
{
    struct ct_testcase tests[] = { ct_maketest(notabout_equality_test_withformatmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
