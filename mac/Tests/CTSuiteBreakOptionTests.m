//
//  CTSuiteBreakOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 1/26/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"

@interface CTSuiteBreakOptionTests : CTOutputAssertionTestBase

@end

@implementation CTSuiteBreakOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_SUITE_BREAKS";
        return self;
    }
    return nil;
}

- (void)test_suiteBreakEnabledByDefault
{
    [self assertDefault:CTOutputContains value:@"Test suite '"];
}

- (void)test_suiteBreakDisabledByEnv
{
    [self assertEnvDisabled:CTOutputDoesNotContain value:@"Test suite '"];
}

- (void)test_suiteBreakEnabledForPositiveEnvValues
{
    [self assertEnvEnabled:CTOutputContains value:@"Test suite '"];
}

- (void)test_suiteBreakEnabledWithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputContains value:@"Test suite '"];
}

- (void)test_suiteBreakDisabledWithCommandLineArg
{
    [self assertArg:@"--ct-suite-breaks" ifDisabled:CTOutputDoesNotContain value:@"Test suite '"];
}

- (void)test_suiteBreakEnabledWithPositiveCommandLineArg
{
    [self assertArg:@"--ct-suite-breaks" ifEnabled:CTOutputContains value:@"Test suite '"];
}

- (void)test_suiteBreakHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-suite-breaks" isDisabled:CTOutputDoesNotContain value:@"Test suite '"];
}

@end