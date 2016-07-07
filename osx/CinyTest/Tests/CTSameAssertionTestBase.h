//
//  CTSameAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"

@interface CTSameAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) void *expectedPointer;
@property (nonatomic, assign) void *actualPointer;

@end
