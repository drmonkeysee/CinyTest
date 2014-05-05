//
//  CTAssertFailTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/4/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "ciny.h"

@interface CTAssertFailTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawUnreachableCode;

@end

static void *TestClass;

static void fail_test_nomessage(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail();
    
    testObject.sawUnreachableCode = YES;
}

static void fail_test_message(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail("a test message");
    
    testObject.sawUnreachableCode = YES;
}

static void fail_test_formatmessage(void *context)
{
    CTAssertFailTests *testObject = (__bridge CTAssertFailTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertfail("a test message with %d format arguments: %f, %s", 3, 1.5, "foo");
    
    testObject.sawUnreachableCode = YES;
}

@implementation CTAssertFailTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;
    
    [super tearDown];
}

- (void)test_ctassertfail_TerminatesTest_IfGivenNoMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_nomessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

- (void)test_ctassertfail_TerminatesTest_IfGivenMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_message) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

- (void)test_ctassertfail_TerminatesTest_IfGivenFormattedMessage
{
    struct ct_testcase cases[] = { ct_maketest(fail_test_formatmessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

@end
