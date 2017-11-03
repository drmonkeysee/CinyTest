//
//  CTVerboseOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 10/29/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"

@interface CTVerboseOptionTests : CTOutputAssertionTestBase

@end

@implementation CTVerboseOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_VERBOSE";
        return self;
    }
    return nil;
}

- (void)test_verbosityDefault
{
    [self assertDefault:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertDefault:CTOutputContains value:@"Test suite '"];
    [self assertDefault:CTOutputContains value:@"[ ✓ ] - "];
    [self assertDefault:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_VerbosityWithArbitraryArgs
{
    [self assertDefault:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertDefault:CTOutputContains value:@"Test suite '"];
    [self assertDefault:CTOutputContains value:@"[ ✓ ] - "];
    [self assertDefault:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_verbosityMinimal
{
    [self assertArg:@"--ct-verbose" inputs:@[@"0"] compare:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"0"] compare:CTOutputDoesNotContain value:@"Test suite '"];
    [self assertArg:@"--ct-verbose" inputs:@[@"0"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"0"] compare:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_verbosityUniform
{
    [self assertArg:@"--ct-verbose" inputs:@[@"1"] compare:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"1"] compare:CTOutputDoesNotContain value:@"Test suite '"];
    [self assertArg:@"--ct-verbose" inputs:@[@"1"] compare:CTOutputContains value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"1"] compare:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_verbosityExplicitDefault
{
    [self assertArg:@"--ct-verbose" inputs:@[@"2"] compare:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"2"] compare:CTOutputContains value:@"Test suite '"];
    [self assertArg:@"--ct-verbose" inputs:@[@"2"] compare:CTOutputContains value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"2"] compare:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_verbosityFull
{
    [self assertArg:@"--ct-verbose" inputs:@[@"3"] compare:CTOutputContains value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"3"] compare:CTOutputContains value:@"Test suite '"];
    [self assertArg:@"--ct-verbose" inputs:@[@"3"] compare:CTOutputContains value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"3"] compare:CTOutputContains value:@"[ SUCCESS ]"];
}

- (void)test_verbosityClampsLessThanMinimal
{
    [self assertArg:@"--ct-verbose" inputs:@[@"-1"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"-23"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"-334"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"-2"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
}

- (void)test_verbosityClampsGreaterThanFull
{
    [self assertArg:@"--ct-verbose" inputs:@[@"8"] compare:CTOutputContains value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"4"] compare:CTOutputContains value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"10"] compare:CTOutputContains value:@"Colorized:"];
    [self assertArg:@"--ct-verbose" inputs:@[@"324"] compare:CTOutputContains value:@"Colorized:"];
}

- (void)test_verbositySetsMinimal_IfMalformed
{
    [self assertArg:@"--ct-verbose" inputs:@[@"foo"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"%4"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
    [self assertArg:@"--ct-verbose" inputs:@[@"**"] compare:CTOutputDoesNotContain value:@"[ ✓ ] - "];
}

- (void)test_verbosityEnvVar
{
    [self assertEnvInputs:@[@"1"] compare:CTOutputDoesNotContain value:@"Colorized:"];
    [self assertEnvInputs:@[@"1"] compare:CTOutputDoesNotContain value:@"Test suite '"];
    [self assertEnvInputs:@[@"1"] compare:CTOutputContains value:@"[ ✓ ] - "];
    [self assertEnvInputs:@[@"1"] compare:CTOutputContains value:@"[ SUCCESS ]"];
}

@end
