//
//  CTEqualAssertionTestBase.h
//  CinyTest
//
//  Created by Brandon Stansbury on 7/11/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#import "CTAssertionTestBase.h"
#include <limits.h>

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
    TAT_SMAX,
    
    TAT_BOOL,
    TAT_UCHAR,
    TAT_USHORT,
    TAT_UINT,
    TAT_ULONG,
    TAT_ULONG_LONG,
    TAT_UMAX,
    
    TAT_FLOAT,
    TAT_DOUBLE,
    TAT_LDOUBLE,
    
    TAT_FCOMPLEX,
    TAT_COMPLEX,
    TAT_LCOMPLEX
};

enum {
    ARG_EXPECTED,
    ARG_ACTUAL
};

#define get_integral_test_arg(T, i) ((T) == TAT_SCHAR ? sc_values[i] \
                                    : (T) == TAT_SHORT ? s_values[i] \
                                    : (T) == TAT_INT ? i_values[i] \
                                    : (T) == TAT_LONG ? l_values[i] \
                                    : (T) == TAT_LONG_LONG ? ll_values[i] \
                                    : smx_values[i])
#define get_uintegral_test_arg(T, i) ((T) == TAT_BOOL ? b_values[i] \
                                        : (T) == TAT_UCHAR ? uc_values[i] \
                                        : (T) == TAT_USHORT ? us_values[i] \
                                        : (T) == TAT_UINT ? ui_values[i] \
                                        : (T) == TAT_ULONG ? ul_values[i] \
                                        : (T) == TAT_ULONG_LONG ? ull_values[i] \
                                        : umx_values[i])
#define get_float_test_arg(T, i) ((T) == TAT_FLOAT ? f_values[i] \
                                    : (T) == TAT_DOUBLE ? d_values[i] \
                                    : ld_values[i])
#define get_complex_test_arg(T, i) ((T) == TAT_FCOMPLEX ? fc_values[i] \
                                    : (T) == TAT_COMPLEX ? dc_values[i] \
                                    : ldc_values[i])

extern signed char sc_values[2];
extern short s_values[2];
extern int i_values[2];
extern long l_values[2];
extern long long ll_values[2];
extern intmax_t smx_values[2];

extern _Bool b_values[2];
extern unsigned char uc_values[2];
extern unsigned short us_values[2];
extern unsigned int ui_values[2];
extern unsigned long ul_values[2];
extern unsigned long long ull_values[2];
extern uintmax_t umx_values[2];

extern float f_values[2];
extern double d_values[2];
extern long double ld_values[2];

extern float _Complex fc_values[2];
extern double _Complex dc_values[2];
extern long double _Complex ldc_values[2];

@interface CTEqualAssertionTestBase : CTAssertionTestBase

@property (nonatomic, assign) TEST_ARG_TYPE expectedType;
@property (nonatomic, assign) TEST_ARG_TYPE actualType;

@end
