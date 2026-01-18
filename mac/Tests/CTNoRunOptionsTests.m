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
    auto suite = ct_makesuite(cases);
    char *args[] = {"--ct-version"};
    
    auto result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(0u, result);
    XCTAssertFalse(self.invokedTest);
}

- (void)test_noTestsRun_IfHelpOptionSet
{
    const struct ct_testcase cases[] = {ct_maketest(test_case)};
    auto suite = ct_makesuite(cases);
    char *args[] = {"--ct-help"};
    
    auto result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(0u, result);
    XCTAssertFalse(self.invokedTest);
}

@end
