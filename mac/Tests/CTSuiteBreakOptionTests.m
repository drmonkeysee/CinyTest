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
    [self assertDefault:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreakDisabledByEnv
{
    [self assertEnvDisabled:CTOutputContains value:@"1 passed,"];
}

- (void)test_suiteBreakEnabledForPositiveEnvValues
{
    [self assertEnvEnabled:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreakEnabledWithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreakDisabledWithCommandLineArg
{
    [self assertArg:@"--ct-colorized" ifDisabled:CTOutputContains value:@"1 passed,"];
}

- (void)test_suiteBreakEnabledWithPositiveCommandLineArg
{
    [self assertArg:@"--ct-colorized" ifEnabled:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreakHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-colorized" isDisabled:CTOutputContains value:@"1 passed,"];
}

@end
