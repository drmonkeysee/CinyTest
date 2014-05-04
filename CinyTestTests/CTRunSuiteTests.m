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
@property (nonatomic, assign) NSUInteger ignoredTestInvocations;
@property (nonatomic, assign) NSUInteger setupInvocations;
@property (nonatomic, assign) NSInteger testSawContext;
@property (nonatomic, assign) NSInteger teardownSawContext;

@end

static void *TestClass;
static int *FakeContext;
static const int FakeContextValue = 8;

static void record_testcontext_occurrence(void *context, CTRunSuiteTests *testObject)
{
    if (context && *((int *)context) == FakeContextValue) {
        ++testObject.testSawContext;
    } else {
        --testObject.testSawContext;
    }
}

static void passing_test(void *context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.passingTestInvocations;
    record_testcontext_occurrence(context, testObject);
}

static void failing_test(void *context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.failingTestInvocations;
    record_testcontext_occurrence(context, testObject);
    
    ct_assertfail();
}

static void ignored_test(void *context)
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.ignoredTestInvocations;
    record_testcontext_occurrence(context, testObject);
    
    ct_ignore();
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
    struct ct_testsuite suite = ct_makesuite(NULL);
    
    size_t run_result = ct_runsuite(&suite);
    
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
    XCTAssertEqual(0, self.ignoredTestInvocations);
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
    XCTAssertEqual(0, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcaseWithContext
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(2, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfOneTestFails
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertEqual(2, self.passingTestInvocations);
    XCTAssertEqual(1, self.failingTestInvocations);
    XCTAssertEqual(0, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfAllTestsFail
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3, run_result);
    XCTAssertEqual(0, self.passingTestInvocations);
    XCTAssertEqual(3, self.failingTestInvocations);
    XCTAssertEqual(0, self.ignoredTestInvocations);
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
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfAllFailingTests
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_DoesNotIncludeIgnoredTestInFailureCount_IfOneTestIgnored
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, self.passingTestInvocations);
    XCTAssertEqual(0, self.failingTestInvocations);
    XCTAssertEqual(1, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotIncludeIgnoredTestsInFailureCount_IfAllTestsIgnored
{
    struct ct_testcase cases[] = { ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(0, self.passingTestInvocations);
    XCTAssertEqual(0, self.failingTestInvocations);
    XCTAssertEqual(3, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfAllTestsIgnoredWithNoSetupOrTeardown
{
    struct ct_testcase cases[] = { ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfOneIgnoredTest
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfAllIgnoredTests
{
    struct ct_testcase cases[] = { ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfMixtureOfPassingIgnoredFailedTests
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertEqual(1, self.passingTestInvocations);
    XCTAssertEqual(1, self.failingTestInvocations);
    XCTAssertEqual(1, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfMixtureOfPassingIgnoredFailedTests
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfMixtureOfPassingIgnoredFailedTests
{
    struct ct_testcase cases[] = { ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

@end
