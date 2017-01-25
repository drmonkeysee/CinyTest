//
//  CTColorOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 11/27/16.
//  Copyright © 2016 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"

@interface CTColorOptionTests : CTOutputAssertionTestBase

@end

@implementation CTColorOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_COLORIZED";
        return self;
    }
    return nil;
}

- (void)test_colorizedEnabledByDefault
{
    [self assertDefaultOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedDisabledByEnv
{
    [self assertEnvDisabledOptionOutputContains:@"1 passed,"];
}

- (void)test_colorizedEnabledForPositiveEnvValues
{
    [self assertEnvEnabledOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedEnabledWithArbitraryArgs
{
    [self assertArbitraryArgsOptionOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedDisabledWithCommandLineArg
{
    [self assertArgDisablesOption:@"--ct-colorized" outputContains:@"1 passed,"];
}

- (void)test_colorizedEnabledWithPositiveCommandLineArg
{
    [self assertArgEnablesOption:@"--ct-colorized" outputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateOption:@"--ct-colorized" outputContains:@"1 passed,"];
}

@end
