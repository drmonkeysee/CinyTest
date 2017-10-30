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

- (void)test_colorizedDisabledByDefault
{
    [self assertDefault:CTOutputDoesNotContain value:@"Colorized:"];
}

- (void)test_colorizedDisabled_WithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputDoesNotContain value:@"Colorized:"];
}

- (void)test_colorizedEnabled_WithCommandLineArg
{
    [self assertArg:@"--ct-verbose" ifPresent:CTOutputContains value:@"Colorized:"];
}

- (void)test_colorizedHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-verbose" isDisabled:CTOutputContains value:@"Colorized:"];
}

@end
