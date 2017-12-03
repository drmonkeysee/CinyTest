//
//  CTFilterOptionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 12/2/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

typedef NS_ENUM(NSUInteger, RUN_TEST_FLAGS) {
    RUN_TEST_NONE = 0,
    RUN_TEST_FOOBAR = 1 << 0,
    RUN_TEST_BARFOO = 1 << 1,
    RUN_TEST_BORT = 1 << 2,
    RUN_TEST_BART = 1 << 3,
    RUN_TEST_TITLE_BART = 1 << 4,
    RUN_TEST_EBERT = 1 << 5,
    RUN_TEST_REPETITIVE = 1 << 6,
    RUN_TEST_EXTENDED = 1 << 7,
    RUN_TEST_EAST_ASIAN = 1 << 8,
    RUN_TEST_HORSE = 1 << 9,
    RUN_TEST_ALL = RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART | RUN_TEST_EBERT | RUN_TEST_REPETITIVE | RUN_TEST_EXTENDED | RUN_TEST_EAST_ASIAN | RUN_TEST_HORSE
};

@interface CTFilterOptionTestBase : CTTestBase

@property (nonatomic) NSString *envProperty;

- (void)assertFilters:(NSArray *)filters suite1Expected:(RUN_TEST_FLAGS)suite1Expected suite2Expected:(RUN_TEST_FLAGS)suite2Expected;

@end
