//
//  CTAssertNullTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/10/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTNullAssertionTestBase.h"
#include "ciny.h"

@interface CTAssertNullTests : CTNullAssertionTestBase

@end

static void variable_test(void *context)
{
    CTAssertNullTests *testObject = (__bridge CTAssertNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnull(testObject.testVariable, "i see the %p value", testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertNullTests *testObject = (__bridge CTAssertNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnull(generate_pointer(testObject.useRealPointer), "oh no i got a real pointer!!");
    
    testObject.sawPostAssertCode = YES;
}

static void literal_null_test(void *context)
{
    CTAssertNullTests *testObject = (__bridge CTAssertNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnull(NULL);
    
    testObject.sawPostAssertCode = YES;
}

static void literal_notnull_test(void *context)
{
    CTAssertNullTests *testObject = (__bridge CTAssertNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnull((void *)0xffff);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNullTests

- (void)test_ctassertnull_ComparesNull_IfVariableIsNull
{
    self.testVariable = NULL;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnull_ComparesNotNull_IfVariableIsNotNull
{
    self.testVariable = TestClass;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnull_ComparesNull_IfExpressionReturnsNull
{
    self.useRealPointer = false;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnull_ComparesNotNull_IfExpressionReturnsNotNull
{
    self.useRealPointer = true;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertnull_ComparesNull_IfLiteralIsNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_null_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertnull_ComparesNotNull_IfLiteralIsNotNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_notnull_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
