//
//  CTAssertionTestBase.m
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"

void *TestClass;

@implementation CTAssertionTestBase

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = nullptr;
    
    [super tearDown];
}

@end
