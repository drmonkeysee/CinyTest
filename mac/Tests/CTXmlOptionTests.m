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

@end

static void *TestClass;

// NOTE: mock fopen to capture xml output (I'm surprised this works)
FILE *fopen(const char *restrict filename, const char *restrict mode)
{
    CTXmlOptionTests *testObject = (__bridge CTXmlOptionTests *)(TestClass);
    return fdopen(testObject.xmlSink.fileHandleForWriting.fileDescriptor,
                  mode);
}

static void testcase(void *context)
{
    ct_asserttrue(true, "a test case");
}

@implementation CTXmlOptionTests

- (void)setUp
{
    [super setUp];

    self.xmlSink = [NSPipe pipe];

    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;

    [super tearDown];
}

- (void)test_RunTests
{
    const struct ct_testcase cases[] = {ct_maketest(testcase)};
    const struct ct_testsuite suite = ct_makesuite(cases);
    const char *args[] = {"mytests", "--ct-xml=test.xml"};

    const size_t result = ct_runsuite_withargs(&suite,
                                               sizeof args / sizeof args[0],
                                               args);

    NSFileHandle *output = self.xmlSink.fileHandleForReading;
    NSData *data = output.availableData;
    NSString *xmlResult = [[NSString alloc] initWithData:data
                                                encoding:NSUTF8StringEncoding];
    XCTAssertEqual(0, result);
}

@end
