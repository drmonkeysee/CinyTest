//
//  CTAssertAboutEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/28/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <float.h>
#include <math.h>
#include "ciny.h"

typedef NS_ENUM(NSUInteger, TEST_ARG_TYPE) {
    TAT_FLOAT,
    TAT_DOUBLE,
    TAT_LDOUBLE
};

enum argument {
    ARG_EXPECTED,
    ARG_ACTUAL,
    ARG_PRECISION
};

@interface CTAssertAboutEqualTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;
@property (nonatomic, assign) TEST_ARG_TYPE precisionType;

@end

static void *TestClass;

#define get_test_arg(T, i) ((T) == TAT_FLOAT ? f_values[i] \
                            : (T) == TAT_DOUBLE ? d_values[i] \
                            : ld_values[i])

static float f_values[3];
static double d_values[3];
static long double ld_values[3];

static void about_equality_test(void *context)
{
    CTAssertAboutEqualTests *testObject = (__bridge CTAssertAboutEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertaboutequal(get_test_arg(testObject.expectedType, ARG_EXPECTED), get_test_arg(testObject.actualType, ARG_ACTUAL), get_test_arg(testObject.precisionType, ARG_PRECISION));
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertAboutEqualTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;
    
    [super tearDown];
}

#pragma - Equal

- (void)test_ctaboutequal_ComparesEqual_IfEqualValues
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.5;
    d_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_IfWithinPrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.3;
    d_values[ARG_PRECISION] = 0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_IfExactlyOnPrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.51;
    d_values[ARG_PRECISION] = 0.01;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_IfNegativePrecision
{
    d_values[ARG_EXPECTED] = 4.5;
    d_values[ARG_ACTUAL] = 4.3;
    d_values[ARG_PRECISION] = -0.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_IfPrecisionIsGreaterThanValues
{
    d_values[ARG_EXPECTED] = 1.5;
    d_values[ARG_ACTUAL] = 2.3;
    d_values[ARG_PRECISION] = 3.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_IfDifferentWidthsAndBigEnoughPrecision
{
    f_values[ARG_EXPECTED] = 34.235f;
    ld_values[ARG_ACTUAL] = 34.246l;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_ForFloats
{
    f_values[ARG_EXPECTED] = 0.82f;
    f_values[ARG_ACTUAL] = 0.78f;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_ForLongDoubles
{
    ld_values[ARG_EXPECTED] = 0.82l;
    ld_values[ARG_ACTUAL] = 0.78l;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithNegativeValues
{
    d_values[ARG_EXPECTED] = -2.4;
    d_values[ARG_ACTUAL] = -2.42;
    d_values[ARG_PRECISION] = 0.04;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_AroundZero
{
    d_values[ARG_EXPECTED] = -0.5;
    d_values[ARG_ACTUAL] = 0.2;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedZero
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 0.6;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualZero
{
    d_values[ARG_EXPECTED] = 1.0;
    d_values[ARG_ACTUAL] = 0.0;
    d_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMinFloat
{
    f_values[ARG_EXPECTED] = FLT_MIN;
    f_values[ARG_ACTUAL] = FLT_MIN + 0.05f;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMinFloat
{
    f_values[ARG_EXPECTED] = FLT_MIN + 0.05f;
    f_values[ARG_ACTUAL] = FLT_MIN;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMaxFloat
{
    f_values[ARG_EXPECTED] = FLT_MAX;
    f_values[ARG_ACTUAL] = FLT_MAX - 0.05f;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMaxFloat
{
    f_values[ARG_EXPECTED] = FLT_MAX - 0.05f;
    f_values[ARG_ACTUAL] = FLT_MAX;
    f_values[ARG_PRECISION] = 0.1f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMinDouble
{
    d_values[ARG_EXPECTED] = DBL_MIN;
    d_values[ARG_ACTUAL] = DBL_MIN + 0.05;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMinDouble
{
    d_values[ARG_EXPECTED] = DBL_MIN + 0.05;
    d_values[ARG_ACTUAL] = DBL_MIN;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMaxDouble
{
    d_values[ARG_EXPECTED] = DBL_MAX;
    d_values[ARG_ACTUAL] = DBL_MAX - 0.05;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMaxDouble
{
    d_values[ARG_EXPECTED] = DBL_MAX - 0.05;
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMinLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN + 0.05l;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMinLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MIN + 0.05l;
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithExpectedMaxLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX - 0.05l;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesEqual_WithActualMaxLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MAX - 0.05l;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    ld_values[ARG_PRECISION] = 0.1l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

#pragma - Not Equal

- (void)test_ctaboutequal_ComparesNotEqual_IfDifferentWidthsAndZeroPrecision
{
    f_values[ARG_EXPECTED] = 22.0f / 7.0f;
    d_values[ARG_ACTUAL] = 22.0 / 7.0;
    d_values[ARG_PRECISION] = 0.0;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_IfOutsideOfPrecision
{
    d_values[ARG_EXPECTED] = 5.2;
    d_values[ARG_ACTUAL] = 5.9;
    d_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_IfJustBeyondPrecision
{
    d_values[ARG_EXPECTED] = 5.4;
    d_values[ARG_ACTUAL] = 5.5001;
    d_values[ARG_PRECISION] = 0.1;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_ForFloats
{
    f_values[ARG_EXPECTED] = 0.82f;
    f_values[ARG_ACTUAL] = 0.78f;
    f_values[ARG_PRECISION] = 0.01f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_ForLongDoubles
{
    ld_values[ARG_EXPECTED] = 0.82l;
    ld_values[ARG_ACTUAL] = 0.78l;
    ld_values[ARG_PRECISION] = 0.01l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithNegativeValues
{
    d_values[ARG_EXPECTED] = -2.4;
    d_values[ARG_ACTUAL] = -2.5;
    d_values[ARG_PRECISION] = 0.05;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_AroundZero
{
    d_values[ARG_EXPECTED] = -0.5;
    d_values[ARG_ACTUAL] = 0.4;
    d_values[ARG_PRECISION] = 0.3;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedZero
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 2.5;
    d_values[ARG_PRECISION] = 1.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualZero
{
    d_values[ARG_EXPECTED] = 2.0;
    d_values[ARG_ACTUAL] = 0.0;
    d_values[ARG_PRECISION] = 1.5;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMinFloat
{
    f_values[ARG_EXPECTED] = FLT_MIN;
    f_values[ARG_ACTUAL] = FLT_MIN + 5.7f;
    f_values[ARG_PRECISION] = 1.4f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMinFloat
{
    f_values[ARG_EXPECTED] = FLT_MIN + 5.7f;
    f_values[ARG_ACTUAL] = FLT_MIN;
    f_values[ARG_PRECISION] = 1.4f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMaxFloat
{
    f_values[ARG_EXPECTED] = FLT_MAX;
    f_values[ARG_ACTUAL] = FLT_MAX - 5.7f;
    f_values[ARG_PRECISION] = 1.4f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMaxFloat
{
    f_values[ARG_EXPECTED] = FLT_MAX - 5.7f;
    f_values[ARG_ACTUAL] = FLT_MAX;
    f_values[ARG_PRECISION] = 1.4f;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_FLOAT;
    self.precisionType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMinDouble
{
    d_values[ARG_EXPECTED] = DBL_MIN;
    d_values[ARG_ACTUAL] = DBL_MIN + 5.7;
    d_values[ARG_PRECISION] = 1.4;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMinDouble
{
    d_values[ARG_EXPECTED] = DBL_MIN + 5.7;
    d_values[ARG_ACTUAL] = DBL_MIN;
    d_values[ARG_PRECISION] = 1.4;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMaxDouble
{
    d_values[ARG_EXPECTED] = DBL_MAX;
    d_values[ARG_ACTUAL] = DBL_MAX - 5.7;
    d_values[ARG_PRECISION] = 1.4;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMaxDouble
{
    d_values[ARG_EXPECTED] = DBL_MAX - 5.7;
    d_values[ARG_ACTUAL] = DBL_MAX;
    d_values[ARG_PRECISION] = 1.4;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    self.precisionType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMinLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN + 5.7l;
    ld_values[ARG_PRECISION] = 1.4l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMinLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MIN + 5.7l;
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    ld_values[ARG_PRECISION] = 1.4l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithExpectedMaxLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX - 5.7l;
    ld_values[ARG_PRECISION] = 1.4l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctaboutequal_ComparesNotEqual_WithActualMaxLongDouble
{
    ld_values[ARG_EXPECTED] = LDBL_MAX - 5.7l;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    ld_values[ARG_PRECISION] = 1.4l;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    self.precisionType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(about_equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
