//
//  CTMakeTestTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/20/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

void faketest(void *context)
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
    ct_test_function expected_function = faketest;
    
    ct_testcase testcase = ct_maketest(faketest);
    
    XCTAssertEqualObjects(@"faketest", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketestfull_CreatesTestCaseWithName
{
    ct_test_function expected_function = faketest;
    
    ct_testcase testcase = ct_maketest_full("fake name", expected_function);
    
    XCTAssertEqualObjects(@"fake name", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketestfull_CreatesTestCase_IfNullArguments
{
    ct_testcase testcase = ct_maketest_full(NULL, NULL);
    
    XCTAssertTrue(testcase.name == NULL, @"Expected NULL name");
    XCTAssertTrue(testcase.test == NULL, @"Expected NULL function");
}

@end
