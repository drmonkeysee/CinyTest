//
//  CTOutputAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 1/24/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

@interface CTOutputAssertionTestBase : CTTestBase

@property (nonatomic) NSString *envProperty;

- (void)assertDefaultOptionOutputContains:(NSString *)expected;
- (void)assertEnvDisabledOptionOutputContains:(NSString *)expected;
- (void)assertEnvEnabledOptionOutputContains:(NSString *)expected;
- (void)assertArbitraryArgsOptionOutputContains:(NSString *)expected;
- (void)assertArgDisablesOption:(NSString *)optionArgument outputContains:(NSString *)expected;
- (void)assertArgEnablesOption:(NSString *)optionArgument outputContains:(NSString *)expected;
- (void)assertDuplicateOption:(NSString *)optionArgument outputContains:(NSString *)expected;

@end
