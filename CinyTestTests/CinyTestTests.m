//
//  CinyTestTests.m
//  CinyTestTests
//
//  Created by Brandon Stansbury on 4/12/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

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

- (void)test_cinytest_SmokeTest
{
    XCTAssertEqual(0, ct_runtests(NULL));
}

@end
