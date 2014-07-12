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
    TestClass = NULL;
    
    [super tearDown];
}

- (void)expectAssertionSuccessForResult:(size_t)testResult
{
    XCTAssertEqual(0, testResult);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)expectAssertionFailureForResult:(size_t)testResult
{
    XCTAssertEqual(1, testResult);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
