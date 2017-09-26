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
    [self assertDefault:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedDisabledByEnv
{
    [self assertEnvDisabled:CTOutputContains value:@"1 passed,"];
}

- (void)test_colorizedEnabled_ForPositiveEnvValues
{
    [self assertEnvEnabled:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedEnabled_WithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedDisabled_WithCommandLineArg
{
    [self assertArg:@"--ct-colorized" ifDisabled:CTOutputContains value:@"1 passed,"];
}

- (void)test_colorizedEnabled_WithPositiveCommandLineArg
{
    [self assertArg:@"--ct-colorized" ifEnabled:CTOutputContains value:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-colorized" isDisabled:CTOutputContains value:@"1 passed,"];
}

@end
