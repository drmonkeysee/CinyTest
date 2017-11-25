//
//  CTAssertNotEqualStrTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 6/23/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTStringAssertionTestBase.h"
#include <stddef.h>
#include "ciny.h"

@interface CTAssertNotEqualStrTests : CTStringAssertionTestBase

@end

static void test_inequality_stringn(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstrn(testObject.expectedString, testObject.actualString, testObject.compareCount);
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_stringn_withmessage(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstrn("foobar", "foobar", sizeof "foobar", "equal strings >:(");
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_stringn_withformatmessage(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char * const expected = "foobar", * const actual = "foobar";
    
    ct_assertnotequalstrn(expected, actual, sizeof "foobar", "we both said %s", actual);
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_string_expectedempty(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstr("", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_string_expectedonechar(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstr("b", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_string_expected(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstr("foobar", testObject.actualString);
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_string_withmessage(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertnotequalstr("foobar", "foobar", "equal strings :(");
    
    testObject.sawPostAssertCode = YES;
}

static void test_inequality_string_withformatmessage(void *context)
{
    CTAssertNotEqualStrTests *testObject = (__bridge CTAssertNotEqualStrTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const char * const actual = "foobar";
    
    ct_assertnotequalstr("foobar", actual, "why'd you say %s??", actual);
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertNotEqualStrTests

#pragma mark - ctassertnotequalstrn

- (void)test_ctassertnotequalstrn_ComparesEqual_IfExpectedAndActualAreNull
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 0;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfExpectedAndActualAreNullEvenWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = NULL;
    self.compareCount = 8;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfExpectedAndActualAreEmpty
{
    self.expectedString = "";
    self.actualString = "";
    self.compareCount = sizeof "";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfExpectedAndActualAreSingleCharStrings
{
    self.expectedString = "f";
    self.actualString = "f";
    self.compareCount = sizeof "f";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfExpectedAndActualAreEqualStrings
{
    self.expectedString = "foobar";
    self.actualString = "foobar";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfSizeRefersToEqualSubstrings
{
    self.expectedString = "foobar";
    self.actualString = "fooroo";
    self.compareCount = 3;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfUnicodeStrings
{
    self.expectedString = "测试";
    self.actualString = "测试";
    self.compareCount = sizeof "测试";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfEmoji
{
    self.expectedString = "💩";
    self.actualString = "💩";
    self.compareCount = sizeof "💩";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF16EscapeSequence
{
    self.expectedString = "⌘";
    self.actualString = "\u2318";
    self.compareCount = sizeof "⌘";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_IfUnicodeCharIsComparedToUTF32EscapeSequence
{
    self.expectedString = "🐴";
    self.actualString = "\U0001F434";
    self.compareCount = sizeof "🐴";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesEqual_WithVeryLongString
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfMixedCase
{
    self.expectedString = "foobar";
    self.actualString = "FOOBAR";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfActualIsShorterThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "fooba";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfActualIsLongerThanExpected
{
    self.expectedString = "foobar";
    self.actualString = "foobars";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfExpectedIsNull
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 0;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfExpectedIsNullWithInvalidSize
{
    self.expectedString = NULL;
    self.actualString = "foobar";
    self.compareCount = 45;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfExpectedIsEmpty
{
    self.expectedString = "";
    self.actualString = "foobar";
    self.compareCount = 1;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfActualIsNull
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfActualIsNullWithInvalidSize
{
    self.expectedString = "foobar";
    self.actualString = NULL;
    self.compareCount = 100;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfActualIsEmpty
{
    self.expectedString = "foobar";
    self.actualString = "";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfDifferentStrings
{
    self.expectedString = "foobar";
    self.actualString = "blarg";
    self.compareCount = sizeof "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfDifferentUnicodeStrings
{
    self.expectedString = "例子";
    self.actualString = "مثال.إختبار";
    self.compareCount = sizeof "例子";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfDifferentEmoji
{
    self.expectedString = "🐵";
    self.actualString = "🐒";
    self.compareCount = sizeof "🐵";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_IfUnicodeCharIsComparedToComparableISOSequence
{
    self.expectedString = "’"; // 0xE2 0x80 0x99 (\u2019)
    self.actualString = "â€™"; // 0xE2 0x80 0x99 in ISO-8859-1
    self.compareCount = sizeof "’";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtStart
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[0];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_ComparesNotEqual_WhenVeryLongStringDiffersAtEnd
{
    NSString *longString = [[NSBundle bundleForClass:self.class] localizedStringForKey:@"LongString" value:@"PlaceholderString" table:@"Tests"];
    self.expectedString = (char *)[longString UTF8String];
    NSString *copiedString = [NSString stringWithUTF8String:self.expectedString];
    self.actualString = (char *)[copiedString UTF8String];
    ++self.actualString[longString.length];
    self.compareCount = longString.length + 1;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

#pragma mark - ctassertnotequalstr

- (void)test_ctassertnotequalstrEmpty_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrEmpty_ComparesEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrEmpty_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrEmpty_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedempty) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrOneChar_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrOneChar_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrOneChar_ComparesEqual_IfSingleChar
{
    self.actualString = "b";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrOneChar_ComparesNotEqual_IfNonEqualSingleChar
{
    self.actualString = "d";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrOneChar_ComparesNotEqual_IfNonEmptyString
{
    self.actualString = "booz";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expectedonechar) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrFullStr_ComparesNotEqual_IfNull
{
    self.actualString = NULL;
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrFullStr_ComparesNotEqual_IfEmpty
{
    self.actualString = "";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrFullStr_ComparesNotEqual_IfSingleChar
{
    self.actualString = "f";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrFullStr_ComparesEqual_IfSameString
{
    self.actualString = "foobar";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrFullStr_ComparesNotEqual_IfSuperstring
{
    self.actualString = "foobars";
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_expected) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    successful_assertion_expected(run_result);
}

#pragma mark - Messages

- (void)test_ctassertnotequalstrn_FailsAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn_withmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstrn_FailsAssertion_WithFormattedMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_stringn_withformatmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstr_FailsAssertion_WithMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_withmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

- (void)test_ctassertnotequalstr_FailsAssertion_WithFormattedMessage
{
    const struct ct_testcase tests[] = { ct_maketest(test_inequality_string_withformatmessage) };
    const struct ct_testsuite suite = ct_makesuite(tests);
    
    const size_t run_result = ct_runsuite(&suite);
    
    failed_assertion_expected(run_result);
}

@end
