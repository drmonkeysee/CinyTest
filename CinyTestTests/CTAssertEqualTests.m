//
//  CTAssertEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <limits.h>
#include "ciny.h"

typedef NS_ENUM(NSUInteger, TEST_ARG_TYPE) {
    TAT_CHAR,
    TAT_SHORT,
    TAT_INT,
    TAT_LONG,
    TAT_LONG_LONG,
    
    TAT_BOOL,
    TAT_UCHAR,
    TAT_USHORT,
    TAT_UINT,
    TAT_ULONG,
    TAT_ULONG_LONG
};

@interface CTAssertEqualTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;

@end

static void *TestClass;

#define get_integral_test_arg(T, i) ((T) == TAT_CHAR ? c_values[i] \
                                        : (T) == TAT_SHORT ? s_values[i] \
                                        : (T) == TAT_INT ? i_values[i] \
                                        : (T) == TAT_LONG ? l_values[i] \
                                        : ll_values[i])
#define get_uintegral_test_arg(T, i) ((T) == TAT_BOOL ? b_values[i] \
                                        : (T) == TAT_UCHAR ? uc_values[i] \
                                        : (T) == TAT_USHORT ? us_values[i] \
                                        : (T) == TAT_UINT ? ui_values[i] \
                                        : (T) == TAT_ULONG ? ul_values[i] \
                                        : ull_values[i])

static signed char c_values[2];
static short s_values[2];
static int i_values[2];
static long l_values[2];
static long long ll_values[2];

static _Bool b_values[2];
static unsigned char uc_values[2];
static unsigned short us_values[2];
static unsigned int ui_values[2];
static unsigned long ul_values[2];
static unsigned long long ull_values[2];

static void equality_test(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    switch (testObject.expectedType) {
        case TAT_CHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
            switch (testObject.actualType) {
                case TAT_CHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, 0), get_integral_test_arg(testObject.actualType, 1));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, 0), get_uintegral_test_arg(testObject.actualType, 1));
                    break;
            }
            break;
        case TAT_BOOL:
        case TAT_UCHAR:
        case TAT_USHORT:
        case TAT_UINT:
        case TAT_ULONG:
        case TAT_ULONG_LONG:
            switch (testObject.actualType) {
                case TAT_CHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, 0), get_integral_test_arg(testObject.actualType, 1));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, 0), get_uintegral_test_arg(testObject.actualType, 1));
                    break;
            }
            break;
    }
    
    testObject.sawPostAssertCode = YES;
}

@implementation CTAssertEqualTests

- (void)setUp
{
    [super setUp];
    
    TestClass = (__bridge void *)(self);
}

- (void)tearDown
{
    TestClass = NULL;
    
    [super tearDown];
}

- (void)test_ctassertequal_ComparesEqual_IfSameIntegralTypes
{
    i_values[0] = 34503;
    i_values[1] = 34503;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentIntegralTypes
{
    c_values[0] = 42;
    ll_values[1] = 42;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_LONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeIntegralValues
{
    i_values[0] = -5673;
    i_values[1] = -5673;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeIntegralValuesWithDifferentTypes
{
    s_values[0] = -5673;
    l_values[1] = -5673;
    self.expectedType = TAT_SHORT;
    self.actualType = TAT_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroIntegralValues
{
    i_values[0] = 0;
    i_values[1] = 0;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroIntegralValuesWithDifferentTypes
{
    c_values[0] = 0;
    s_values[1] = 0;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_SHORT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestIntegralValue
{
    ll_values[0] = LONG_LONG_MAX;
    ll_values[1] = LONG_LONG_MAX;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestIntegralValue
{
    ll_values[0] = LONG_LONG_MIN;
    ll_values[1] = LONG_LONG_MIN;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentIntegralValues
{
    i_values[0] = 560;
    i_values[1] = -346;
    self.expectedType = TAT_INT;
    self.actualType = TAT_INT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentIntegralValuesAndTypes
{
    s_values[0] = 560;
    l_values[1] = -4574234;
    self.expectedType = TAT_SHORT;
    self.actualType = TAT_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxIntegralValues
{
    ll_values[0] = LONG_LONG_MIN;
    ll_values[1] = LONG_LONG_MAX;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfSameUnsignedIntegralTypes
{
    ui_values[0] = 34503;
    ui_values[1] = 34503;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentUnsignedIntegralTypes
{
    b_values[0] = 1;
    ull_values[1] = 1;
    self.expectedType = TAT_BOOL;
    self.actualType = TAT_ULONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroUnsignedIntegralValues
{
    ui_values[0] = 0;
    ui_values[1] = 0;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroUnsignedIntegralValuesWithDifferentTypes
{
    uc_values[0] = 0;
    ul_values[1] = 0;
    self.expectedType = TAT_UCHAR;
    self.actualType = TAT_ULONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestUnsignedIntegralValue
{
    ull_values[0] = ULONG_LONG_MAX;
    ull_values[1] = ULONG_LONG_MAX;
    self.expectedType = TAT_ULONG_LONG;
    self.actualType = TAT_ULONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentUnsignedIntegralValues
{
    ui_values[0] = 560;
    ui_values[1] = 123467;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentUnsignedIntegralValuesAndTypes
{
    us_values[0] = 560;
    ui_values[1] = 688334;
    self.expectedType = TAT_USHORT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxUnsignedIntegralValues
{
    ull_values[0] = 0;
    ull_values[1] = ULONG_LONG_MAX;
    self.expectedType = TAT_ULONG_LONG;
    self.actualType = TAT_ULONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
