//
//  CTAssertNullTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/10/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTNullAssertionTestBase.h"
#include <stddef.h>
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
    
    ct_assertnull((void *)0xFFFF);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNullTests

- (void)test_ctassertnull_ComparesNull_IfVariableIsNull
{
    self.testVariable = NULL;
    const struct ct_testcase cases[] = { ct_maketest(variable_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnull_ComparesNotNull_IfVariableIsNotNull
{
    self.testVariable = TestClass;
    const struct ct_testcase cases[] = { ct_maketest(variable_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnull_ComparesNull_IfExpressionReturnsNull
{
    self.useRealPointer = false;
    const struct ct_testcase cases[] = { ct_maketest(expression_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnull_ComparesNotNull_IfExpressionReturnsNotNull
{
    self.useRealPointer = true;
    const struct ct_testcase cases[] = { ct_maketest(expression_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnull_ComparesNull_IfLiteralIsNull
{
    const struct ct_testcase cases[] = { ct_maketest(literal_null_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnull_ComparesNotNull_IfLiteralIsNotNull
{
    const struct ct_testcase cases[] = { ct_maketest(literal_notnull_test) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
