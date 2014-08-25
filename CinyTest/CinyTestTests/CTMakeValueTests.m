//
//  CTMakeValueTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <limits.h>
#include <stdbool.h>
#include <float.h>
#include <complex.h>
#include "ciny.h"

#define get_integral_value(cv) (cv).integral_value
#define get_uintegral_value(cv) (cv).uintegral_value
#define get_floating_value(cv) (cv).floating_value
#define get_complex_value(cv) (cv).complex_value

#define assert_valuetype(T, v, a, acc) \
            do { \
                assert_valuetype_variant(T, v, a, acc); \
                assert_valuetype_variant(const T, v, a, acc); \
                assert_valuetype_variant(volatile T, v, a, acc); \
                assert_valuetype_variant(_Atomic T, v, a, acc); \
            } while (false)
#define assert_valuetype_variant(T, v, a, acc) \
            do { \
                T foo = v; \
                struct ct_comparable_value foo_value = ct_makevalue(foo); \
                XCTAssertEqual(a, foo_value.type); \
                XCTAssertEqual(v, acc(foo_value)); \
            } while (false)

#define assert_invalidvaluetype(v) \
            do { \
                struct ct_comparable_value foo_value = ct_makevalue(v); \
                XCTAssertEqual(CT_ANNOTATE_INVALID, foo_value.type); \
            } while (false)

@interface CTMakeValueTests : XCTestCase

@end

@implementation CTMakeValueTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_ctmakevalue_CreatesIntegralValues
{
    assert_valuetype(signed char, SCHAR_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    assert_valuetype(short, SHRT_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    assert_valuetype(int, INT_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    assert_valuetype(long, LONG_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    assert_valuetype(long long, LONG_LONG_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
#if CHAR_MIN < 0
    assert_valuetype(char, CHAR_MAX, CT_ANNOTATE_INTEGRAL, get_integral_value);
#endif
}

- (void)test_ctmakevalue_CreatesUnsignedIntegralValues
{
    assert_valuetype(bool, true, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
    assert_valuetype(unsigned char, UCHAR_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
    assert_valuetype(unsigned short, USHRT_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
    assert_valuetype(unsigned int, UINT_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
    assert_valuetype(unsigned long, ULONG_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
    assert_valuetype(unsigned long long, ULONG_LONG_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
    
#if CHAR_MIN == 0
    assert_valuetype(char, CHAR_MAX, CT_ANNOTATE_UNSIGNEDINTEGRAL, get_uintegral_value);
#endif
}

- (void)test_ctmakevalue_CreatesFloatingValues
{
    assert_valuetype(float, FLT_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
    
    assert_valuetype(double, DBL_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
    
    assert_valuetype(long double, LDBL_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
}

- (void)test_ctmakevalue_CreatesComplexValues
{
    assert_valuetype(float complex, (CMPLXF(FLT_MAX, FLT_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
    
    assert_valuetype(double complex, (CMPLX(DBL_MAX, DBL_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
    
    assert_valuetype(long double complex, (CMPLXL(LDBL_MAX, LDBL_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
}

- (void)test_ctmakevalue_CreatesInvalidTypes
{
    int i = 40;
    int *ip = &i;
    assert_invalidvaluetype(ip);
    
    struct {
        int i_v;
        float f_v;
    } s = { 10, 5.0 };
    assert_invalidvaluetype(s);
    
    char str[5];
    assert_invalidvaluetype(str);
}

@end
