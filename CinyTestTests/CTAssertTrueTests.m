//
//  CTAssertTrueTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/9/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include <stddef.h>
#include <stdbool.h>
#include "ciny.h"

@interface CTAssertTrueTests : CTAssertionTestBase

@property (nonatomic, assign) bool testVariable;
@property (nonatomic, assign) NSInteger gtExpressionLhs;
@property (nonatomic, assign) NSInteger gtExpressionRhs;

@end

static void variable_test(void *context)
{
    CTAssertTrueTests *testObject = (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(testObject.testVariable, "i didn't expect %d value right???", testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertTrueTests *testObject = (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(testObject.gtExpressionLhs > testObject.gtExpressionRhs, "oh no my lhs is too small!!");
    
    testObject.sawPostAssertCode = YES;
}

static void literal_true_test(void *context)
{
    CTAssertTrueTests *testObject = (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(45);
    
    testObject.sawPostAssertCode = YES;
}

static void literal_false_test(void *context)
{
    CTAssertTrueTests *testObject = (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(0);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertTrueTests

- (void)test_ctasserttrue_ComparesTrue_IfVariableIsTrue
{
    self.testVariable = true;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctasserttrue_ComparesFalse_IfVariableIsFalse
{
    self.testVariable = false;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctasserttrue_ComparesTrue_IfExpressionIsTrue
{
    self.gtExpressionLhs = 10;
    self.gtExpressionRhs = 5;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctasserttrue_ComparesFalse_IfExpressionIsFalse
{
    self.gtExpressionLhs = 5;
    self.gtExpressionRhs = 10;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctasserttrue_ComparesTrue_IfLiteralIsTrue
{
    struct ct_testcase cases[] = { ct_maketest(literal_true_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctasserttrue_ComparesFalse_IfLiteralIsFalse
{
    struct ct_testcase cases[] = { ct_maketest(literal_false_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
