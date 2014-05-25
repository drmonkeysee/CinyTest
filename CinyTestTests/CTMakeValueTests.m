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

#define assert_valuetype(v, T, a) \
            do { \
                struct ct_comparable_value v ## _value = ct_makevalue(v, ct_valuetype_annotation(v)); \
                XCTAssertEqual(T, v ## _value.type); \
                XCTAssertEqual(v, a(v ## _value)); \
            } while (false)

#define assert_invalidvaluetype(v) \
            do { \
                struct ct_comparable_value v ## _value = ct_makevalue(v, ct_valuetype_annotation(v)); \
                XCTAssertEqual(CT_ANNOTATE_INVALID, v ## _value.type); \
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
    signed char c = SCHAR_MAX;
    assert_valuetype(c, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    short s = SHRT_MAX;
    assert_valuetype(s, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    int i = INT_MAX;
    assert_valuetype(i, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    long l = LONG_MAX;
    assert_valuetype(l, CT_ANNOTATE_INTEGRAL, get_integral_value);
    
    long long ll = LONG_LONG_MAX;
    assert_valuetype(ll, CT_ANNOTATE_INTEGRAL, get_integral_value);
}

- (void)test_ctmakevalue_CreatesUnsignedIntegralValues
{
    bool b = true;
    assert_valuetype(b, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
    
    unsigned char c = UCHAR_MAX;
    assert_valuetype(c, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
    
    unsigned short s = USHRT_MAX;
    assert_valuetype(s, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
    
    unsigned int i = UINT_MAX;
    assert_valuetype(i, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
    
    unsigned long l = ULONG_MAX;
    assert_valuetype(l, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
    
    unsigned long long ll = ULONG_LONG_MAX;
    assert_valuetype(ll, CT_ANNOTATE_UNSIGNED_INTEGRAL, get_uintegral_value);
}

- (void)test_ctmakevalue_CreatesFloatingValues
{
    float f = FLT_MAX;
    assert_valuetype(f, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
    
    double d = DBL_MAX;
    assert_valuetype(d, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
    
    long double ld = LDBL_MAX;
    assert_valuetype(ld, CT_ANNOTATE_FLOATINGPOINT, get_floating_value);
}

- (void)test_ctmakevalue_CreatesComplexValues
{
    float complex fc = CMPLXF(FLT_MAX, FLT_MAX);
    assert_valuetype(fc, CT_ANNOTATE_COMPLEX, get_complex_value);
    
    double complex dc = CMPLX(DBL_MAX, DBL_MAX);
    assert_valuetype(dc, CT_ANNOTATE_COMPLEX, get_complex_value);
    
    long double complex ldc = CMPLXL(LDBL_MAX, LDBL_MAX);
    assert_valuetype(ldc, CT_ANNOTATE_COMPLEX, get_complex_value);
}

- (void)test_ctmakevalue_CreatesInvalidTypes
{
    char c = CHAR_MAX;
    assert_invalidvaluetype(c);
}

@end
