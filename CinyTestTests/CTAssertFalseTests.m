//
//  CTAssertFalseTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/9/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <stdbool.h>
#include "ciny.h"

@interface CTAssertFalseTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) bool testVariable;
@property (nonatomic, assign) NSInteger gtExpressionLhs;
@property (nonatomic, assign) NSInteger gtExpressionRhs;

@end

static void *TestClass;

static void variable_test(void *context)
{
    CTAssertFalseTests *testObject = (__bridge CTAssertFalseTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfalse(testObject.testVariable, "i did expect %d value right???", testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertFalseTests *testObject = (__bridge CTAssertFalseTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfalse(testObject.gtExpressionLhs > testObject.gtExpressionRhs, "oh no my lhs is too big!!");
    
    testObject.sawPostAssertCode = YES;
}

static void literal_true_test(void *context)
{
    CTAssertFalseTests *testObject = (__bridge CTAssertFalseTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfalse(45);
    
    testObject.sawPostAssertCode = YES;
}

static void literal_false_test(void *context)
{
    CTAssertFalseTests *testObject = (__bridge CTAssertFalseTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfalse(0);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertFalseTests

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

- (void)test_ctassertfalse_ComparesTrue_IfVariableIsTrue
{
    self.testVariable = true;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertfalse_ComparesFalse_IfVariableIsFalse
{
    self.testVariable = false;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertfalse_ComparesTrue_IfExpressionIsTrue
{
    self.gtExpressionLhs = 10;
    self.gtExpressionRhs = 5;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertfalse_ComparesFalse_IfExpressionIsFalse
{
    self.gtExpressionLhs = 5;
    self.gtExpressionRhs = 10;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertfalse_ComparesTrue_IfLiteralIsTrue
{
    struct ct_testcase cases[] = { ct_maketest(literal_true_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertfalse_ComparesFalse_IfLiteralIsFalse
{
    struct ct_testcase cases[] = { ct_maketest(literal_false_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

@end
