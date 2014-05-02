//
//  CTMakeTestTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/20/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "ciny.h"

static void maketest_faketest(void *context)
{
    // do nothing
}

@interface CTMakeTestTests : XCTestCase

@end

@implementation CTMakeTestTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_ctmaketest_CreatesTestCase
{
    ct_test_function expected_function = maketest_faketest;
    
    struct ct_testcase testcase = ct_maketest(maketest_faketest);
    
    XCTAssertEqualObjects(@"maketest_faketest", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketest_CreatesTestCase_IfNullArguments
{
    struct ct_testcase testcase = ct_maketest(NULL);
    
    XCTAssertEqualObjects(@"NULL", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertTrue(testcase.test == NULL, @"Expected NULL function");
}

- (void)test_ctmaketestfull_CreatesTestCaseWithName
{
    ct_test_function expected_function = maketest_faketest;
    
    struct ct_testcase testcase = ct_maketest_full("fake name", expected_function);
    
    XCTAssertEqualObjects(@"fake name", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketestfull_CreatesTestCase_IfNullArguments
{
    struct ct_testcase testcase = ct_maketest_full(NULL, NULL);
    
    XCTAssertTrue(testcase.name == NULL, @"Expected NULL name");
    XCTAssertTrue(testcase.test == NULL, @"Expected NULL function");
}

@end
