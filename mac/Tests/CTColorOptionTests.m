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
    [self assertSuiteOutputContains:@"[0;32m1 passed[0m,"];
}

- (void)test_colorizedDisabledByEnv
{
    setenv("CINYTEST_COLORIZED", "NO", 1);
    
    [self assertSuiteOutputContains:@"1 passed,"];
}

#define TEST_RESULT_SIZE 512u

- (void)assertSuiteOutputContains:(NSString *)expected
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
    
    XCTAssertNotNil(result);
    XCTAssertNotEqual(NSNotFound, found.location);
}

@end
