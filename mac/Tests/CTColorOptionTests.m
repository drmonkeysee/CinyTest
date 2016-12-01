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
    [self assertSuiteOutputContains:@"[0;32m1 passed[0m," for:nil];
}

- (void)test_colorizedDisabledByEnv
{
    NSArray *disableValues = [NSArray arrayWithObjects:@"NO", @"no", @"FALSE", @"false", @"0", @"n", @"F", nil];
    for (NSString *value in disableValues) {
        setenv("CINYTEST_COLORIZED", value.UTF8String, 1);
        [self assertSuiteOutputContains:@"1 passed," for:value];
    }
}

- (void)test_colorizedEnabledForPositiveEnvValues
{
    NSArray *randomValues = [NSArray arrayWithObjects:@"YES", @"true", @"blarg", @"", @"1", nil];
    for (NSString *value in randomValues) {
        setenv("CINYTEST_COLORIZED", value.UTF8String, 1);
        [self assertSuiteOutputContains:@"[0;32m1 passed[0m," for:value];
    }
}

- (void)assertSuiteOutputContains:(NSString *)expected for:(NSString *)envValue
{
    const struct ct_testcase cases[] = { ct_maketest(test_case) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    NSPipe *output = [NSPipe pipe];
    NSFileHandle *readOutput = output.fileHandleForReading;
    int old_stdout = dup(fileno(stdout));
    dup2(output.fileHandleForWriting.fileDescriptor, fileno(stdout));
    
    ct_runsuite(&suite);
    
    fflush(stdout);
    NSData *data = readOutput.availableData;
    dup2(old_stdout, fileno(stdout));
    close(old_stdout);
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange found = [result rangeOfString:expected];
    
    XCTAssertNotNil(result, @"Unexpected nil output string for env value \"%@\"", envValue);
    XCTAssertNotEqual(NSNotFound, found.location, @"Expected string \"%@\" not found for env value \"%@\"", expected, envValue);
}

@end
