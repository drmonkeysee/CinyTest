//
//  CTRunTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 12/31/16.
//  Copyright © 2016 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

#include <stddef.h>
#include <stdlib.h>

@interface CTRunTests : CTTestBase

@property (nonatomic, assign) NSUInteger passingTestInvocationsA;
@property (nonatomic, assign) NSUInteger failingTestInvocationsA;
@property (nonatomic, assign) NSUInteger ignoredTestInvocationsA;
@property (nonatomic, assign) NSUInteger setupInvocationsA;
@property (nonatomic, assign) NSInteger testSawContextA;
@property (nonatomic, assign) NSInteger teardownSawContextA;

@property (nonatomic, assign) NSUInteger passingTestInvocationsB;
@property (nonatomic, assign) NSUInteger failingTestInvocationsB;
@property (nonatomic, assign) NSUInteger ignoredTestInvocationsB;
@property (nonatomic, assign) NSUInteger setupInvocationsB;
@property (nonatomic, assign) NSInteger testSawContextB;
@property (nonatomic, assign) NSInteger teardownSawContextB;

@end

static void *TestClass;

static int *FakeContextA, *FakeContextB;
static constexpr int FakeContextAValue = 8, FakeContextBValue = -5;

static void record_testcontext_occurrenceA(void *context,
                                           CTRunTests *testObject)
{
    if (context && *(int *)context == FakeContextAValue) {
        ++testObject.testSawContextA;
    } else {
        --testObject.testSawContextA;
    }
}

static void record_testcontext_occurrenceB(void *context,
                                           CTRunTests *testObject)
{
    if (context && *(int *)context == FakeContextBValue) {
        ++testObject.testSawContextB;
    } else {
        --testObject.testSawContextB;
    }
}

static void passing_testA(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.passingTestInvocationsA;
    record_testcontext_occurrenceA(context, testObject);
}

static void passing_testB(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.passingTestInvocationsB;
    record_testcontext_occurrenceB(context, testObject);
}

static void failing_testA(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.failingTestInvocationsA;
    record_testcontext_occurrenceA(context, testObject);
    
    ct_assertfail();
}

static void failing_testB(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.failingTestInvocationsB;
    record_testcontext_occurrenceB(context, testObject);
    
    ct_assertfail();
}

static void ignored_testA(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.ignoredTestInvocationsA;
    record_testcontext_occurrenceA(context, testObject);
    
    ct_ignore();
}

static void ignored_testB(void *context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.ignoredTestInvocationsB;
    record_testcontext_occurrenceB(context, testObject);
    
    ct_ignore();
}

static void test_setupA(void **context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.setupInvocationsA;
    
    FakeContextA = malloc(sizeof *FakeContextA);
    *FakeContextA = FakeContextAValue;
    *context = FakeContextA;
}

static void test_setupB(void **context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    ++testObject.setupInvocationsB;
    
    FakeContextB = malloc(sizeof *FakeContextB);
    *FakeContextB = FakeContextBValue;
    *context = FakeContextB;
}

static void test_teardownA(void **context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    
    if (*context && *((int *)*context) == FakeContextAValue) {
        ++testObject.teardownSawContextA;
    } else {
        --testObject.teardownSawContextA;
    }
}

static void test_teardownB(void **context)
{
    CTRunTests *testObject = (__bridge CTRunTests *)(TestClass);
    
    if (*context && *((int *)*context) == FakeContextBValue) {
        ++testObject.teardownSawContextB;
    } else {
        --testObject.teardownSawContextB;
    }
}

@implementation CTRunTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
    FakeContextA = FakeContextB = nullptr;
}

- (void)tearDown
{
    TestClass = nullptr;
    
    free(FakeContextA);
    FakeContextA = nullptr;
    
    free(FakeContextB);
    FakeContextB = nullptr;
    
    [super tearDown];
}

- (void)test_ctrun_ReturnsZero_IfNullSuites
{
    const struct ct_testsuite *suites = nullptr;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    const size_t run_result = ct_run(suites);
#pragma clang diagnostic pop
    
    XCTAssertEqual(0u, run_result);
}

- (void)test_ctrun_ReturnsZero_IfSuitesHaveNullTestLists
{
    const struct ct_testcase *cases = nullptr;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsizeof-pointer-div"
    const struct ct_testsuite suites[] = {ct_makesuite(cases), ct_makesuite(cases)};
#pragma clang diagnostic pop

    const size_t run_result = ct_run(suites);
    
    XCTAssertEqual(0u, run_result);
}

- (void)test_ctrun_Invokes_All_Suites_NoSetupTeardown
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {ct_makesuite(casesA), ct_makesuite(casesB)};
    
    const size_t run_result = ct_run(suites);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertTrue(FakeContextA == nullptr);
    XCTAssertTrue(FakeContextB == nullptr);
    XCTAssertEqual(-4, self.testSawContextA);
    XCTAssertEqual(-3, self.testSawContextB);
}

- (void)test_ctrun_Invokes_All_Suites_OneSetupTeardown
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA), ct_makesuite(casesB)};
    
    const size_t run_result = ct_run(suites);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertTrue(FakeContextB == nullptr);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(-3, self.testSawContextB);
}

- (void)test_ctrun_Invokes_All_Suites_AllSetupTeardown
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA),
        ct_makesuite_setup_teardown(casesB, test_setupB, test_teardownB)
    };
    
    const size_t run_result = ct_run(suites);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(3, self.testSawContextB);
}

- (void)test_ctrun_SumsAllFailures
{
    const struct ct_testcase casesA[] = {
        ct_maketest(failing_testA),
        ct_maketest(failing_testA),
        ct_maketest(failing_testA),
        ct_maketest(failing_testA),
    },
    casesB[] = {
        ct_maketest(failing_testB),
        ct_maketest(failing_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {ct_makesuite(casesA), ct_makesuite(casesB)};
    
    const size_t run_result = ct_run(suites);
    
    XCTAssertEqual(7u, run_result);
    XCTAssertEqual(0u, self.passingTestInvocationsA);
    XCTAssertEqual(4u, self.failingTestInvocationsA);
    XCTAssertEqual(0u, self.ignoredTestInvocationsA);
    XCTAssertEqual(0u, self.passingTestInvocationsB);
    XCTAssertEqual(3u, self.failingTestInvocationsB);
    XCTAssertEqual(0u, self.ignoredTestInvocationsB);
}

- (void)test_ctrun_withargs_Accepts_Commandline_Arguments
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA),
        ct_makesuite_setup_teardown(casesB, test_setupB, test_teardownB),
    };
    char *args[] = {"foo", "bar"};
    
    const size_t run_result = ct_run_withargs(suites, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(3, self.testSawContextB);
}

- (void)test_ctrun_withargs_Handles_NullAndEmpty_Arguments
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA),
        ct_makesuite_setup_teardown(casesB, test_setupB, test_teardownB),
    };
    char *args[] = {"foo", nullptr, "bar", ""};
    
    const size_t run_result = ct_run_withargs(suites, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(3, self.testSawContextB);
}

- (void)test_ctruncount_withargs_Accepts_Commandline_Arguments
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA),
        ct_makesuite_setup_teardown(casesB, test_setupB, test_teardownB),
    };
    char *args[] = {"foo", "bar"};
    
    const size_t run_result = ct_runcount_withargs(sizeof suites / sizeof suites[0], suites, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(2u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(1u, self.passingTestInvocationsB);
    XCTAssertEqual(1u, self.failingTestInvocationsB);
    XCTAssertEqual(1u, self.ignoredTestInvocationsB);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(3, self.testSawContextB);
}

- (void)test_ctruncount_withargs_Runs_Count_Suites
{
    const struct ct_testcase casesA[] = {
        ct_maketest(passing_testA),
        ct_maketest(failing_testA),
        ct_maketest(passing_testA),
        ct_maketest(ignored_testA),
    },
    casesB[] = {
        ct_maketest(passing_testB),
        ct_maketest(ignored_testB),
        ct_maketest(failing_testB),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown(casesA, test_setupA, test_teardownA),
        ct_makesuite_setup_teardown(casesB, test_setupB, test_teardownB),
    };
    char *args[] = {"foo", nullptr, "bar", ""};
    
    const size_t run_result = ct_runcount_withargs(1, suites, sizeof args / sizeof args[0], args);
    
    XCTAssertEqual(1u, run_result);
    XCTAssertEqual(2u, self.passingTestInvocationsA);
    XCTAssertEqual(1u, self.failingTestInvocationsA);
    XCTAssertEqual(1u, self.ignoredTestInvocationsA);
    XCTAssertEqual(0u, self.passingTestInvocationsB);
    XCTAssertEqual(0u, self.failingTestInvocationsB);
    XCTAssertEqual(0u, self.ignoredTestInvocationsB);
    XCTAssertEqual(4, self.testSawContextA);
    XCTAssertEqual(0, self.testSawContextB);
}

@end
