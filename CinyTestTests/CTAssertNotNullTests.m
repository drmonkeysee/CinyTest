//
//  CTAssertNotNullTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/10/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTNullAssertionTestBase.h"
#include "ciny.h"

@interface CTAssertNotNullTests : CTNullAssertionTestBase

@end

static void variable_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(testObject.testVariable, "i see the %p value", testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(generate_pointer(testObject.useRealPointer), "oh no i got a fake pointer!!");
    
    testObject.sawPostAssertCode = YES;
}

static void literal_null_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull(NULL);
    
    testObject.sawPostAssertCode = YES;
}

static void literal_notnull_test(void *context)
{
    CTAssertNotNullTests *testObject = (__bridge CTAssertNotNullTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotnull((void *)0xffff);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNotNullTests

- (void)test_ctassertnotnull_ComparesNull_IfVariableIsNull
{
    self.testVariable = NULL;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotnull_ComparesNotNull_IfVariableIsNotNull
{
    self.testVariable = TestClass;
    struct ct_testcase cases[] = { ct_maketest(variable_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotnull_ComparesNull_IfExpressionReturnsNull
{
    self.useRealPointer = false;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotnull_ComparesNotNull_IfExpressionReturnsNotNull
{
    self.useRealPointer = true;
    struct ct_testcase cases[] = { ct_maketest(expression_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotnull_ComparesNull_IfLiteralIsNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_null_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotnull_ComparesNotNull_IfLiteralIsNotNull
{
    struct ct_testcase cases[] = { ct_maketest(literal_notnull_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

@end
