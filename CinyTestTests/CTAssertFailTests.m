//
//  CTAssertFailTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/4/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include "ciny.h"

@interface CTAssertFailTests : CTAssertionTestBase

@end

static void fail_test_nomessage(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail();
    
    testObject.sawPostAssertCode = YES;
}

static void fail_test_message(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail("a test message");
    
    testObject.sawPostAssertCode = YES;
}

static void fail_test_formatmessage(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail("a test message with %d format arguments: %f, %s", 3, 1.5, "foo");
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertFailTests

- (void)test_ctassertfail_TerminatesTest_IfGivenNoMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_nomessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertfail_TerminatesTest_IfGivenMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_message) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertfail_TerminatesTest_IfGivenFormattedMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_formatmessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
