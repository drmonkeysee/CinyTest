//
//  CTIncludeOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 9/21/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTFilterOptionTestBase.h"

#include <stdlib.h>

@interface CTIncludeOptionTests : CTFilterOptionTestBase

@end

@implementation CTIncludeOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_INCLUDE";
        return self;
    }
    return nil;
}

- (void)test_AllTestsRun_IfNoFilter
{
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include="] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_AllTestsRun_IfSimpleWildcard
{
    [self assertFilters:@[@"--ct-include=*"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_ExactPatternMatch
{
    [self assertFilters:@[@"--ct-include=suite_far:test_bort"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
}

- (void)test_NoTestsRun_IfExactMatchHasWhitespace
{
    [self assertFilters:@[@"--ct-include=suite_far:test_bort "] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include= suite_far:test_bort"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include= suite_far:test_bort "] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_SingleSuitePatterns
{
    [self assertFilters:@[@"--ct-include=suite_far:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_far:*"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_NONE];
}

- (void)test_SingleTestPatterns
{
    [self assertFilters:@[@"--ct-include=:test_bort"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BORT];
    [self assertFilters:@[@"--ct-include=*:test_bort"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BORT];
}

- (void)test_WildcardPatterns
{
    [self assertFilters:@[@"--ct-include=*bar*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=*foo"] suite1Expected:RUN_TEST_BARFOO suite2Expected:RUN_TEST_BARFOO];
    [self assertFilters:@[@"--ct-include=suite_f*"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:*foo*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO suite2Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO];
    [self assertFilters:@[@"--ct-include=*far:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:test*b*rt"] suite1Expected:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_EBERT suite2Expected:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_EBERT];
    [self assertFilters:@[@"--ct-include=suite_bar:test_*t"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART | RUN_TEST_EBERT];
    [self assertFilters:@[@"--ct-include=suite_bar:test_**bar"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_FOOBAR];
}

// verify wildcards do not prematurely fail when partial match is found earlier in test name
- (void)test_WildcardPatterns_WithPartialMatches
{
    // partial match on two e's in test_eb
    [self assertFilters:@[@"--ct-include=*ert*"] suite1Expected:RUN_TEST_EBERT suite2Expected:RUN_TEST_EBERT];
    // partial match on e in eb following test_
    [self assertFilters:@[@"--ct-include=:test_*ert*"] suite1Expected:RUN_TEST_EBERT suite2Expected:RUN_TEST_EBERT];
    // many partial matches on ed throughout the name
    [self assertFilters:@[@"--ct-include=:*eder*"] suite1Expected:RUN_TEST_REPETITIVE suite2Expected:RUN_TEST_REPETITIVE];
    // many partial matches on ed but only the end of string matters
    [self assertFilters:@[@"--ct-include=:*ed"] suite1Expected:RUN_TEST_REPETITIVE suite2Expected:RUN_TEST_REPETITIVE];
    // two matches on te but only the beginning of string matters
    [self assertFilters:@[@"--ct-include=:te*"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    // many partial matches on te and ed but requiring beginning and end
    [self assertFilters:@[@"--ct-include=:te*ed"] suite1Expected:RUN_TEST_REPETITIVE suite2Expected:RUN_TEST_REPETITIVE];
    // many partial matches on ed including the end
    [self assertFilters:@[@"--ct-include=:*ed*ed"] suite1Expected:RUN_TEST_REPETITIVE suite2Expected:RUN_TEST_REPETITIVE];
}

- (void)test_WildcardLetterPatterns
{
    [self assertFilters:@[@"--ct-include=:test_b?rt"] suite1Expected:RUN_TEST_BORT | RUN_TEST_BART suite2Expected:RUN_TEST_BORT | RUN_TEST_BART];
    [self assertFilters:@[@"--ct-include=suite_bar:test_b?rt"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BORT | RUN_TEST_BART];
    [self assertFilters:@[@"--ct-include=suite_bar:test_?art"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BART | RUN_TEST_TITLE_BART];
    [self assertFilters:@[@"--ct-include=suite_?ar:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=suite_?ar:test_foobar"] suite1Expected:RUN_TEST_FOOBAR suite2Expected:RUN_TEST_FOOBAR];
    [self assertFilters:@[@"--ct-include=:test_??rt"] suite1Expected:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART suite2Expected:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART];
}

- (void)test_NoTestsRun_IfNoPatternMatch
{
    [self assertFilters:@[@"--ct-include= "] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=foo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=*blarg*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:test_f?rt"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_NoTestsRun_IfTooManyTargetDelimiters
{
    [self assertFilters:@[@"--ct-include=suite_foo:test_foobar:test_barfoo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_foo:suite_bar:test_barfoo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_foo:test*:*foo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_MixWildcardLetterAndWildcard
{
    [self assertFilters:@[@"--ct-include=suite_?ar:*foo*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO suite2Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO];
}

- (void)test_ExtendedCharacters
{
    [self assertFilters:@[@"--ct-include=suite_far:test_èxtended_chærs"] suite1Expected:RUN_TEST_EXTENDED suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=*æ*"] suite1Expected:RUN_TEST_EXTENDED suite2Expected:RUN_TEST_EXTENDED];
}

- (void)test_HighBMPCharacters
{
    [self assertFilters:@[@"--ct-include=suite_far:test_测试漢"] suite1Expected:RUN_TEST_EAST_ASIAN suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=*试*"] suite1Expected:RUN_TEST_EAST_ASIAN suite2Expected:RUN_TEST_EAST_ASIAN];
}

- (void)test_EmojiCharacters
{
    [self assertFilters:@[@"--ct-include=suite_far:test_🐴🐎"] suite1Expected:RUN_TEST_HORSE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=*🐴*"] suite1Expected:RUN_TEST_HORSE suite2Expected:RUN_TEST_HORSE];
}

- (void)test_Wildcards_DoNotMatch_ExtendedCharacters
{
    [self assertFilters:@[@"--ct-include=:test_?xtended_chærs"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:test_测试?"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=:test_🐴?"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_MultipleMatchedExpressions
{
    [self assertFilters:@[@"--ct-include=suite_far:,suite_bar:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=:test_barfoo,:test_bort"] suite1Expected:RUN_TEST_BARFOO | RUN_TEST_BORT suite2Expected:RUN_TEST_BARFOO | RUN_TEST_BORT];
    [self assertFilters:@[@"--ct-include=suite_far:,:test_bort"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_BORT];
    [self assertFilters:@[@"--ct-include=:test_bort,suite_far:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_BORT];
    [self assertFilters:@[@"--ct-include=suite_far:test_bort,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BARFOO];
}

- (void)test_FiltersIgnored_IfEmptyMultipleExpressions
{
    [self assertFilters:@[@"--ct-include=,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BARFOO];
    [self assertFilters:@[@"--ct-include=suite_far:test_bort,"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=,"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=:,"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=,:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-include=:,:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_MultipleExactMatches_ContainingWhitespace
{
    [self assertFilters:@[@"--ct-include=suite_far:test_bort, suite_bar:test_barfoo"] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=suite_far:test_bort ,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BARFOO];
    [self assertFilters:@[@"--ct-include=suite_far:test_bort , suite_bar:test_barfoo"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_RejectTooManyTargetDelimiters_InMultiExpressionFilter
{
    [self assertFilters:@[@"--ct-include=suite_foo:test*:*foo,suite_bar:test_barfoo,suite_bar:test_foobar:test_bort"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_BARFOO];
}

- (void)test_MultipleWildcardExpressions
{
    [self assertFilters:@[@"--ct-include=*foo*,suite_bar:test_b?rt"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO suite2Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT];
}

- (void)test_OverlappingWildcards
{
    [self assertFilters:@[@"--ct-include=*foo,*:test_ba*,suite_bar:*rt"] suite1Expected:RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT | RUN_TEST_TITLE_BART | RUN_TEST_EBERT];
}

- (void)test_UsesLastFilterFound
{
    [self assertFilters:@[@"--ct-include=*foo*", @"--ct-include=*bar*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_ALL];
}

- (void)test_EnvFilter
{
    setenv(self.envProperty.UTF8String, "", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    
    setenv(self.envProperty.UTF8String, "*", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    
    setenv(self.envProperty.UTF8String, "suite_far:test_bort", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    
    setenv(self.envProperty.UTF8String, "suite_?ar:test_?art", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BART | RUN_TEST_TITLE_BART suite2Expected:RUN_TEST_BART | RUN_TEST_TITLE_BART];

    setenv(self.envProperty.UTF8String, "*bar*", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_ALL];
    
    setenv(self.envProperty.UTF8String, "suite_far:test_bort,suite_bar:test_barfoo", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BARFOO];
}

@end
