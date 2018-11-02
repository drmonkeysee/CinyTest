//
//  CTOutputAssertionTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 1/24/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTOutputAssertionTestBase.h"
#include <stddef.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>

static void test_case(void *context)
{
    ct_asserttrue(true, "true test");
}

@implementation CTOutputAssertionTestBase

- (void)setUp
{
    [super setUp];
    
    self.testFunc = test_case;
    unsetenv(self.envProperty.UTF8String);
}

- (void)tearDown
{
    unsetenv(self.envProperty.UTF8String);
    self.testFunc = NULL;
    
    [super tearDown];
}

- (void)assertDefault:(CTOutputComparison)compare value:(NSString *)expected
{
    [self assertSuite:compare value:expected forOption:nil];
}

- (void)assertEnvDisabled:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *disableValues = @[@"NO", @"no", @"FALSE", @"false", @"0", @"n", @"F"];
    [self assertEnvInputs:disableValues compare:compare value:expected];
}

- (void)assertEnvEnabled:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *randomValues = @[@"YES", @"true", @"blarg", @"", @"''", @"\"\"", @"1"];
    [self assertEnvInputs:randomValues compare:compare value:expected];
}

- (void)assertEnvInputs:(NSArray *)inputs compare:(CTOutputComparison)compare value:(NSString *)expected
{
    for (NSString *value in inputs) {
        setenv(self.envProperty.UTF8String, value.UTF8String, 1);
        [self assertSuite:compare value:expected forOption:value];
    }
}

- (void)assertArbitraryArgs:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *args = @[@"my-program", @"--foo=1", @"-v", @"", @"--ct-somethingelse=NO"];
    [self assertSuite:compare value:expected forOption:nil withArgs:args];
}

- (void)assertArg:(NSString *)optionArgument ifDisabled:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *disableValues = @[@"NO", @"no", @"FALSE", @"false", @"0", @"N", @"f"];
    [self assertArg:optionArgument inputs:disableValues compare:compare value:expected];
}

- (void)assertArg:(NSString *)optionArgument ifEnabled:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *randomValues = @[@"YES", @"true", @"blarg", @"", @"''", @"\"\"", @"%@", @"1"];
    [self assertArg:optionArgument inputs:randomValues compare:compare value:expected];
    // verify form "--optionArgument" with no value specified
    [self assertSuite:compare value:expected forOption:optionArgument withArgs:@[optionArgument]];
}

- (void)assertDuplicateArg:(NSString *)optionArgument isDisabled:(CTOutputComparison)compare value:(NSString *)expected
{
    NSArray *args = @[[optionArgument stringByAppendingString:@"=YES"], [optionArgument stringByAppendingString:@"=NO"]];
    [self assertSuite:compare value:expected forOption:@"NO" withArgs:args];
}

- (void)assertArg:(NSString *)optionArgument inputs:(NSArray *)inputs compare:(CTOutputComparison)compare value:(NSString *)expected
{
    for (NSString *value in inputs) {
        NSMutableArray *args = [NSMutableArray arrayWithObjects:@"my-program", @"--foo=1", @"-v", @"--ct-somethingelse=NO", nil];
        const uint32_t insertIndex = arc4random_uniform((uint32_t)args.count);
        NSString *argValue = [NSString stringWithFormat:@"%@=%@", optionArgument, value];
        [args insertObject:argValue atIndex:insertIndex];
        [self assertSuite:compare value:expected forOption:value withArgs:args];
    }
}

- (void)assertSuite:(CTOutputComparison)compare value:(NSString *)expected forOption:(NSString *)optionFlag
{
    [self assertSuite:compare value:expected forOption:optionFlag withArgs:@[]];
}

- (void)assertSuite:(CTOutputComparison)compare value:(NSString *)expected forOption:(NSString *)optionFlag withArgs:(NSArray *)args
{
    const struct ct_testcase cases[] = {ct_maketest(self.testFunc)};
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
    if (compare == CTOutputContains) {
        XCTAssertNotEqual(NSNotFound, found.location, @"Expected string \"%@\" not found for option flag value \"%@\"", expected, optionFlag);
    } else {
        XCTAssertEqual(NSNotFound, found.location, @"Unexpected string \"%@\" found for option flag value \"%@\"", expected, optionFlag);
    }
}

@end
