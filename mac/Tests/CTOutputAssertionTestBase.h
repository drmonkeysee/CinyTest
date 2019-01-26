//
//  CTOutputAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 1/24/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"
#include "ciny.h"

typedef NS_ENUM(NSUInteger, CTOutputComparison) {
    CTOutputContains,
    CTOutputDoesNotContain
};

@interface CTOutputAssertionTestBase : CTTestBase

@property (nonatomic) NSString *envProperty;
@property (nonatomic, assign) ct_test_function *testFunc;

- (void)assertDefault:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertEnvDisabled:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertEnvEnabled:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertEnvInputs:(NSArray *)inputs compare:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertArbitraryArgs:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertArg:(NSString *)optionArgument ifDisabled:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertArg:(NSString *)optionArgument ifEnabled:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertDuplicateArg:(NSString *)optionArgument isDisabled:(CTOutputComparison)compare value:(NSString *)expected;
- (void)assertArg:(NSString *)optionArgument inputs:(NSArray *)inputs compare:(CTOutputComparison)compare value:(NSString *)expected;

@end
