//
//  CTColorOptionTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 11/27/16.
//  Copyright © 2016 Brandon Stansbury. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "ciny.h"

@interface CTColorOptionTests : XCTestCase

@end

static void test_case(void *context)
{
    ct_asserttrue(true, "true test");
}

@implementation CTColorOptionTests

- (void)setUp
{
    [super setUp];
    
    unsetenv("CINYTEST_COLORIZED");
}

- (void)tearDown
{
    unsetenv("CINYTEST_COLORIZED");
    
    [super tearDown];
}

- (void)test_colorizedEnabledByDefault
{
    [self assertSuiteOutputContains:@"[0;32m1 passed[0m," forValue:nil];
}

- (void)test_colorizedDisabledByEnv
{
    NSArray *disableValues = @[@"NO", @"no", @"FALSE", @"false", @"0", @"n", @"F"];
    for (NSString *value in disableValues) {
        setenv("CINYTEST_COLORIZED", value.UTF8String, 1);
        [self assertSuiteOutputContains:@"1 passed," forValue:value];
    }
}

- (void)test_colorizedEnabledForPositiveEnvValues
{
    NSArray *randomValues = @[@"YES", @"true", @"blarg", @"", @"1"];
    for (NSString *value in randomValues) {
        setenv("CINYTEST_COLORIZED", value.UTF8String, 1);
        [self assertSuiteOutputContains:@"[0;32m1 passed[0m," forValue:value];
    }
}

- (void)test_colorizedEnabledWithArbitraryArgs
{
    NSArray *args = @[@"my-program", @"--foo=1", @"-v", @"", @"--ct-somethingelse=NO"];
    [self assertSuiteOutputContains:@"[0;32m1 passed[0m," forValue:nil withArgs:args];
}

- (void)test_colorizedDisabledWithCommandLineArg
{
    NSArray *disableValues = @[@"--ct-colorized=NO", @"--ct-colorized=no", @"--ct-colorized=FALSE", @"--ct-colorized=false", @"--ct-colorized=0", @"--ct-colorized=N", @"--ct-colorized=f"];
    for (NSString *value in disableValues) {
        NSMutableArray *args = [NSMutableArray arrayWithObjects:@"my-program", @"--foo=1", @"-v", @"--ct-somethingelse=NO", nil];
        uint32_t insertIndex = arc4random_uniform((uint32_t)args.count);
        [args insertObject:value atIndex:insertIndex];
        [self assertSuiteOutputContains:@"1 passed," forValue:value withArgs:args];
    }
}

- (void)test_colorizedEnabledWithPositiveCommandLineArg
{
    NSArray *randomValues = @[@"--ct-colorized=YES", @"--ct-colorized=true", @"--ct-colorized=blarg", @"--ct-colorized=", @"--ct-colorized", @"--ct-colorized=1"];
    for (NSString *value in randomValues) {
        NSMutableArray *args = [NSMutableArray arrayWithObjects:@"my-program", @"--foo=1", @"-v", @"--ct-somethingelse=NO", nil];
        uint32_t insertIndex = arc4random_uniform((uint32_t)args.count);
        [args insertObject:value atIndex:insertIndex];
        [self assertSuiteOutputContains:@"[0;32m1 passed[0m," forValue:value withArgs:args];
    }
}

- (void)test_colorizedHandlesDuplicateCommandLineArgs
{
    NSArray *args = @[@"--ct-colorized=NO", @"--ct-colorized=YES"];
    [self assertSuiteOutputContains:@"1 passed," forValue:nil withArgs:args];
}

- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)colorFlag
{
    [self assertSuiteOutputContains:expected forValue:colorFlag withArgs:[NSArray array]];
}

- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)colorFlag withArgs:(NSArray *)args
{
    const struct ct_testcase cases[] = { ct_maketest(test_case) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    NSPipe *output = [NSPipe pipe];
    NSFileHandle *readOutput = output.fileHandleForReading;
    int old_stdout = dup(fileno(stdout));
    dup2(output.fileHandleForWriting.fileDescriptor, fileno(stdout));
    
    int argc = (int)args.count;
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
    
    XCTAssertNotNil(result, @"Unexpected nil output string for color flag value \"%@\"", colorFlag);
    XCTAssertNotEqual(NSNotFound, found.location, @"Expected string \"%@\" not found for color flag value \"%@\"", expected, colorFlag);
}

@end
