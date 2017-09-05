//
//  CTCaptureOutputOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 9/3/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

static void io_testcase(void *context)
{
    printf("stdout message\n");
    fprintf(stderr, "stderr message\n");
    ct_asserttrue(true, "true test");
}

@interface CTSuppressOutputOptionTests : CTOutputAssertionTestBase

@end

@implementation CTSuppressOutputOptionTests

- (void)setUp
{
    [super setUp];
    
    self.testFunc = io_testcase;
}

- (void)test_suppressOutputEnabledByDefault
{
    [self assertDefault:CTOutputDoesNotContain value:@"stdout message"];
    [self assertDefault:CTOutputDoesNotContain value:@"stderr message"];
    /*
    printf("BEFORE DUP\n");
    const int std_out = dup(fileno(stdout));
    //const int dev_null = open("/dev/null", O_WRONLY);
    printf("BEFORE DUP2\n");
    fflush(stdout);
    //int result = dup2(dev_null, fileno(stdout));
    freopen("/dev/null", "w", stdout);
    printf("SHOULDN'T SEE\n");
    FILE *my_stdout = fdopen(std_out, "w");
    fprintf(my_stdout, "SHOULD SEE\n");
    fflush(stdout);
    fflush(my_stdout);
    // don't close before dup2
    //fclose(my_stdout);
    dup2(std_out, fileno(stdout));
    fclose(my_stdout);
    // close unnecessary after fclose
    //close(std_out);
    printf("AFTER RESTORE\n");
    */
}

- (void)test_suppressOutputEnabledForPositiveEnvValues
{
    [self assertEnvEnabled:CTOutputDoesNotContain value:@"stdout message"];
    [self assertEnvEnabled:CTOutputDoesNotContain value:@"stderr message"];
}

- (void)test_suppressOutputEnabledWithArbitraryArgs
{
    [self assertArbitraryArgs:CTOutputDoesNotContain value:@"stdout message"];
    [self assertArbitraryArgs:CTOutputDoesNotContain value:@"stderr message"];
}

- (void)test_suppressOutputDisabledWithCommandLineArg
{
    [self assertArg:@"--ct-suppress-output" ifDisabled:CTOutputContains value:@"stdout message"];
    [self assertArg:@"--ct-suppress-output" ifDisabled:CTOutputContains value:@"stderr message"];
}

- (void)test_suppressOutputEnabledWithPositiveCommandLineArg
{
    [self assertArg:@"--ct-suppress-output" ifEnabled:CTOutputDoesNotContain value:@"stdout message"];
    [self assertArg:@"--ct-suppress-output" ifEnabled:CTOutputDoesNotContain value:@"stderr message"];
}

- (void)test_suppressOutputHandlesDuplicateCommandLineArgs
{
    [self assertDuplicateArg:@"--ct-suppress-output" isDisabled:CTOutputContains value:@"stdout message"];
    [self assertDuplicateArg:@"--ct-suppress-output" isDisabled:CTOutputContains value:@"stderr message"];
}

@end
