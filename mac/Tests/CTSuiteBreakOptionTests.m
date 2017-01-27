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

- (void)test_suiteBreaksEnabledByDefault
{
    [self assertDefaultOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreaksDisabledByEnv
{
    [self assertEnvDisabledOptionOutputContains:@"1 passed,"];
}

- (void)test_suiteBreaksEnabledForPositiveEnvValues
{
    [self assertEnvEnabledOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreaksEnabledWithArbitraryArgs
{
    [self assertArbitraryArgsOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreaksDisabledWithCommandLineArg
{
    [self assertArgDisablesOption:@"--ct-suite-breaks" outputContains:@"1 passed,"];
}

- (void)test_suiteBreaksEnabledWithPositiveCommandLineArg
{
    [self assertArgEnablesOption:@"--ct-suite-breaks" outputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_suiteBreaksHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateOption:@"--ct-suite-breaks" outputContains:@"1 passed,"];
}

@end
