//
//  CTMakeSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/20/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"
#include <stddef.h>

static void makesuite_fakesetup(void **context)
{
    // do nothing
}

static void makesuite_faketeardown(void **context)
{
    // do nothing
}

static struct ct_testsuite fakesuite_function()
{
    const struct ct_testcase *const cases = NULL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    return ct_makesuite(cases);
#pragma clang diagnostic pop
}

@interface CTMakeSuiteTests : CTTestBase

@end

@implementation CTMakeSuiteTests

- (void)test_ctmakesuite_CreatesTestSuite
{
    const struct ct_testcase faketests[] = {ct_maketest_named("foo", NULL), ct_maketest_named("bar", NULL)},
    // XCTest doesn't like comparing an array to a pointer so get the address of the array
                             *const expected_tests = faketests;
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    
    const struct ct_testsuite testsuite = ct_makesuite(faketests);
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(2u, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuite_UsesFunctionName
{
    const struct ct_testsuite testsuite = fakesuite_function();
    
    XCTAssertEqualObjects([NSString stringWithUTF8String:"fakesuite_function"], [NSString stringWithUTF8String:testsuite.name]);
}

- (void)test_ctmakesuite_CreatesTestSuite_IfNullArguments
{
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    const struct ct_testcase *const cases = NULL;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    const struct ct_testsuite testsuite = ct_makesuite(cases);
#pragma clang diagnostic pop
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertTrue(testsuite.tests == NULL, @"Expected NULL tests");
    XCTAssertEqual(0u, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuitesetup_CreatesTestSuite
{
    const struct ct_testcase faketests[] = {ct_maketest_named("foo", NULL), ct_maketest_named("bar", NULL)},
    // XCTest doesn't like comparing an array to a pointer so get the address of the array
                             *const expected_tests = faketests;
    ct_setupteardown_function *const expected_setup = makesuite_fakesetup;
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    
    const struct ct_testsuite testsuite = ct_makesuite_setup(faketests, expected_setup);
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(2u, testsuite.count);
    XCTAssertEqual(expected_setup, testsuite.setup);
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuitesetup_CreatesTestSuite_WithConstArguments
{
    const struct ct_testcase faketests[] = {ct_maketest_named("foo", NULL), ct_maketest_named("bar", NULL)},
    // XCTest doesn't like comparing an array to a pointer so get the address of the array
                             *const expected_tests = faketests;
    ct_setupteardown_function *const expected_setup = makesuite_fakesetup;
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    
    const struct ct_testsuite testsuite = ct_makesuite_setup(faketests, expected_setup);
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(2u, testsuite.count);
    XCTAssertEqual(expected_setup, testsuite.setup);
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuitesetup_CreatesTestSuite_IfNullArguments
{
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    const struct ct_testcase *const cases = NULL;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    const struct ct_testsuite testsuite = ct_makesuite_setup(cases, NULL);
#pragma clang diagnostic pop
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertTrue(testsuite.tests == NULL, @"Expected NULL tests");
    XCTAssertEqual(0u, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuitesetupteardown_CreatesTestSuite
{
    const struct ct_testcase faketests[] = {ct_maketest_named("foo", NULL), ct_maketest_named("bar", NULL)},
    // XCTest doesn't like comparing an array to a pointer so get the address of the array
                             *const expected_tests = faketests;
    ct_setupteardown_function *const expected_setup = makesuite_fakesetup,
                                *const expected_teardown = makesuite_faketeardown;
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    
    const struct ct_testsuite testsuite = ct_makesuite_setup_teardown(faketests, expected_setup, expected_teardown);
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(2u, testsuite.count);
    XCTAssertEqual(expected_setup, testsuite.setup);
    XCTAssertEqual(expected_teardown, testsuite.teardown);
}

- (void)test_ctmakesuitesetupteardown_CreatesTestSuite_IfNullArguments
{
    NSString *expectedName = [self stringOfExpectedSuiteNameWithSelector:_cmd];
    const struct ct_testcase *const cases = NULL;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    const struct ct_testsuite testsuite = ct_makesuite_setup_teardown(cases, NULL, NULL);
#pragma clang diagnostic pop
    
    XCTAssertEqualObjects(expectedName, [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertTrue(testsuite.tests == NULL, @"Expected NULL tests");
    XCTAssertEqual(0u, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (void)test_ctmakesuitesetupteardownnamed_CreatesTestSuiteWithArguments
{
    const struct ct_testcase faketests[] = {ct_maketest_named("foo", NULL), ct_maketest_named("bar", NULL)},
    // XCTest doesn't like comparing an array to a pointer so get the address of the array
                             *const expected_tests = faketests;
    size_t expected_count = 10;
    ct_setupteardown_function *const expected_setup = makesuite_fakesetup,
                                *const expected_teardown = makesuite_faketeardown;
    
    const struct ct_testsuite testsuite = ct_makesuite_setup_teardown_named("fake suite", expected_count, faketests, expected_setup, expected_teardown);
    
    XCTAssertEqualObjects(@"fake suite", [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(expected_count, testsuite.count);
    XCTAssertEqual(expected_setup, testsuite.setup);
    XCTAssertEqual(expected_teardown, testsuite.teardown);
}

- (void)test_ctmakesuitesetupteardownnamed_CreatesTestSuite_IfNullArguments
{
    const struct ct_testsuite testsuite = ct_makesuite_setup_teardown_named(NULL, 0, NULL, NULL, NULL);
    
    XCTAssertTrue(testsuite.name == NULL, @"Expected NULL name");
    XCTAssertTrue(testsuite.tests == NULL, @"Expected NULL tests");
    XCTAssertEqual(0u, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown");
}

- (NSString *)stringOfExpectedSuiteNameWithSelector:(SEL)selector
{
    return [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass(self.class), NSStringFromSelector(selector)];
}

@end
