//
//  CTRunSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/29/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

@interface CTRunSuiteTests : XCTestCase

@property (nonatomic, assign) BOOL testContextIsNull;

@end

static void *test_class;

static size_t passing_test_invocations;
static void passing_test(void *context)
{
    ++passing_test_invocations;
    CTRunSuiteTests *testInstance = (__bridge CTRunSuiteTests *)(test_class);
    if (context && testInstance.testContextIsNull) {
        testInstance.testContextIsNull = NO;
    }
}

@implementation CTRunSuiteTests

- (void)setUp
{
    [super setUp];
    
    test_class = (__bridge void *)(self);
    
    passing_test_invocations = 0;
}

- (void)tearDown
{
    test_class = NULL;
    
    [super tearDown];
}

- (void)test_ctrunsuite_ReturnsZero_IfSuiteHasNullTestList
{
    struct ct_testsuite suite_to_run = ct_makesuite(NULL);
    
    size_t run_result = ct_runsuite(&suite_to_run);
    
    XCTAssertEqual(0, run_result);
}

- (void)test_ctrunsuite_InvokesPassingTests_IfValidTestcases
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, passing_test_invocations);
}

- (void)test_ctrunsuite_PassesNullTestContext_IfNoSetupMethod
{
    self.testContextIsNull = YES;
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.testContextIsNull);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcase
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, passing_test_invocations);
}

@end
