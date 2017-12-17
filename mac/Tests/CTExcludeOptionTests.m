//
//  CTExcludeOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 12/2/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTFilterOptionTestBase.h"

@interface CTExcludeOptionTests : CTFilterOptionTestBase

@end

@implementation CTExcludeOptionTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        self.envProperty = @"CINYTEST_EXCLUDE";
        return self;
    }
    return nil;
}

- (void)test_AllTestsRun_IfNoFilter
{
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude="] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_NoTestsRun_IfSimpleWildcard
{
    [self assertFilters:@[@"--ct-exclude=*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
}

- (void)test_ExactPatternMatch
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:RUN_TEST_ALL];
}

- (void)test_AllTestsRun_IfExactMatchHasWhitespace
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort "] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude= suite_far:test_bort"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude= suite_far:test_bort "] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_SingleSuitePatterns
{
    [self assertFilters:@[@"--ct-exclude=suite_far:"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=suite_far:*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_ALL];
}

- (void)test_SingleTestPatterns
{
    [self assertFilters:@[@"--ct-exclude=:test_bort"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:[self except:RUN_TEST_BORT]];
    [self assertFilters:@[@"--ct-exclude=*:test_bort"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:[self except:RUN_TEST_BORT]];
}

- (void)test_WildcardPatterns
{
    [self assertFilters:@[@"--ct-exclude=*bar*"] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART] suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-exclude=*foo"] suite1Expected:[self except:RUN_TEST_BARFOO] suite2Expected:[self except:RUN_TEST_BARFOO]];
    [self assertFilters:@[@"--ct-exclude=suite_f*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:*foo*"] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO] suite2Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO]];
    [self assertFilters:@[@"--ct-exclude=*far:"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:test*b*rt"] suite1Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_EBERT] suite2Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_EBERT]];
    [self assertFilters:@[@"--ct-exclude=suite_bar:test_*t"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART | RUN_TEST_EBERT]];
    [self assertFilters:@[@"--ct-exclude=suite_bar:test_**bar"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_FOOBAR]];
}

// verify wildcards do not prematurely fail when partial match is found earlier in test name
- (void)test_WildcardPatterns_WithPartialMatches
{
    // partial match on two e's in test_eb
    [self assertFilters:@[@"--ct-exclude=*ert*"] suite1Expected:[self except:RUN_TEST_EBERT] suite2Expected:[self except:RUN_TEST_EBERT]];
    // partial match on e in eb following test_
    [self assertFilters:@[@"--ct-exclude=:test_*ert*"] suite1Expected:[self except:RUN_TEST_EBERT] suite2Expected:[self except:RUN_TEST_EBERT]];
    // many partial matches on ed throughout the name
    [self assertFilters:@[@"--ct-exclude=:*eder*"] suite1Expected:[self except:RUN_TEST_REPETITIVE] suite2Expected:[self except:RUN_TEST_REPETITIVE]];
    // many partial matches on ed but only the end of string matters
    [self assertFilters:@[@"--ct-exclude=:*ed"] suite1Expected:[self except:RUN_TEST_REPETITIVE] suite2Expected:[self except:RUN_TEST_REPETITIVE]];
    // two matches on te but only the beginning of string matters
    [self assertFilters:@[@"--ct-exclude=:te*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    // many partial matches on te and ed but requiring beginning and end
    [self assertFilters:@[@"--ct-exclude=:te*ed"] suite1Expected:[self except:RUN_TEST_REPETITIVE] suite2Expected:[self except:RUN_TEST_REPETITIVE]];
    // many partial matches on ed including the end
    [self assertFilters:@[@"--ct-exclude=:*ed*ed"] suite1Expected:[self except:RUN_TEST_REPETITIVE] suite2Expected:[self except:RUN_TEST_REPETITIVE]];
}

- (void)test_WildcardLetterPatterns
{
    [self assertFilters:@[@"--ct-exclude=:test_b?rt"] suite1Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART] suite2Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART]];
    [self assertFilters:@[@"--ct-exclude=suite_bar:test_b?rt"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART]];
    [self assertFilters:@[@"--ct-exclude=suite_bar:test_?art"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BART | RUN_TEST_TITLE_BART]];
    [self assertFilters:@[@"--ct-exclude=suite_?ar:"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-exclude=suite_?ar:test_foobar"] suite1Expected:[self except:RUN_TEST_FOOBAR] suite2Expected:[self except:RUN_TEST_FOOBAR]];
    [self assertFilters:@[@"--ct-exclude=:test_??rt"] suite1Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART] suite2Expected:[self except:RUN_TEST_BORT | RUN_TEST_BART | RUN_TEST_TITLE_BART]];
}

- (void)test_AllTestsRun_IfNoPatternMatch
{
    [self assertFilters:@[@"--ct-exclude= "] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=foo"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=*blarg*"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:test_f?rt"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_AllTestsRun_IfTooManyTargetDelimiters
{
    [self assertFilters:@[@"--ct-exclude=suite_foo:test_foobar:test_barfoo"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=suite_foo:suite_bar:test_barfoo"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=suite_foo:test*:*foo"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_MixWildcardLetterAndWildcard
{
    [self assertFilters:@[@"--ct-exclude=suite_?ar:*foo*"] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO] suite2Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO]];
}

- (void)test_ExtendedCharacters
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_èxtended_chærs"] suite1Expected:[self except:RUN_TEST_EXTENDED] suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=*æ*"] suite1Expected:[self except:RUN_TEST_EXTENDED] suite2Expected:[self except:RUN_TEST_EXTENDED]];
}

- (void)test_HighBMPCharacters
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_测试漢"] suite1Expected:[self except:RUN_TEST_EAST_ASIAN] suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=*试*"] suite1Expected:[self except:RUN_TEST_EAST_ASIAN] suite2Expected:[self except:RUN_TEST_EAST_ASIAN]];
}

- (void)test_EmojiCharacters
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_🐴🐎"] suite1Expected:[self except:RUN_TEST_HORSE] suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=*🐴*"] suite1Expected:[self except:RUN_TEST_HORSE] suite2Expected:[self except:RUN_TEST_HORSE]];
}

- (void)test_Wildcards_DoNotMatch_ExtendedCharacters
{
    [self assertFilters:@[@"--ct-exclude=:test_?xtended_chærs"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:test_测试?"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:test_🐴?"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_MultipleMatchedExpressions
{
    [self assertFilters:@[@"--ct-exclude=suite_far:,suite_bar:"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-exclude=:test_barfoo,:test_bort"] suite1Expected:[self except: RUN_TEST_BARFOO | RUN_TEST_BORT] suite2Expected:[self except:RUN_TEST_BARFOO | RUN_TEST_BORT]];
    [self assertFilters:@[@"--ct-exclude=suite_far:,:test_bort"] suite1Expected:RUN_TEST_NONE suite2Expected:[self except:RUN_TEST_BORT]];
    [self assertFilters:@[@"--ct-exclude=:test_bort,suite_far:"] suite1Expected:RUN_TEST_NONE suite2Expected:[self except:RUN_TEST_BORT]];
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort,suite_bar:test_barfoo"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:[self except:RUN_TEST_BARFOO]];
}

- (void)test_FiltersIgnored_IfEmptyMultipleExpressions
{
    [self assertFilters:@[@"--ct-exclude=,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BARFOO]];
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort,"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=,"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:,"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=,:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=:,:"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_MultipleExactMatches_ContainingWhitespace
{
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort, suite_bar:test_barfoo"] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:RUN_TEST_ALL];
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort ,suite_bar:test_barfoo"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BARFOO]];
    [self assertFilters:@[@"--ct-exclude=suite_far:test_bort , suite_bar:test_barfoo"] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
}

- (void)test_RejectTooManyTargetDelimiters_InMultiExpressionFilter
{
    [self assertFilters:@[@"--ct-exclude=suite_foo:test*:*foo,suite_bar:test_barfoo,suite_bar:test_foobar:test_bort"] suite1Expected:RUN_TEST_ALL suite2Expected:[self except:RUN_TEST_BARFOO]];
}

- (void)test_MultipleWildcardExpressions
{
    [self assertFilters:@[@"--ct-exclude=*foo*,suite_bar:test_b?rt"] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO] suite2Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT]];
}

- (void)test_OverlappingWildcards
{
    [self assertFilters:@[@"--ct-exclude=*foo,*:test_ba*,suite_bar:*rt"] suite1Expected:[self except:RUN_TEST_BARFOO | RUN_TEST_BART] suite2Expected:[self except:RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT | RUN_TEST_TITLE_BART | RUN_TEST_EBERT]];
}

- (void)test_UsesLastFilterFound
{
    [self assertFilters:@[@"--ct-exclude=*foo*", @"--ct-exclude=*bar*"] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART] suite2Expected:RUN_TEST_NONE];
}

- (void)test_EnvFilter
{
    setenv(self.envProperty.UTF8String, "", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    
    setenv(self.envProperty.UTF8String, "*", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    
    setenv(self.envProperty.UTF8String, "suite_far:test_bort", 1);
    [self assertFilters:@[] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:RUN_TEST_ALL];
    
    setenv(self.envProperty.UTF8String, "suite_?ar:test_?art", 1);
    [self assertFilters:@[] suite1Expected:[self except:RUN_TEST_BART | RUN_TEST_TITLE_BART] suite2Expected:[self except:RUN_TEST_BART | RUN_TEST_TITLE_BART]];
    
    setenv(self.envProperty.UTF8String, "*bar*", 1);
    [self assertFilters:@[] suite1Expected:[self except:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART] suite2Expected:RUN_TEST_NONE];
    
    setenv(self.envProperty.UTF8String, "suite_far:test_bort,suite_bar:test_barfoo", 1);
    [self assertFilters:@[] suite1Expected:[self except:RUN_TEST_BORT] suite2Expected:[self except:RUN_TEST_BARFOO]];
}

- (void)test_IncludeAndExcludeFilters
{
    [self assertFilters:@[@"--ct-include=*b?rt", @"--ct-exclude=*bort"] suite1Expected:RUN_TEST_BART | RUN_TEST_EBERT suite2Expected:RUN_TEST_BART | RUN_TEST_EBERT];
}

- (RUN_TEST_FLAGS)except:(RUN_TEST_FLAGS)flags
{
    return RUN_TEST_ALL & ~flags;
}

@end
