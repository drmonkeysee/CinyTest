//
//  CTOutputAssertionTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 1/24/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include "ciny.h"

static void test_case(void *context)
{
    ct_asserttrue(true, "true test");
}

@implementation CTOutputAssertionTestBase

- (void)setUp
{
    [super setUp];
    
    unsetenv(self.envProperty.UTF8String);
}

- (void)tearDown
{
    unsetenv(self.envProperty.UTF8String);
    
    [super tearDown];
}

- (void)assertDefaultOptionOutputContains:(NSString *)expected
{
    [self assertSuiteOutputContains:expected forValue:nil];
}

- (void)assertEnvDisabledOptionOutputContains:(NSString *)expected
{
    NSArray *disableValues = @[@"NO", @"no", @"FALSE", @"false", @"0", @"n", @"F"];
    for (NSString *value in disableValues) {
        setenv(self.envProperty.UTF8String, value.UTF8String, 1);
        [self assertSuiteOutputContains:expected forValue:value];
    }
}

- (void)assertEnvEnabledOptionOutputContains:(NSString *)expected
{
    NSArray *randomValues = @[@"YES", @"true", @"blarg", @"", @"1"];
    for (NSString *value in randomValues) {
        setenv(self.envProperty.UTF8String, value.UTF8String, 1);
        [self assertSuiteOutputContains:expected forValue:value];
    }
}

- (void)assertArbitraryArgsOptionOutputContains:(NSString *)expected
{
    NSArray *args = @[@"my-program", @"--foo=1", @"-v", @"", @"--ct-somethingelse=NO"];
    [self assertSuiteOutputContains:expected forValue:nil withArgs:args];
}

- (void)assertArgDisablesOption:(NSString *)optionArgument outputContains:(NSString *)expected
{
    NSArray *disableValues = @[@"%@=NO", @"%@=no", @"%@=FALSE", @"%@=false", @"%@=0", @"%@=N", @"%@=f"];
    for (NSString *value in disableValues) {
        NSMutableArray *args = [NSMutableArray arrayWithObjects:@"my-program", @"--foo=1", @"-v", @"--ct-somethingelse=NO", nil];
        const uint32_t insertIndex = arc4random_uniform((uint32_t)args.count);
        NSString *argValue = [NSString stringWithFormat:value, optionArgument];
        [args insertObject:argValue atIndex:insertIndex];
        [self assertSuiteOutputContains:expected forValue:value withArgs:args];
    }
}

- (void)assertArgEnablesOption:(NSString *)optionArgument outputContains:(NSString *)expected
{
    NSArray *randomValues = @[@"%@=YES", @"%@=true", @"%@=blarg", @"%@=", @"%@", @"%@=1"];
    for (NSString *value in randomValues) {
        NSMutableArray *args = [NSMutableArray arrayWithObjects:@"my-program", @"--foo=1", @"-v", @"--ct-somethingelse=NO", nil];
        const uint32_t insertIndex = arc4random_uniform((uint32_t)args.count);
        NSString *argValue = [NSString stringWithFormat:value, optionArgument];
        [args insertObject:argValue atIndex:insertIndex];
        [self assertSuiteOutputContains:expected forValue:value withArgs:args];
    }
}

- (void)assertDuplicateOption:(NSString *)optionArgument outputContains:(NSString *)expected
{
    NSArray *args = @[[optionArgument stringByAppendingString:@"=YES"], [optionArgument stringByAppendingString:@"=NO"]];
    [self assertSuiteOutputContains:expected forValue:@"NO" withArgs:args];
}

- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)optionFlag
{
    [self assertSuiteOutputContains:expected forValue:optionFlag withArgs:[NSArray array]];
}

- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)optionFlag withArgs:(NSArray *)args
{
    const struct ct_testcase cases[] = { ct_maketest(test_case) };
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    NSPipe *output = [NSPipe pipe];
    NSFileHandle *readOutput = output.fileHandleForReading;
    const int old_stdout = dup(fileno(stdout));
    dup2(output.fileHandleForWriting.fileDescriptor, fileno(stdout));
    
    const int argc = (int)args.count;
    const char *argv[args.count];
    for (int i = 0; i < argc; ++i) {
        argv[i] = [args[i] UTF8String];
    }
    
    ct_runsuite_withargs(&suite, argc, argv);
    
    fflush(stdout);
    NSData *data = readOutput.availableData;
    dup2(old_stdout, fileno(stdout));
    close(old_stdout);
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange found = [result rangeOfString:expected];
    
    XCTAssertNotNil(result, @"Unexpected nil output string for option flag value \"%@\"", optionFlag);
    XCTAssertNotEqual(NSNotFound, found.location, @"Expected string \"%@\" not found for option flag value \"%@\"", expected, optionFlag);
}

@end
