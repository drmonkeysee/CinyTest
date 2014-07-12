//
//  CTAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>

extern void *TestClass;

@interface CTAssertionTestBase : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;

- (void)expectAssertionSuccessForResult:(size_t)testResult;
- (void)expectAssertionFailureForResult:(size_t)testResult;

@end
