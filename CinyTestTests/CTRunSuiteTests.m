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

@property (nonatomic, assign) BOOL testContextIsNull;
@property (nonatomic, assign) NSUInteger passingTestInvocations;
@property (nonatomic, assign) NSUInteger setupInvocations;
@property (nonatomic, assign) NSUInteger teardownInvocations;

@end

struct testcontext {
    size_t setup_calls;
    size_t test_calls;
    size_t teardown_calls;
};

static void *test_class;
static struct testcontext *fake_context;

static void passing_test(void *context)
{
    CTRunSuiteTests *testInstance = (__bridge CTRunSuiteTests *)(test_class);
    ++testInstance.passingTestInvocations;
    
    if (context) {
        if (testInstance.testContextIsNull) {
            testInstance.testContextIsNull = NO;
        } else {
            ++((struct testcontext *)context)->test_calls;
        }
    } else {
        if (!testInstance.testContextIsNull) {
            testInstance.testContextIsNull = YES;
        }
    }
}

static void test_setup(void **context)
{
    CTRunSuiteTests *testInstance = (__bridge CTRunSuiteTests *)(test_class);
    ++testInstance.setupInvocations;
    
    fake_context = calloc(1, sizeof *fake_context);
    fake_context->setup_calls = 1;
    *context = fake_context;
}

static void test_teardown(void **context)
{
    CTRunSuiteTests *testInstance = (__bridge CTRunSuiteTests *)(test_class);
    ++testInstance.teardownInvocations;
    
    if (*context) {
        if (testInstance.testContextIsNull) {
            testInstance.testContextIsNull = NO;
        } else {
            ++((struct testcontext *)*context)->teardown_calls;
        }
    } else {
        if (!testInstance.testContextIsNull) {
            testInstance.testContextIsNull = YES;
        }
    }
}

@implementation CTRunSuiteTests

- (void)setUp
{
    [super setUp];
    
    test_class = (__bridge void *)(self);
    
    fake_context = NULL;
}

- (void)tearDown
{
    test_class = NULL;
    free(fake_context);
    
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
}

- (void)test_ctrunsuite_DoesNotCreateTestContext_IfNoSetupMethod
{
    self.testContextIsNull = NO;
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.testContextIsNull);
    XCTAssertTrue(fake_context == NULL);
}

- (void)test_ctrunsuite_CreatesTestContext_IfGivenSetupMethod
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup(cases, test_setup);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.passingTestInvocations);
    XCTAssertEqual(1, fake_context->setup_calls);
    XCTAssertEqual(1, fake_context->test_calls);
    XCTAssertEqual(0, fake_context->teardown_calls);
}

- (void)test_ctrunsuite_PassesContextToTeardown_IfSetupAndTeardownMethod
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, test_setup, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(3, self.setupInvocations);
    XCTAssertEqual(3, self.passingTestInvocations);
    XCTAssertEqual(3, self.teardownInvocations);
    XCTAssertEqual(1, fake_context->setup_calls);
    XCTAssertEqual(1, fake_context->test_calls);
    XCTAssertEqual(1, fake_context->teardown_calls);
}

- (void)test_ctrunsuite_GivesTeardownNullContext_IfTeardownButNoSetup
{
    self.testContextIsNull = NO;
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite_setup_teardown(cases, NULL, test_teardown);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(0, self.setupInvocations);
    XCTAssertEqual(3, self.passingTestInvocations);
    XCTAssertEqual(3, self.teardownInvocations);
    XCTAssertTrue(self.testContextIsNull);
    XCTAssertTrue(fake_context == NULL);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcase
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, self.passingTestInvocations);
}

@end
