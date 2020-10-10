//
//  CTXmlOptionTests.m
//  Tests
//
//  Created by Brandon Stansbury on 10/9/20.
//  Copyright © 2020 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>

@interface CTXmlOptionTests : CTTestBase

@property (nonatomic) NSPipe *xmlSink;
@property (nonatomic) NSString *xmlName;

- (void)assertValidXmlContaining:(NSArray *)expected;
- (NSData *)getXmlData;
- (NSString *)xmlTextFrom:(NSData *)data;
- (NSString *)getXmlText;
- (NSString *)getExpectedXmlFor:(NSString *)key;

@end

#define ARGS_SIZE 2
static void *TestClass;
static const char *ProgramArgs[ARGS_SIZE];

// NOTE: mock fopen to capture xml output (I'm surprised this works)
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

@implementation CTXmlOptionTests

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
    TestClass = NULL;

    [super tearDown];
}

- (void)test_NoXmlData_IfNoTests
{
    const size_t result = ct_runsuite_withargs(NULL, ARGS_SIZE, ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    XCTAssertEqualObjects(@"", [self getXmlText]);
}

- (void)test_EmptyXmlDoc_IfEmptyTests
{
    const struct ct_testcase cases[] = {};
    const struct ct_testsuite suite = ct_makesuite(cases);
    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

    XCTAssertEqual(0, result);
    XCTAssertEqualObjects(@"test.xml", self.xmlName);
    XCTAssertEqualObjects([self getExpectedXmlFor:@"EmptyXmlDoc"],
                          [self getXmlText]);
}

- (void)test_SuccessfulTest
{
    const struct ct_testcase cases[] = {ct_maketest(simple_success)};
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, NULL, NULL);

    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

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
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, NULL, NULL);

    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

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
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, NULL, NULL);

    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

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
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, NULL, NULL);

    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

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
    const struct ct_testsuite
    suite = ct_makesuite_setup_teardown_named("suite1",
                                              sizeof cases / sizeof cases[0],
                                              cases, NULL, NULL);

    const size_t result = ct_runsuite_withargs(&suite, ARGS_SIZE, ProgramArgs);

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

- (NSString *)getExpectedXmlFor:(NSString *)key
{
    return [[NSBundle bundleForClass:self.class]
            localizedStringForKey:key
            value:@"PlaceholderString"
            table:@"Tests"];
}

@end
