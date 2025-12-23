//
//  CTXmlOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 10/9/20.
//  Copyright © 2020 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

@interface CTXmlOptionTests : CTTestBase

@property (nonatomic) NSPipe *xmlSink;
@property (nonatomic) NSString *xmlName;

+ (NSString *)getResourceStringFor:(NSString *)key;
- (void)assertValidXmlContaining:(NSArray *)expected;
- (NSData *)getXmlData;
- (NSString *)xmlTextFrom:(NSData *)data;
- (NSString *)getXmlText;

@end

static constexpr size_t ArgsSize = 3;
static void *TestClass;
static char *ProgramArgs[ArgsSize];

// NOTE: mock fopen to capture xml output (i'm surprised this works)
FILE *fopen(const char *restrict filename, const char *restrict mode)
{
    CTXmlOptionTests *testObject = (__bridge CTXmlOptionTests *)(TestClass);
    testObject.xmlName = [NSString stringWithUTF8String:filename];
    return fdopen(testObject.xmlSink.fileHandleForWriting.fileDescriptor,
                  mode);
}

static void simple_success(void *context)
{
    ct_asserttrue(true, "a test case");
}

static void simple_failure(void *context)
{
    ct_assertfail();
}

static void encoded_failure(void *context)
{
    ct_asserttrue(5 < 2, "a proper & expected failure");
}

static void simple_ignore(void *context)
{
    ct_ignore();
}

static void encoded_ignore(void *context)
{
    ct_ignore("don't run this \"useful\" test");
}

static void long_ignore(void *context)
{
    CTXmlOptionTests *testObject = (__bridge CTXmlOptionTests *)(TestClass);
    const char *const long_string =
        [testObject.class getResourceStringFor:@"LongString"].UTF8String;
    ct_ignore("%s", long_string);
}

static void long_failure(void *context)
{
    CTXmlOptionTests *testObject = (__bridge CTXmlOptionTests *)(TestClass);
    const char *const long_string =
        [testObject.class getResourceStringFor:@"LongString"].UTF8String;
    ct_assertfail("%s", long_string);
}

@implementation CTXmlOptionTests

+ (NSString *)getResourceStringFor:(NSString *)key
{
    return [[NSBundle bundleForClass:self]
            localizedStringForKey:key
            value:@"PlaceholderString"
            table:@"Tests"];
}

- (void)setUp
{
    [super setUp];

    self.xmlSink = [NSPipe pipe];

    TestClass = (__bridge void *)(self);
    ProgramArgs[0] = "xmltests";
    ProgramArgs[1] = "--ct-xml=test.xml";
}

- (void)tearDown
{
    TestClass = nullptr;

    [super tearDown];
}

- (void)test_NoXmlData_IfNoTests
{
    const size_t result = ct_runsuite_withargs(nullptr, ArgsSize, ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    XCTAssertEqualObjects(@"", [self getXmlText]);
}

- (void)test_EmptyXmlDoc_IfEmptyTests
{
    const struct ct_testcase cases[] = {};
    const struct ct_testsuite suite = ct_makesuite(cases);
    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    XCTAssertEqualObjects([self.class getResourceStringFor:@"EmptyXmlDoc"],
                          [self getXmlText]);
}

- (void)test_SuccessfulTest
{
    const struct ct_testcase cases[] = {ct_maketest(simple_success)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"0\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"simple_success\"",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_FailedTest
{
    const struct ct_testcase cases[] = {ct_maketest(simple_failure)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(1, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"1\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"1\" skipped=\"0\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"simple_failure\"",
        [NSString stringWithFormat:@"<failure message=\"%@ L.50 : asserted unconditional failure\" type=\"assertion\" />", [NSString stringWithUTF8String:__FILE__]],
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_EncodedFailedTest
{
    const struct ct_testcase cases[] = {ct_maketest(encoded_failure)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(1, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"1\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"1\" skipped=\"0\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"encoded_failure\"",
        [NSString stringWithFormat:
         @"<failure message=\"%@ L.55 : (5 &#60; 2) is true failed&#10;a proper &#38; expected failure\" type=\"assertion\" />",
         [NSString stringWithUTF8String:__FILE__]],
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_IgnoredTest
{
    const struct ct_testcase cases[] = {ct_maketest(simple_ignore)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"1\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"simple_ignore\"",
        @"<skipped type=\"ignored\" />",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_EncodedIgnoredTest
{
    const struct ct_testcase cases[] = {ct_maketest(encoded_ignore)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"1\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"encoded_ignore\"",
        @"<skipped message=\"don't run this &#34;useful&#34; test\" type=\"ignored\" />",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_SkippedByNoMatch
{
    ProgramArgs[2] = "--ct-include=*foo*";
    const struct ct_testcase cases[] = {ct_maketest(simple_success)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"1\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"simple_success\"",
        @"<skipped message=\"skipped by include filter (no match)\" type=\"filtered\" />",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_SkippedByMatch
{
    ProgramArgs[2] = "--ct-exclude=:simple_success";
    const struct ct_testcase cases[] = {ct_maketest(simple_success)};
    const struct ct_testsuite suite =
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases / sizeof cases[0],
                                          cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"1\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"simple_success\"",
        @"<skipped message=\"skipped by exclude filter (simple_success)\" type=\"filtered\" />",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_MultipleSuites
{
    ProgramArgs[0] = "multi-tests";
    ProgramArgs[1] = "--ct-xml=tests.xml";
    ProgramArgs[2] = "--ct-exclude=:skipped1";
    const struct ct_testcase cases1[] = {
        ct_maketest_named("success1", simple_success),
        ct_maketest_named("success2", simple_success),
        ct_maketest_named("failure1", encoded_failure),
        ct_maketest_named("ignore1", encoded_ignore),
    };
    const struct ct_testcase cases2[] = {
        ct_maketest_named("ignore2", simple_ignore),
        ct_maketest_named("success3", simple_success),
        ct_maketest_named("skipped1", simple_success),
    };
    const struct ct_testsuite suites[] = {
        ct_makesuite_setup_teardown_named("suite1",
                                          sizeof cases1 / sizeof cases1[0],
                                          cases1, nullptr, nullptr),
        ct_makesuite_setup_teardown_named("suite2",
                                          sizeof cases2 / sizeof cases2[0],
                                          cases2, nullptr, nullptr),
    };

    const size_t result = ct_run_withargs(suites, ArgsSize, ProgramArgs);

    XCTAssertEqual(1, result);
    XCTAssertEqualObjects(@"tests.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"multi-tests\" tests=\"7\" failures=\"1\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"4\" failures=\"1\" skipped=\"1\"",
        @"<testsuite name=\"suite2\" id=\"1\" tests=\"3\" failures=\"0\" skipped=\"2\"",
        @"<testcase classname=\"multi-tests.suite1\" name=\"success1\"",
        @"<testcase classname=\"multi-tests.suite1\" name=\"success2\"",
        @"<testcase classname=\"multi-tests.suite1\" name=\"failure1\"",
        [NSString stringWithFormat:
         @"<failure message=\"%@ L.55 : (5 &#60; 2) is true failed&#10;a proper &#38; expected failure\" type=\"assertion\" />",
         [NSString stringWithUTF8String:__FILE__]],
        @"<testcase classname=\"multi-tests.suite1\" name=\"ignore1\"",
        @"<skipped message=\"don't run this &#34;useful&#34; test\" type=\"ignored\" />",
        @"<testcase classname=\"multi-tests.suite2\" name=\"ignore2\"",
        @"<skipped type=\"ignored\" />",
        @"<testcase classname=\"multi-tests.suite2\" name=\"success3\"",
        @"<testcase classname=\"multi-tests.suite2\" name=\"skipped1\"",
        @"<skipped message=\"skipped by exclude filter (skipped1)\" type=\"filtered\" />",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_IgnoredTest_VeryLongMessage
{
    const struct ct_testcase cases[] = {ct_maketest(long_ignore)};
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"1\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"long_ignore\"",
        [NSString stringWithFormat:@"<skipped message=\"%@\" type=\"ignored\" />",
         [self.class getResourceStringFor:@"TruncatedString"]],
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_FailedTest_VeryLongMessage
{
    const struct ct_testcase cases[] = {ct_maketest(long_failure)};
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, nullptr, nullptr);

    const size_t result = ct_runsuite_withargs(&suite, ArgsSize - 1,
                                               ProgramArgs);

    XCTAssertEqual(1, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"xmltests\" tests=\"1\" failures=\"1\"",
        @"<testsuite name=\"suite1\" id=\"0\" tests=\"1\" failures=\"1\" skipped=\"0\"",
        @"<testcase classname=\"xmltests.suite1\" name=\"long_failure\"",
        [NSString stringWithFormat:@"<failure message=\"%@ L.81 : asserted unconditional failure&#10;%@\" type=\"assertion\" />", [NSString stringWithUTF8String:__FILE__], [self.class getResourceStringFor:@"TruncatedString"]],
    ];
    [self assertValidXmlContaining:expected];
}

- (void)test_UseEnvVar
{
    setenv("CINYTEST_XML", "env.xml", 1);
    const struct ct_testcase cases[] = {ct_maketest(simple_success)};
    const struct ct_testsuite suite = ct_makesuite(cases);

    const size_t result = ct_runsuite(&suite);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"env.xml", self.xmlName);
    NSArray *expected = @[
        @"<testsuites name=\"(all tests)\" tests=\"1\" failures=\"0\"",
        @"<testsuite name=\"-[CTXmlOptionTests test_UseEnvVar]\" id=\"0\" tests=\"1\" failures=\"0\" skipped=\"0\"",
        @"<testcase classname=\"(all tests).-[CTXmlOptionTests test_UseEnvVar]\" name=\"simple_success\"",
    ];
    [self assertValidXmlContaining:expected];
}

- (void)assertValidXmlContaining:(NSArray *)expected
{
    NSData *xmlData = [self getXmlData];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    XCTAssertTrue([parser parse]);

    NSString *xmlText = [self xmlTextFrom:xmlData];
    for (NSString *str in expected) {
        NSRange found = [xmlText rangeOfString:str];
        XCTAssertNotEqual(NSNotFound, found.location,
                          @"Expected string \"%@\" not found in\n%@", str,
                          xmlText);
    }
}

- (NSData *)getXmlData
{
    NSFileHandle *output = self.xmlSink.fileHandleForReading;
    return output.availableData;
}

- (NSString *)xmlTextFrom:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)getXmlText
{
    return [self xmlTextFrom:[self getXmlData]];
}

@end
