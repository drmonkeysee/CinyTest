//
//  CTAssertEqualStrTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/20/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "ciny.h"

@interface CTAssertEqualStrTests : XCTestCase

@end

static void *TestClass;

@implementation CTAssertEqualStrTests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
