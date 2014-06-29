//
//  CTAssertAboutEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/28/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

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

@end
