//
//  CTAssertEqualTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <stddef.h>
#include <limits.h>
#include <float.h>
#include <complex.h>
#include "ciny.h"

#if CHAR_MIN < 0
#define TAT_CHAR TAT_SCHAR
#define c_values sc_values
#else
#define TAT_CHAR TAT_UCHAR
#define c_values uc_values
#endif

typedef NS_ENUM(NSUInteger, TEST_ARG_TYPE) {
    TAT_SCHAR,
    TAT_SHORT,
    TAT_INT,
    TAT_LONG,
    TAT_LONG_LONG,
    
    TAT_BOOL,
    TAT_UCHAR,
    TAT_USHORT,
    TAT_UINT,
    TAT_ULONG,
    TAT_ULONG_LONG,
    
    TAT_FLOAT,
    TAT_DOUBLE,
    TAT_LDOUBLE,
    
    TAT_FCOMPLEX,
    TAT_COMPLEX,
    TAT_LCOMPLEX
};

enum argument {
    ARG_EXPECTED,
    ARG_ACTUAL
};

@interface CTAssertEqualTests : XCTestCase

@property (nonatomic, assign) BOOL invokedTest;
@property (nonatomic, assign) BOOL sawPostAssertCode;
@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;

@end

static void *TestClass;

#define get_integral_test_arg(T, i) ((T) == TAT_SCHAR ? sc_values[i] \
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
#define get_float_test_arg(T, i) ((T) == TAT_FLOAT ? f_values[i] \
                                    : (T) == TAT_DOUBLE ? d_values[i] \
                                    : ld_values[i])
#define get_complex_test_arg(T, i) ((T) == TAT_FCOMPLEX ? fc_values[i] \
                                    : (T) == TAT_COMPLEX ? dc_values[i] \
                                    : ldc_values[i])

static signed char sc_values[2];
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

static float f_values[2];
static double d_values[2];
static long double ld_values[2];

static float complex fc_values[2];
static double complex dc_values[2];
static long double complex ldc_values[2];

static void equality_test(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    switch (testObject.expectedType) {
        case TAT_SCHAR:
        case TAT_SHORT:
        case TAT_INT:
        case TAT_LONG:
        case TAT_LONG_LONG:
            switch (testObject.actualType) {
                case TAT_SCHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, ARG_EXPECTED), get_integral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, ARG_EXPECTED), get_uintegral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FLOAT:
                case TAT_DOUBLE:
                case TAT_LDOUBLE:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, ARG_EXPECTED), get_float_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FCOMPLEX:
                case TAT_COMPLEX:
                case TAT_LCOMPLEX:
                    ct_assertequal(get_integral_test_arg(testObject.expectedType, ARG_EXPECTED), get_complex_test_arg(testObject.actualType, ARG_ACTUAL));
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
                case TAT_SCHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, ARG_EXPECTED), get_integral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, ARG_EXPECTED), get_uintegral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FLOAT:
                case TAT_DOUBLE:
                case TAT_LDOUBLE:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, ARG_EXPECTED), get_float_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FCOMPLEX:
                case TAT_COMPLEX:
                case TAT_LCOMPLEX:
                    ct_assertequal(get_uintegral_test_arg(testObject.expectedType, ARG_EXPECTED), get_complex_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
            }
            break;
        case TAT_FLOAT:
        case TAT_DOUBLE:
        case TAT_LDOUBLE:
            switch (testObject.actualType) {
                case TAT_SCHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_float_test_arg(testObject.expectedType, ARG_EXPECTED), get_integral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_float_test_arg(testObject.expectedType, ARG_EXPECTED), get_uintegral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FLOAT:
                case TAT_DOUBLE:
                case TAT_LDOUBLE:
                    ct_assertequal(get_float_test_arg(testObject.expectedType, ARG_EXPECTED), get_float_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FCOMPLEX:
                case TAT_COMPLEX:
                case TAT_LCOMPLEX:
                    ct_assertequal(get_float_test_arg(testObject.expectedType, ARG_EXPECTED), get_complex_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
            }
            break;
        case TAT_FCOMPLEX:
        case TAT_COMPLEX:
        case TAT_LCOMPLEX:
            switch (testObject.actualType) {
                case TAT_SCHAR:
                case TAT_SHORT:
                case TAT_INT:
                case TAT_LONG:
                case TAT_LONG_LONG:
                    ct_assertequal(get_complex_test_arg(testObject.expectedType, ARG_EXPECTED), get_integral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_BOOL:
                case TAT_UCHAR:
                case TAT_USHORT:
                case TAT_UINT:
                case TAT_ULONG:
                case TAT_ULONG_LONG:
                    ct_assertequal(get_complex_test_arg(testObject.expectedType, ARG_EXPECTED), get_uintegral_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FLOAT:
                case TAT_DOUBLE:
                case TAT_LDOUBLE:
                    ct_assertequal(get_complex_test_arg(testObject.expectedType, ARG_EXPECTED), get_float_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
                case TAT_FCOMPLEX:
                case TAT_COMPLEX:
                case TAT_LCOMPLEX:
                    ct_assertequal(get_complex_test_arg(testObject.expectedType, ARG_EXPECTED), get_complex_test_arg(testObject.actualType, ARG_ACTUAL));
                    break;
            }
            break;
    }
    
    testObject.sawPostAssertCode = YES;
}

static void equality_test_withmessage(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    ct_assertequal(10, 20, "Oh dear, an inequality message!");
    
    testObject.sawPostAssertCode = YES;
}

static void equality_test_withformatmessage(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    int e = -9;
    int i = 5;
    
    ct_assertequal(e, i, "Turns out %d is not equal to %d", e, i);
    
    testObject.sawPostAssertCode = YES;
}

static void equality_test_withtypevariants(void *context)
{
    CTAssertEqualTests *testObject = (__bridge CTAssertEqualTests *)(TestClass);
    
    testObject.invokedTest = YES;
    
    const int ci = 10;
    int i = 10;
    
    ct_assertequal(ci, i, "const ints and ints should be equal");
    
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

#pragma mark - Integral Equality

- (void)test_ctassertequal_ComparesEqual_IfSameIntegralTypes
{
    i_values[ARG_EXPECTED] = 34503;
    i_values[ARG_ACTUAL] = 34503;
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
    sc_values[ARG_EXPECTED] = 42;
    ll_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_SCHAR;
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
    i_values[ARG_EXPECTED] = -5673;
    i_values[ARG_ACTUAL] = -5673;
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
    s_values[ARG_EXPECTED] = -5673;
    l_values[ARG_ACTUAL] = -5673;
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
    i_values[ARG_EXPECTED] = 0;
    i_values[ARG_ACTUAL] = 0;
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
    sc_values[ARG_EXPECTED] = 0;
    s_values[ARG_ACTUAL] = 0;
    self.expectedType = TAT_SCHAR;
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
    ll_values[ARG_EXPECTED] = LONG_LONG_MAX;
    ll_values[ARG_ACTUAL] = LONG_LONG_MAX;
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
    ll_values[ARG_EXPECTED] = LONG_LONG_MIN;
    ll_values[ARG_ACTUAL] = LONG_LONG_MIN;
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
    i_values[ARG_EXPECTED] = 560;
    i_values[ARG_ACTUAL] = -346;
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
    s_values[ARG_EXPECTED] = 560;
    l_values[ARG_ACTUAL] = -4574234;
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
    ll_values[ARG_EXPECTED] = LONG_LONG_MIN;
    ll_values[ARG_ACTUAL] = LONG_LONG_MAX;
    self.expectedType = TAT_LONG_LONG;
    self.actualType = TAT_LONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Unsigned Integral Equality

- (void)test_ctassertequal_ComparesEqual_IfSameUnsignedIntegralTypes
{
    ui_values[ARG_EXPECTED] = 34503;
    ui_values[ARG_ACTUAL] = 34503;
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
    b_values[ARG_EXPECTED] = 1;
    ull_values[ARG_ACTUAL] = 1;
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
    ui_values[ARG_EXPECTED] = 0;
    ui_values[ARG_ACTUAL] = 0;
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
    uc_values[ARG_EXPECTED] = 0;
    ul_values[ARG_ACTUAL] = 0;
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
    ull_values[ARG_EXPECTED] = ULONG_LONG_MAX;
    ull_values[ARG_ACTUAL] = ULONG_LONG_MAX;
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
    ui_values[ARG_EXPECTED] = 560;
    ui_values[ARG_ACTUAL] = 123467;
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
    us_values[ARG_EXPECTED] = 560;
    ui_values[ARG_ACTUAL] = 688334;
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
    ull_values[ARG_EXPECTED] = 0;
    ull_values[ARG_ACTUAL] = ULONG_LONG_MAX;
    self.expectedType = TAT_ULONG_LONG;
    self.actualType = TAT_ULONG_LONG;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Float Equality

- (void)test_ctassertequal_ComparesEqual_IfSameFloatTypes
{
    d_values[ARG_EXPECTED] = 3.7832e21;
    d_values[ARG_ACTUAL] = 3.7832e21;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentFloatTypes
{
    f_values[ARG_EXPECTED] = 7834.0f;
    ld_values[ARG_ACTUAL] = 7834.0l;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeFloatValues
{
    d_values[ARG_EXPECTED] = -56.873201;
    d_values[ARG_ACTUAL] = -56.873201;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeFloatValuesWithDifferentTypes
{
    f_values[ARG_EXPECTED] = -52.0f;
    d_values[ARG_ACTUAL] = -52.0;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroFloatValues
{
    d_values[ARG_EXPECTED] = 0.0;
    d_values[ARG_ACTUAL] = 0.0;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroFloatValuesWithDifferentTypes
{
    d_values[ARG_EXPECTED] = 0.0;
    ld_values[ARG_ACTUAL] = 0.0l;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestFloatValue
{
    ld_values[ARG_EXPECTED] = LDBL_MAX;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestFloatValue
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MIN;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentFloatValues
{
    d_values[ARG_EXPECTED] = 67.34;
    d_values[ARG_ACTUAL] = -902.435;
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentFloatValuesAndTypes
{
    f_values[ARG_EXPECTED] = 560.093f;
    ld_values[ARG_ACTUAL] = -4574234e10l;
    self.expectedType = TAT_FLOAT;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxFloatValues
{
    ld_values[ARG_EXPECTED] = LDBL_MIN;
    ld_values[ARG_ACTUAL] = LDBL_MAX;
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Complex Equality

- (void)test_ctassertequal_ComparesEqual_IfSameComplexTypes
{
    dc_values[ARG_EXPECTED] = CMPLX(5.762, 3.462);
    dc_values[ARG_ACTUAL] = CMPLX(5.762, 3.462);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfDifferentComplexTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(82.0f, 12.0f);
    ldc_values[ARG_ACTUAL] = CMPLXL(82.0l, 12.0l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(-67.345, -23e10);
    dc_values[ARG_ACTUAL] = CMPLX(-67.345, -23e10);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfNegativeComplexValuesWithDifferentTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(-23.0f, -6.0f);
    dc_values[ARG_ACTUAL] = CMPLXL(-23.0, -6.0);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(0.0, 0.0);
    dc_values[ARG_ACTUAL] = CMPLX(0.0, 0.0);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfZeroComplexValuesWithDifferentTypes
{
    dc_values[ARG_EXPECTED] = CMPLX(0.0, 0.0);
    ldc_values[ARG_ACTUAL] = CMPLXL(0.0l, 0.0l);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfLargestComplexValue
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MAX, LDBL_MAX);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MAX, LDBL_MAX);
    self.expectedType = TAT_LCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfSmallestComplexValue
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MIN, LDBL_MIN);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MIN, LDBL_MIN);
    self.expectedType = TAT_LDOUBLE;
    self.actualType = TAT_LDOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexValues
{
    dc_values[ARG_EXPECTED] = CMPLX(56.0234, 1.903);
    dc_values[ARG_ACTUAL] = CMPLX(87.34, 5.09);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexRealValues
{
    dc_values[ARG_EXPECTED] = CMPLX(56.0234, 20.5);
    dc_values[ARG_ACTUAL] = CMPLX(87.34, 20.5);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexImaginaryValues
{
    dc_values[ARG_EXPECTED] = CMPLX(76.98, 1.903);
    dc_values[ARG_ACTUAL] = CMPLX(76.98, 5.09);
    self.expectedType = TAT_COMPLEX;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(30.23f, 10e5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(-9.7l, 0.456l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexRealValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(30.23f, 2.5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(-9.7l, 2.5l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfDifferentComplexImaginaryValuesAndTypes
{
    fc_values[ARG_EXPECTED] = CMPLXF(45.0f, 10e5f);
    ldc_values[ARG_ACTUAL] = CMPLXL(45.0l, 0.456l);
    self.expectedType = TAT_FCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_ForMinAndMaxComplexValues
{
    ldc_values[ARG_EXPECTED] = CMPLXL(LDBL_MIN, LDBL_MIN);
    ldc_values[ARG_ACTUAL] = CMPLXL(LDBL_MAX, LDBL_MAX);
    self.expectedType = TAT_LCOMPLEX;
    self.actualType = TAT_LCOMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Type Inequality

- (void)test_ctassertequal_ComparesNotEqual_IfIntegralAndUIntegralTypes
{
    i_values[ARG_EXPECTED] = 20;
    ui_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_INT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegralAndFloatTypes
{
    i_values[ARG_EXPECTED] = 20;
    d_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_INT;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegralAndComplexTypes
{
    i_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_INT;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegralAndFloatTypes
{
    ui_values[ARG_EXPECTED] = 20;
    d_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_DOUBLE;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegralAndComplexTypes
{
    ui_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_UINT;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfFloatAndComplexTypes
{
    d_values[ARG_EXPECTED] = 20;
    dc_values[ARG_ACTUAL] = CMPLX(20, 0.0);
    self.expectedType = TAT_DOUBLE;
    self.actualType = TAT_COMPLEX;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Bit Pattern Inequality

- (void)test_ctassertequal_ComparesNotEqual_IfIntegralAndUIntegralIdenticalBitPattern
{
    _Static_assert(sizeof(int) == sizeof(unsigned int), "int and uint not equal sizes; this test needs to be adjusted to use different types");
    i_values[ARG_EXPECTED] = -1046478848;
    ui_values[ARG_ACTUAL] = 3248488448;
    self.expectedType = TAT_INT;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfIntegralAndFloatIdenticalBitPattern
{
    _Static_assert(sizeof(int) == sizeof(float), "int and float not equal sizes; this test needs to be adjusted to use different types");
    i_values[ARG_EXPECTED] = -1046478848;
    f_values[ARG_ACTUAL] = -2.0e1f;
    self.expectedType = TAT_INT;
    self.actualType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfUIntegralAndFloatIdenticalBitPattern
{
    _Static_assert(sizeof(unsigned int) == sizeof(float), "uint and float not equal sizes; this test needs to be adjusted to use different types");
    ui_values[ARG_EXPECTED] = 3248488448;
    f_values[ARG_ACTUAL] = -2.0e1f;
    self.expectedType = TAT_UINT;
    self.actualType = TAT_FLOAT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Messages

- (void)test_ctassertequal_FiresAssertion_WithCustomMessage
{
    struct ct_testcase tests[] = { ct_maketest(equality_test_withmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

- (void)test_ctassertequal_FiresAssertion_WithCustomFormatMessage
{
    struct ct_testcase tests[] = { ct_maketest(equality_test_withformatmessage) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

#pragma mark - Type variants

- (void)test_ctassertequal_ComparesEqual_WithTypeVariants
{
    struct ct_testcase tests[] = { ct_maketest(equality_test_withtypevariants) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

#pragma mark - Char

- (void)test_ctassertequal_ComparesEqual_IfCharTypes
{
    c_values[ARG_EXPECTED] = 42;
    c_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_CHAR;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesEqual_IfCharAndIntegralType
{
    c_values[ARG_EXPECTED] = 42;
    i_values[ARG_ACTUAL] = 42;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_INT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result, "Test unexpectedly failed - possibly compiled with unsigned char option?");
    XCTAssertTrue(self.invokedTest);
    XCTAssertTrue(self.sawPostAssertCode);
}

- (void)test_ctassertequal_ComparesNotEqual_IfCharAndUIntegralTypes
{
    c_values[ARG_EXPECTED] = 20;
    ui_values[ARG_ACTUAL] = 20;
    self.expectedType = TAT_CHAR;
    self.actualType = TAT_UINT;
    struct ct_testcase tests[] = { ct_maketest(equality_test) };
    struct ct_testsuite suite = ct_makesuite(tests);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(1, run_result, "Test unexpectedly passed - possibly compiled with unsigned char option?");
    XCTAssertTrue(self.invokedTest);
    XCTAssertFalse(self.sawPostAssertCode);
}

@end
