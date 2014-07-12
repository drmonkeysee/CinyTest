//
//  CTIgnoreTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/4/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include "ciny.h"

#undef failed_assertion_expected
#define failed_assertion_expected(test_result) \
            do { \
                XCTAssertEqual(0, test_result); \
                XCTAssertTrue(self.invokedTest); \
                XCTAssertFalse(self.sawPostAssertCode); \
            } while (0);

@interface CTIgnoreTests : CTAssertionTestBase

@end

static void ignore_test_nomessage(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore();
    
    testObject.sawPostAssertCode = YES;
}

static void ignore_test_message(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore("a test message");
    
    testObject.sawPostAssertCode = YES;
}

static void ignore_test_formatmessage(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore("a test message with %d format arguments: %f, %s", 3, 1.5, "foo");
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTIgnoreTests

- (void)test_ctignore_TerminatesTest_IfGivenNoMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_nomessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctignore_TerminatesTest_IfGivenMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_message) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctignore_TerminatesTest_IfGivenFormattedMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_formatmessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
