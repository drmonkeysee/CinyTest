//
//  CTMakeValueTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 5/24/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTTestBase.h"

#include "ciny.h"

#include <complex.h>
#include <float.h>
#include <limits.h>
#include <stdbool.h>

#define get_integer_value(cv) (cv).integer_value
#define get_uinteger_value(cv) (cv).uinteger_value
#define get_floatingpoint_value(cv) (cv).floatingpoint_value
#define get_complex_value(cv) (cv).complex_value

#define assert_valuetype(T, v, a, acc) \
            do { \
                assert_valuetype_variant(T, v, a, acc); \
                assert_valuetype_variant(const T, v, a, acc); \
                assert_valuetype_variant(volatile T, v, a, acc); \
                assert_valuetype_variant(_Atomic T, v, a, acc); \
                assert_valuetype_variant(const volatile T, v, a, acc); \
                assert_valuetype_variant(const _Atomic T, v, a, acc); \
                assert_valuetype_variant(volatile _Atomic T, v, a, acc); \
                assert_valuetype_variant(const volatile _Atomic T, v, a, acc); \
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

@interface CTMakeValueTests : CTTestBase

@end

@implementation CTMakeValueTests

- (void)test_ctmakevalue_CreatesIntegerValues
{
    assert_valuetype(signed char, SCHAR_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(short, SHRT_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(int, INT_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(long, LONG_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(long long, LLONG_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
    
#if CHAR_MIN < 0
    assert_valuetype(char, CHAR_MAX, CT_ANNOTATE_INTEGER, get_integer_value);
#endif
}

- (void)test_ctmakevalue_CreatesUnsignedIntegerValues
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-compare"
    assert_valuetype(bool, true, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
    assert_valuetype(unsigned char, UCHAR_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
    assert_valuetype(unsigned short, USHRT_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
#pragma clang diagnostic pop
    
    assert_valuetype(unsigned int, UINT_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
    assert_valuetype(unsigned long, ULONG_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
    assert_valuetype(unsigned long long, ULLONG_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
#if CHAR_MIN == 0
    assert_valuetype(char, CHAR_MAX, CT_ANNOTATE_UINTEGER, get_uinteger_value);
#endif
}

- (void)test_ctmakevalue_CreatesFloatingPointValues
{
    assert_valuetype(float, FLT_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floatingpoint_value);
    
    assert_valuetype(double, DBL_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floatingpoint_value);
    
    assert_valuetype(long double, LDBL_MAX, CT_ANNOTATE_FLOATINGPOINT, get_floatingpoint_value);
}

- (void)test_ctmakevalue_CreatesComplexValues
{
    assert_valuetype(float complex, (CMPLXF(FLT_MAX, FLT_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
    
    assert_valuetype(double complex, (CMPLX(DBL_MAX, DBL_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
    
    assert_valuetype(long double complex, (CMPLXL(LDBL_MAX, LDBL_MAX)), CT_ANNOTATE_COMPLEX, get_complex_value);
}

- (void)test_ctmakevalue_FromLiterals
{
    assert_valuetype(int, 22, CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(int, 'A', CT_ANNOTATE_INTEGER, get_integer_value);
    
    assert_valuetype(unsigned int, 34u, CT_ANNOTATE_UINTEGER, get_uinteger_value);
    
    assert_valuetype(double, 5.34, CT_ANNOTATE_FLOATINGPOINT, get_floatingpoint_value);
    
    assert_invalidvaluetype("bad value");
    
    assert_invalidvaluetype(((int[]){1, 2, 3}));
    
    assert_invalidvaluetype(((struct { int a; int b; }){1, 2}));
}

- (void)test_ctmakevalue_CreatesInvalidTypes
{
    int i = 40, *ip = &i;
    assert_invalidvaluetype(ip);
    
    struct {
        int i_v;
        float f_v;
    } s = {10, 5.0};
    assert_invalidvaluetype(s);
    
    char str[5];
    assert_invalidvaluetype(str);
}

@end
