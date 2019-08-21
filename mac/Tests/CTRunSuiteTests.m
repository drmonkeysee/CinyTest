//
//  CTRunSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/29/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

#include <stddef.h>
#include <stdlib.h>

@interface CTRunSuiteTests : CTTestBase

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

static void test_setup(void *context[static 1])
{
    CTRunSuiteTests *testObject = (__bridge CTRunSuiteTests *)(TestClass);
    ++testObject.setupInvocations;
    
    FakeContext = malloc(sizeof *FakeContext);
    *FakeContext = FakeContextValue;
    *context = FakeContext;
}

static void test_teardown(void *context[static 1])
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
    FakeContext = NULL;
    
    [super tearDown];
}

- (void)test_ctrunsuite_ReturnsZero_IfSuiteHasNullTestList
{
    const struct ct_testcase * const cases = NULL;
    
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
}

- (void)test_ctrunsuite_InvokesPassingTests_IfValidTestcases
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfNoSetupMethod
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_CreatesTestContext_IfGivenSetupMethod
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup(cases, test_setup);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTeardown_IfSetupAndTeardownMethod
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_GivesTeardownNullContext_IfTeardownButNoSetup
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, NULL, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(0u, self.setupInvocations);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
    XCTAssertEqual(-3, self.teardownSawContext);
}

- (void)test_ctrunsuite_InvokesPassingTests_UpToCount
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown_named("foobar", 2, cases, NULL, NULL);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcase
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_ExecutesTest_IfNullTestName
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest_named(NULL, passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcaseWithContext
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(2, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfOneTestFails
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocations);
    XCTAssertEqual(1u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfAllTestsFail
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3u, run_result);
    XCTAssertEqual(0u, self.passingTestInvocations);
    XCTAssertEqual(3u, self.failingTestInvocations);
    XCTAssertEqual(0u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfAllTestsFailWithNoSetupOrTeardown
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3u, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfOneFailingTest
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfAllFailingTests
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(failing_test), ct_maketest(failing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(3u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_DoesNotIncludeIgnoredTestInFailureCount_IfOneTestIgnored
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(1u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotIncludeIgnoredTestsInFailureCount_IfAllTestsIgnored
{
    const struct ct_testcase cases[] = {ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(0u, self.passingTestInvocations);
    XCTAssertEqual(0u, self.failingTestInvocations);
    XCTAssertEqual(3u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfAllTestsIgnoredWithNoSetupOrTeardown
{
    const struct ct_testcase cases[] = {ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfOneIgnoredTest
{
    const struct ct_testcase cases[] = {ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfAllIgnoredTests
{
    const struct ct_testcase cases[] = {ct_maketest(ignored_test), ct_maketest(ignored_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ctrunsuite_ReturnsFailureCount_IfMixtureOfPassingIgnoredFailedTests
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(1u, self.passingTestInvocations);
    XCTAssertEqual(1u, self.failingTestInvocations);
    XCTAssertEqual(1u, self.ignoredTestInvocations);
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfMixtureOfPassingIgnoredFailedTests
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertTrue(FakeContext == NULL);
    XCTAssertEqual(-3, self.testSawContext);
}

- (void)test_ctrunsuite_PassesContextToTests_IfMixtureOfPassingIgnoredFailedTests
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(ignored_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    const size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ct_runsuite_withargs_Accepts_Commandline_Arguments
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    const char *args[] = {"foo", "bar"};
    
    const size_t run_result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

- (void)test_ct_runsuite_withargs_Handles_NullAndEmpty_Arguments
{
    const struct ct_testcase cases[] = {ct_maketest(failing_test), ct_maketest(passing_test), ct_maketest(passing_test)};
    const struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    const char *args[] = {"foo", NULL, "bar", ""};
    
    const size_t run_result = ct_runsuite_withargs(&suite, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(3u, self.setupInvocations);
    XCTAssertEqual(3, self.testSawContext);
    XCTAssertEqual(3, self.teardownSawContext);
}

@end
