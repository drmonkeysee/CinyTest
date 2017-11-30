//
//  CTIncludeOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 9/21/17.
//  Copyright © 2017 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"
#include <stddef.h>
#include <stdlib.h>
#include "ciny.h"

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

typedef NS_ENUM(NSUInteger, RUN_SUITE) {
    RUN_SUITE1,
    RUN_SUITE2
};

static const char * const restrict EnvVar = "CINYTEST_INCLUDE";
static struct ct_testsuite Suites[2];
static RUN_TEST_FLAGS Suite1Flags, Suite2Flags;

static void set_test_flag(const void *ctx, RUN_TEST_FLAGS flag)
{
    RUN_TEST_FLAGS * const testvar = (RUN_TEST_FLAGS)ctx == RUN_SUITE2 ? &Suite2Flags : &Suite1Flags;
    *testvar |= flag;
}

static void test_foobar(void *context)
{
    set_test_flag(context, RUN_TEST_FOOBAR);
}

static void test_barfoo(void *context)
{
    set_test_flag(context, RUN_TEST_BARFOO);
}

static void test_bort(void *context)
{
    set_test_flag(context, RUN_TEST_BORT);
}

static void test_bart(void *context)
{
    set_test_flag(context, RUN_TEST_BART);
}

static void test_Bart(void *context)
{
    set_test_flag(context, RUN_TEST_TITLE_BART);
}

static void test_ebert(void *context)
{
    set_test_flag(context, RUN_TEST_EBERT);
}

static void test_ededeededered(void *context)
{
    set_test_flag(context, RUN_TEST_REPETITIVE);
}

static void test_èxtended_chærs(void *context)
{
    set_test_flag(context, RUN_TEST_EXTENDED);
}

static void test_测试漢(void *context)
{
    set_test_flag(context, RUN_TEST_EAST_ASIAN);
}

static void test_🐴🐎(void *context)
{
    set_test_flag(context, RUN_TEST_HORSE);
}

static void suite1_setup(void **context_ref)
{
    *context_ref = (void *)RUN_SUITE1;
}

static void suite2_setup(void **context_ref)
{
    *context_ref = (void *)RUN_SUITE2;
}

static struct ct_testsuite make_suite(const char * restrict name, ct_setupteardown_function setup)
{
    static const struct ct_testcase tests[] = {
        ct_maketest(test_foobar),
        ct_maketest(test_barfoo),
        ct_maketest(test_bort),
        ct_maketest(test_bart),
        ct_maketest(test_Bart),
        ct_maketest(test_ebert),
        ct_maketest(test_ededeededered),
        ct_maketest(test_èxtended_chærs),
        ct_maketest(test_测试漢),
        ct_maketest(test_🐴🐎)
    };
    
    return ct_makesuite_setup_teardown_named(name, tests, sizeof tests / sizeof tests[0], setup, NULL);
}

@interface CTIncludeOptionTests : CTTestBase

@end

@implementation CTIncludeOptionTests

+ (void)setUp
{
    [super setUp];
    
    Suites[0] = make_suite("suite_far", suite1_setup);
    Suites[1] = make_suite("suite_bar", suite2_setup);
}

- (void)setUp
{
    [super setUp];

    unsetenv(EnvVar);
}

- (void)tearDown
{
    unsetenv(EnvVar);
    
    [super tearDown];
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
}

- (void)test_HighBMPCharacters
{
    [self assertFilters:@[@"--ct-include=suite_far:test_测试漢"] suite1Expected:RUN_TEST_EAST_ASIAN suite2Expected:RUN_TEST_NONE];
    // this *happens* to work because the bytes don't match any other tests
    [self assertFilters:@[@"--ct-include=*试*"] suite1Expected:RUN_TEST_EAST_ASIAN suite2Expected:RUN_TEST_EAST_ASIAN];
}

- (void)test_EmojiCharacters
{
    [self assertFilters:@[@"--ct-include=suite_far:test_🐴🐎"] suite1Expected:RUN_TEST_HORSE suite2Expected:RUN_TEST_NONE];
    // this *happens* to work because the bytes don't match any other tests
    [self assertFilters:@[@"--ct-include=*🐴*"] suite1Expected:RUN_TEST_HORSE suite2Expected:RUN_TEST_HORSE];
}

- (void)test_Wildcards_DoNotMatch_ExtendedCharacters
{
    [self assertFilters:@[@"--ct-include=:test_?xtended_chærs"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
    [self assertFilters:@[@"--ct-include=*æ*"] suite1Expected:RUN_TEST_NONE suite2Expected:RUN_TEST_NONE];
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
    [self assertFilters:@[@"--ct-include=*foo,*:test_ba*,suite_bar:*rt"] suite1Expected:RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_BARFOO | RUN_TEST_BART | RUN_TEST_BORT | RUN_TEST_TITLE_BART | RUN_TEST_EBERT | RUN_TEST_REPETITIVE];
}

- (void)test_UsesLastFilterFound
{
    [self assertFilters:@[@"--ct-include=*foo*", @"--ct-include=*bar*"] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_ALL];
}

- (void)test_EnvFilter
{
    setenv(EnvVar, "", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    
    setenv(EnvVar, "*", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_ALL suite2Expected:RUN_TEST_ALL];
    
    setenv(EnvVar, "suite_far:test_bort", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_NONE];
    
    setenv(EnvVar, "suite_?ar:test_?art", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BART | RUN_TEST_TITLE_BART suite2Expected:RUN_TEST_BART | RUN_TEST_TITLE_BART];

    setenv(EnvVar, "*bar*", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_FOOBAR | RUN_TEST_BARFOO | RUN_TEST_BART suite2Expected:RUN_TEST_ALL];
    
    setenv(EnvVar, "suite_far:test_bort,suite_bar:test_barfoo", 1);
    [self assertFilters:@[] suite1Expected:RUN_TEST_BORT suite2Expected:RUN_TEST_BARFOO];
}

- (void)assertFilters:(NSArray *)filters suite1Expected:(RUN_TEST_FLAGS)suite1Expected suite2Expected:(RUN_TEST_FLAGS)suite2Expected
{
    Suite1Flags = Suite2Flags = RUN_TEST_NONE;
    
    const int argc = (int)filters.count;
    const char *argv[argc];
    for (int i = 0; i < argc; ++i) {
        argv[i] = [filters[i] UTF8String];
    }
    
    ct_run_withargs(Suites, sizeof Suites / sizeof Suites[0], argc, argv);
    
    XCTAssertEqual(suite1Expected, Suite1Flags);
    XCTAssertEqual(suite2Expected, Suite2Flags);
}

@end
