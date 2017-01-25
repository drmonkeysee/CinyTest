//
//  CTOutputAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 1/24/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

@interface CTOutputAssertionTestBase : CTTestBase

- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)colorFlag;
- (void)assertSuiteOutputContains:(NSString *)expected forValue:(NSString *)colorFlag withArgs:(NSArray *)args;

@end
