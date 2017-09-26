//
//  CTCaptureOutputOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 9/3/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"
#include <stdio.h>

static void io_testcase(void *context)
{
    printf("stdout message\n");
    ct_asserttrue(true, "true test");
}

@interface CTSuppressOutputOptionTests : CTOutputAssertionTestBase

@end

@implementation CTSuppressOutputOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_SUPPRESS_OUTPUT";
        return self;
    }
    return nil;
}

- (void)setUp
{
    [super setUp];
    
    self.testFunc = io_testcase;
}

- (void)test_suppressOutputEnabledByDefault
{
    [self assertDefault:CTOutputDoesNotContain value:@"stdout message"];
}

- (void)test_suppressOutputDisabledByEnv
{
    [self assertEnvDisabled:CTOutputContains value:@"stdout message"];
}

- (void)test_suppressOutputEnabled_ForPositiveEnvValues
{
    [self assertEnvEnabled:CTOutputDoesNotContain value:@"stdout message"];
}

- (void)test_suppressOutputEnabled_WithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputDoesNotContain value:@"stdout message"];
}

- (void)test_suppressOutputDisabled_WithCommandLineArg
{
    [self assertArg:@"--ct-suppress-output" ifDisabled:CTOutputContains value:@"stdout message"];
}

- (void)test_suppressOutputEnabled_WithPositiveCommandLineArg
{
    [self assertArg:@"--ct-suppress-output" ifEnabled:CTOutputDoesNotContain value:@"stdout message"];
}

- (void)test_suppressOutputHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-suppress-output" isDisabled:CTOutputContains value:@"stdout message"];
}

@end
