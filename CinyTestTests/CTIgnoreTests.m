//
//  CTIgnoreTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/4/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include "ciny.h"

@interface CTIgnoreTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawUnreachableCode;

@end

static void *TestClass;

static void ignore_test_nomessage(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore();
    
    testObject.sawUnreachableCode = YES;
}

static void ignore_test_message(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore("a test message");
    
    testObject.sawUnreachableCode = YES;
}

static void ignore_test_formatmessage(void *context)
{
    CTIgnoreTests *testObject = (__bridge CTIgnoreTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_ignore("a test message with %d format arguments: %f, %s", 3, 1.5, "foo");
    
    testObject.sawUnreachableCode = YES;
}

@implementation CTIgnoreTests

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

- (void)test_ctignore_TerminatesTest_IfGivenNoMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_nomessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

- (void)test_ctignore_TerminatesTest_IfGivenMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_message) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

- (void)test_ctignore_TerminatesTest_IfGivenFormattedMessage
{
    struct ct_testcase cases[] = { ct_maketest(ignore_test_formatmessage) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawUnreachableCode);
}

@end
