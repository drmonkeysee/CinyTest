//
//  CTRunSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/29/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <stdlib.h>
#include "ciny.h"

@interface CTRunSuiteTests : XCTestCase

@property (nonatomic, assign) NSUInteger passingTestInvocations;
@property (nonatomic, assign) NSUInteger failingTestInvocations;
@property (nonatomic, assign) NSUInteger setupInvocations;
@property (nonatomic, assign) NSUInteger teardownInvocations;
@property (nonatomic, assign) NSInteger testSawContext;
@property (nonatomic, assign) NSInteger teardownSawContext;

@end

static void *TestClass;
static int *FakeContext;
static const int FakeContextValue = 8;

static void passing_test(void *context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.passingTestInvocations;
    
    if (context && *((int *)context) == FakeContextValue) {
        ++testObject.testSawContext;
    } else {
        --testObject.testSawContext;
    }
}

static void failing_test(void *context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.failingTestInvocations;
    
    if (context && *((int *)context) == FakeContextValue) {
        ++testObject.testSawContext;
    } else {
        --testObject.testSawContext;
    }
    
    ct_assertfail();
}

static void test_setup(void **context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.setupInvocations;
    
    FakeContext = malloc(sizeof *FakeContext);
    *FakeContext = FakeContextValue;
    *context = FakeContext;
}

static void test_teardown(void **context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.teardownInvocations;
    
    if (*context && *((int *)*context) == FakeContextValue) {
        ++testObject.teardownSawContext;
    } else {
        --testObject.teardownSawContext;
    }
}

@implementation CTRunSuiteTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
    FakeContext = NULL;
}

- (void)tearDown
{
    TestClass = NULL;
    free(FakeContext);
    
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
    XCTAssertEqual(3, self.passingTestInvocations);
    XCTAssertEqual(0, self.failingTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfNoSetupMethod
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_CreatesTestContext_IfGivenSetupMethod
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup(cases, test_setup);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTeardown_IfSetupAndTeardownMethod
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.teardownInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_GivesTeardownNullContext_IfTeardownButNoSetup
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, NULL, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(0, self.setupInvocations);
    XCTAssertEqual(3, self.teardownInvocations);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
    XCTAssertEqual(-3, self.teardownSawContext);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcase
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, self.passingTestInvocations);
    XCTAssertEqual(0, self.failingTestInvocations);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcaseWithContext
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, self.setupInvocations);
    XCTAssertEqual(2, self.teardownInvocations);
    XCTAssertEqual(2, self.testSawContext);
    XCTAssertEqual(2, self.teardownSawContext);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfOneTestFails
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertEqual(2, self.passingTestInvocations);
    XCTAssertEqual(1, self.failingTestInvocations);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfAllTestsFail
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3, run_result);
    XCTAssertEqual(0, self.passingTestInvocations);
    XCTAssertEqual(3, self.failingTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfAllTestsFailWithNoSetupOrTeardown
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfOneFailingTest
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(2, self.teardownInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(2, self.teardownSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfAllFailingTests
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(0, self.teardownInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(0, self.teardownSawContext);
}

@end
