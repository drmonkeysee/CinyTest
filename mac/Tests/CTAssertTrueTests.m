//
//  CTAssertTrueTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/9/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTBoolAssertionTestBase.h"

#include "ciny.h"

#include <stddef.h>

@interface CTAssertTrueTests : CTBoolAssertionTestBase

@end

static void variable_test(void *context)
{
    CTAssertTrueTests *testObject =
        (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(testObject.testVariable, "i didn't expect %d value right???",
                  testObject.testVariable);
    
    testObject.sawPostAssertCode = YES;
}

static void expression_test(void *context)
{
    CTAssertTrueTests *testObject =
        (__bridge CTAssertTrueTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(testObject.gtExpressionLhs > testObject.gtExpressionRhs,
                  "oh no my lhs is too small!!");
    
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
    const struct ct_testcase cases[] = {ct_maketest(variable_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctasserttrue_ComparesFalse_IfVariableIsFalse
{
    self.testVariable = false;
    const struct ct_testcase cases[] = {ct_maketest(variable_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctasserttrue_ComparesTrue_IfExpressionIsTrue
{
    self.gtExpressionLhs = 10;
    self.gtExpressionRhs = 5;
    const struct ct_testcase cases[] = {ct_maketest(expression_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctasserttrue_ComparesFalse_IfExpressionIsFalse
{
    self.gtExpressionLhs = 5;
    self.gtExpressionRhs = 10;
    const struct ct_testcase cases[] = {ct_maketest(expression_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctasserttrue_ComparesTrue_IfLiteralIsTrue
{
    const struct ct_testcase cases[] = {ct_maketest(literal_true_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctasserttrue_ComparesFalse_IfLiteralIsFalse
{
    const struct ct_testcase cases[] = {ct_maketest(literal_false_test)};
    auto suite = ct_makesuite(cases);
    
    auto run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
