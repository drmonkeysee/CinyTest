//
//  CTNoRunOptionsTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 1/22/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"

#include "ciny.h"

@interface CTNoRunOptionsTests : CTAssertionTestBase

@end

static void test_case(void *context)
{
    CTNoRunOptionsTests *testObject =
        (__bridge CTNoRunOptionsTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_asserttrue(true, "true test");
}

@implementation CTNoRunOptionsTests

- (void)test_noTestsRun_IfVersionOptionSet
{
    const struct ct_testcase cases[] = {ct_maketest(test_case)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    const char *args[] = {"--ct-version"};
    
    const size_t result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(0u, result);
    XCTAssertFalse(self.invokedTest);
}

- (void)test_noTestsRun_IfHelpOptionSet
{
    const struct ct_testcase cases[] = {ct_maketest(test_case)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    const char *args[] = {"--ct-help"};
    
    const size_t result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(0u, result);
    XCTAssertFalse(self.invokedTest);
}

@end
