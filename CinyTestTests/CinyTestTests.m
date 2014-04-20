//
//  CinyTestTests.m
//  CinyTestTests
//
//  Created by Brandon Stansbury on 4/12/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

void faketest(void *context)
{
    // do nothing
}

@interface CinyTestTests : XCTestCase

@end

@implementation CinyTestTests

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

@end
