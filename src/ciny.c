//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <setjmp.h>
#include <complex.h>
#include <stdbool.h>
#include <float.h>
#include <math.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include "ciny.h"

/////
// Platform-specific Definitions
/////

uint64_t ct_get_currentmsecs(void);
void ct_startcolor(size_t);
void ct_endcolor(void);

#ifdef _WIN64
// windows console doesn't support utf-8 nicely
static const char * const restrict Ellipsis = "...";
static const char * const restrict PlusMinus = "+/-";
static const char * const restrict PassedTestSymbol = ".";
static const char * const restrict FailedTestSymbol = "x";
#else
static const char * const restrict Ellipsis = "\u2026";
static const char * const restrict PlusMinus = "\u00B1";
static const char * const restrict PassedTestSymbol = "\u2713";
static const char * const restrict FailedTestSymbol = "\u2717";
#endif

/////
// Type and Data Definitions
/////
static const char * const restrict HelpOption = "--ct-help";
static const char * const restrict VersionOption = "--ct-version";
static const char * const restrict ColorizedOption = "--ct-colorized";
static const char * const restrict SuiteBreaksOption = "--ct-suite-breaks";
static const char * const restrict IgnoredTestSymbol = "?";

#define COMPVALUE_STR_SIZE 75
enum assert_type {
    ASSERT_UNKNOWN,
    ASSERT_FAILURE,
    ASSERT_IGNORE
};
static struct {
    const char *file;
    int line;
    enum assert_type type;
    char description[200 + (COMPVALUE_STR_SIZE * 2)];
    char message[1002];
} AssertState;
static jmp_buf AssertSignal;

static const size_t InvalidSuite = 0;
struct runledger {
    size_t passed, failed, ignored;
};
static struct runsummary {
    size_t test_count;
    uint64_t total_time;
    struct runledger ledger;
} RunTotals;

enum text_highlight {
    HIGHLIGHT_SUCCESS,
    HIGHLIGHT_FAILURE,
    HIGHLIGHT_IGNORE
};
static struct {
    bool help;
    bool version;
    bool colorized;
    bool suite_breaks;
} RunContext;

/////
// Inline Function Call Sites
/////

extern inline struct ct_testsuite ct_makesuite_setup_teardown_named(const char * restrict, const struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);
extern inline size_t ct_runsuite_withargs(const struct ct_testsuite *, int, const char *[]);
extern inline size_t ct_runsuite(const struct ct_testsuite *);
extern inline struct ct_comparable_value ct_makevalue_integer(int, intmax_t);
extern inline struct ct_comparable_value ct_makevalue_uinteger(int, uintmax_t);
extern inline struct ct_comparable_value ct_makevalue_floatingpoint(int, long double);
extern inline struct ct_comparable_value ct_makevalue_complex(int, ct_lcomplex);
extern inline struct ct_comparable_value ct_makevalue_invalid(int, ...);

/////
// Run Context
/////

static bool value_on(const char *value)
{
    static const char off_flags[] = { 'n', 'N', 'f', 'F', '0' };
    static const size_t flags_count = sizeof off_flags / sizeof off_flags[0];
    
    if (!value) return true;
    
    for (size_t i = 0; i < flags_count; ++i) {
        if (value[0] == off_flags[i]) {
            return false;
        }
    }

    return true;
}

static const char *arg_value(const char *arg)
{
    const char *delimiter = strrchr(arg, '=');
    
    if (delimiter) {
        return ++delimiter;
    }
    
    return NULL;
}

static void runcontext_init(int argc, const char *argv[])
{
    RunContext.help = false;
    RunContext.version = false;
    
    const char *color_option = NULL;
    const char *suite_breaks_option = NULL;
    
    if (argv) {
        for (int i = 0; i < argc; ++i) {
            const char * const arg = argv[i];
            if (!arg) {
                continue;
            } else if (strstr(arg, HelpOption)) {
                RunContext.help = true;
            } else if (strstr(arg, VersionOption)) {
                RunContext.version = true;
            } else if (strstr(arg, ColorizedOption)) {
                color_option = arg_value(arg);
            } else if (strstr(arg, SuiteBreaksOption)) {
                suite_breaks_option = arg_value(arg);
            }
        }
    }
    
    if (!color_option) {
        color_option = getenv("CINYTEST_COLORIZED");
    }
    if (!suite_breaks_option) {
        suite_breaks_option = getenv("CINYTEST_SUITE_BREAKS");
    }
    
    RunContext.colorized = value_on(color_option);
    RunContext.suite_breaks = value_on(suite_breaks_option);
}

/////
// Printing and Text Manipulation
/////

static void print_usage(void)
{
    printf("---=== CinyTest Usage ===---\n");
    printf("This program contains CinyTest tests and can accept the following command line options:\n\n");
    printf("  %s\t\tPrint this help message (does not run tests).\n", HelpOption);
    printf("  %s\t\tPrint CinyTest version (does not run tests).\n", VersionOption);
    printf("  %s=[yes|no|1|0|true|false]\n\t\t\tColorize test results (default: yes).\n", ColorizedOption);
    printf("  %s=[yes|no|1|0|true|false]\n\t\t\tPrint per-suite result summaries (default: yes).\n", SuiteBreaksOption);
}

static void print_version(void)
{
    printf("CinyTest " CT_VERSION);
#ifdef __VERSION__
    printf(" (" __VERSION__ ")");
#endif
    printf("\n");
}

static void print_highlighted(enum text_highlight color, const char * restrict format, ...)
{
    if (RunContext.colorized) {
        ct_startcolor(color);
    }
    
    va_list format_args;
    va_start(format_args, format);
    vprintf(format, format_args);
    va_end(format_args);
    
    if (RunContext.colorized) {
        ct_endcolor();
    }
}

static void print_resultlabel(enum text_highlight color, const char * restrict result_label)
{
    printf("[ ");
    print_highlighted(color, result_label);
    printf(" ] - ");
}

static void print_testresult(enum text_highlight color, const char * restrict result_label, const char * restrict result_message, ...)
{
    print_resultlabel(color, result_label);
    
    va_list format_args;
    va_start(format_args, result_message);
    vprintf(result_message, format_args);
    va_end(format_args);
    
    printf("\n");
}

static void print_linemessage(const char *message)
{
    if (printf("%s", message) > 0) {
        printf("\n");
    }
}

static bool pretty_truncate(char *str, size_t size)
{
    const size_t ellipsis_length = strlen(Ellipsis);
    const ptrdiff_t truncation_index = size - 1 - ellipsis_length;
    
    const bool can_fit_ellipsis = truncation_index >= 0;
    if (can_fit_ellipsis) {
        str[truncation_index] = '\0';
        strcat(str, Ellipsis);
    }
    
    return can_fit_ellipsis;
}

/////
// Run Summary
/////

static struct runsummary runsummary_make(void)
{
    return (struct runsummary){ .test_count = 0 };
}

static void runsummary_print(const struct runsummary *self)
{
    printf("Ran %zu tests (%.3f seconds): ", self->test_count, self->total_time / 1000.0);
    print_highlighted(HIGHLIGHT_SUCCESS, "%zu passed", self->ledger.passed);
    printf(", ");
    print_highlighted(HIGHLIGHT_FAILURE, "%zu failed", self->ledger.failed);
    printf(", ");
    print_highlighted(HIGHLIGHT_IGNORE, "%zu ignored", self->ledger.ignored);
    printf(".\n");
}

static void runtotals_add(const struct runsummary *summary)
{
    RunTotals.test_count += summary->test_count;
    RunTotals.total_time += summary->total_time;
    RunTotals.ledger.passed += summary->ledger.passed;
    RunTotals.ledger.failed += summary->ledger.failed;
    RunTotals.ledger.ignored += summary->ledger.ignored;
}

static void runtotals_print(void)
{
    if (RunTotals.ledger.failed > 0) {
        print_resultlabel(HIGHLIGHT_FAILURE, "FAILED");
    } else {
        print_resultlabel(HIGHLIGHT_SUCCESS, "SUCCESS");
    }
    runsummary_print(&RunTotals);
}

/////
// Assert State
/////

static void assertstate_reset(void)
{
    AssertState.type = ASSERT_UNKNOWN;
    AssertState.file = NULL;
    AssertState.line = 0;
    AssertState.description[0] = '\0';
    AssertState.message[0] = '\0';
}

static void assertstate_handlefailure(const char * restrict test_name, struct runledger *ledger)
{
    ++ledger->failed;
    print_testresult(HIGHLIGHT_FAILURE, FailedTestSymbol, "'%s' failure", test_name);
    printf("%s L.%d : %s\n", AssertState.file, AssertState.line, AssertState.description);
    print_linemessage(AssertState.message);
}

static void assertstate_handleignore(const char * restrict test_name, struct runledger *ledger)
{
    ++ledger->ignored;
    print_testresult(HIGHLIGHT_IGNORE, IgnoredTestSymbol, "'%s' ignored", test_name);
    print_linemessage(AssertState.message);
}

static void assertstate_handle(const char * restrict test_name, struct runledger *ledger)
{
    switch (AssertState.type) {
        case ASSERT_FAILURE:
            assertstate_handlefailure(test_name, ledger);
            break;
        case ASSERT_IGNORE:
            assertstate_handleignore(test_name, ledger);
            break;
        default:
            fprintf(stderr, "WARNING: unknown assertion type encountered!\n");
            break;
    }
}

static void assertstate_setdescription(const char * restrict format, ...)
{
    const size_t description_size = sizeof AssertState.description;
    va_list format_args;
    va_start(format_args, format);
    const int write_count = vsnprintf(AssertState.description, description_size, format, format_args);
    va_end(format_args);
    
    if ((size_t)write_count >= description_size) {
        pretty_truncate(AssertState.description, description_size);
    }
}

#define assertstate_setmessage(format) \
do { \
    va_list format_args; \
    va_start(format_args, format); \
    assertstate_setvmessage(format, format_args); \
    va_end(format_args); \
} while (false)
static void assertstate_setvmessage(const char *format, va_list format_args)
{
    const size_t message_size = sizeof AssertState.message;
    const int write_count = vsnprintf(AssertState.message, message_size, format, format_args);
    
    if ((size_t)write_count >= message_size) {
        pretty_truncate(AssertState.message, message_size);
    }
}

#define assertstate_raise_signal(assert_type, test_file, test_line, format) \
do { \
    AssertState.type = assert_type; \
    AssertState.file = test_file; \
    AssertState.line = test_line; \
    assertstate_setmessage(format); \
    longjmp(AssertSignal, AssertState.type); \
} while(false)

/////
// Comparable Value
/////

static bool comparable_value_equaltypes(const struct ct_comparable_value *expected, const struct ct_comparable_value *actual)
{
    return expected->type == actual->type;
}

static const char *comparable_value_typedescription(const struct ct_comparable_value *value)
{
    switch (value->type) {
        case CT_ANNOTATE_INTEGER:
            return "integer";
        case CT_ANNOTATE_UINTEGER:
            return "unsigned integer";
        case CT_ANNOTATE_FLOATINGPOINT:
            return "floating point";
        case CT_ANNOTATE_COMPLEX:
            return "complex";
        default:
            return "invalid value type";
    }
}

static bool comparable_value_equalvalues(const struct ct_comparable_value *expected, const struct ct_comparable_value *actual, enum ct_valuetype_annotation type)
{
    switch (type) {
        case CT_ANNOTATE_INTEGER:
            return expected->integer_value == actual->integer_value;
        case CT_ANNOTATE_UINTEGER:
            return expected->uinteger_value == actual->uinteger_value;
        case CT_ANNOTATE_FLOATINGPOINT:
            return expected->floatingpoint_value == actual->floatingpoint_value;
        case CT_ANNOTATE_COMPLEX:
            return creall(expected->complex_value) == creall(actual->complex_value) && cimagl(expected->complex_value) == cimagl(actual->complex_value);
        default:
            return false;
    }
}

static void comparable_value_valuedescription(const struct ct_comparable_value *value, char * restrict buffer, size_t size)
{
    int write_count = 0;
    
    switch (value->type) {
        case CT_ANNOTATE_INTEGER:
            write_count = snprintf(buffer, size, "%"PRIdMAX, value->integer_value);
            break;
        case CT_ANNOTATE_UINTEGER:
            write_count = snprintf(buffer, size, "%"PRIuMAX, value->uinteger_value);
            break;
        case CT_ANNOTATE_FLOATINGPOINT:
            write_count = snprintf(buffer, size, "%.*Lg", DECIMAL_DIG, value->floatingpoint_value);
            break;
        case CT_ANNOTATE_COMPLEX: {
            long double imagin_value = cimagl(value->complex_value);
            char sign = '+';
            if (imagin_value < 0.0) {
                sign = '-';
                imagin_value = fabsl(imagin_value);
            }
            write_count = snprintf(buffer, size, "%.*Lg %c %.*Lgi", DECIMAL_DIG, creall(value->complex_value), sign, DECIMAL_DIG, imagin_value);
            break;
        }
        default:
            write_count = snprintf(buffer, size, "invalid value");
            break;
    }
    
    if ((size_t)write_count >= size) {
        pretty_truncate(buffer, size);
    }
}

/////
// Test Suite and Test Case
/////

static void testcase_run(const struct ct_testcase *self, void * restrict test_context, size_t index, struct runledger *ledger)
{
    if (!self->test) {
        ++ledger->ignored;
        print_testresult(HIGHLIGHT_IGNORE, IgnoredTestSymbol, "ignored test at index %zu (NULL function pointer found)", index);
        return;
    }
    
    self->test(test_context);
    
    ++ledger->passed;
    print_testresult(HIGHLIGHT_SUCCESS, PassedTestSymbol, "'%s' success", self->name);
}

static void testsuite_printheader(const struct ct_testsuite *self, time_t start_time)
{
    char formatted_datetime[30];
    const size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, "%FT%T%z", localtime(&start_time));
    printf("Test suite '%s' started at %s\n", self->name,
           format_length ? formatted_datetime : "Invalid Date (formatted output may have exceeded buffer size)");
}

static void testsuite_runcase(const struct ct_testsuite *self, size_t index, struct runledger *ledger)
{
    assertstate_reset();
    const struct ct_testcase * const current_test = self->tests + index;
    
    void *test_context = NULL;
    if (self->setup) {
        self->setup(&test_context);
    }
    
    if (setjmp(AssertSignal)) {
        assertstate_handle(current_test->name, ledger);
    } else {
        testcase_run(current_test, test_context, index, ledger);
    }
    
    if (self->teardown) {
        self->teardown(&test_context);
    }
}

static void testsuite_run(const struct ct_testsuite *self)
{
    struct runsummary summary = runsummary_make();
    
    if (self && self->tests) {
        const uint64_t start_msecs = ct_get_currentmsecs();
        summary.test_count = self->count;
        if (RunContext.suite_breaks) {
            testsuite_printheader(self, time(NULL));
        }
        
        for (size_t i = 0; i < self->count; ++i) {
            testsuite_runcase(self, i, &summary.ledger);
        }
        
        summary.total_time = ct_get_currentmsecs() - start_msecs;
        if (RunContext.suite_breaks) {
            runsummary_print(&summary);
        }
    } else {
        fprintf(stderr, "NULL test suite or NULL test list detected! No tests run.\n");
        summary.ledger.failed = InvalidSuite;
    }
    
    runtotals_add(&summary);
}

/////
// Public Functions
/////

size_t ct_run_withargs(const struct ct_testsuite suites[], size_t count, int argc, const char *argv[])
{
    runcontext_init(argc, argv);
    RunTotals = runsummary_make();
    
    if (RunContext.help) {
        print_usage();
    } else if (RunContext.version) {
        print_version();
    } else {
        if (suites) {
            for (size_t i = 0; i < count; ++i) {
                const struct ct_testsuite * const suite = suites + i;
                testsuite_run(suite);
            }
            runtotals_print();
        } else {
            fprintf(stderr, "NULL test suite collection detected! No test suites run.\n");
            RunTotals.ledger.failed = InvalidSuite;
        }
    }

    return RunTotals.ledger.failed;
}

noreturn void ct_internal_ignore(const char * restrict format, ...)
{
    assertstate_raise_signal(ASSERT_IGNORE, NULL, 0, format);
}

noreturn void ct_internal_assertfail(const char * restrict file, int line, const char * restrict format, ...)
{
    assertstate_setdescription("%s", "asserted unconditional failure");
    assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
}

void ct_internal_asserttrue(bool expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (!expression) {
        assertstate_setdescription("(%s) is true failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertfalse(bool expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is false failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnull(const void * restrict expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is NULL failed: (%p)", stringized_expression, expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotnull(const void * restrict expression, const char * restrict stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (!expression) {
        assertstate_setdescription("(%s) is not NULL failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertequal(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription("(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (!comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE], valuestr_actual[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        comparable_value_valuedescription(&actual, valuestr_actual, sizeof valuestr_actual);
        assertstate_setdescription("(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotequal(struct ct_comparable_value expected, const char *stringized_expected, struct ct_comparable_value actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    bool failed_assert = false;
    if (!comparable_value_equaltypes(&expected, &actual)) {
        assertstate_setdescription("(%s) is not the same type as (%s): expected (%s type), actual (%s type)", stringized_expected, stringized_actual, comparable_value_typedescription(&expected), comparable_value_typedescription(&actual));
        failed_assert = true;
    } else if (comparable_value_equalvalues(&expected, &actual, expected.type)) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        comparable_value_valuedescription(&expected, valuestr_expected, sizeof valuestr_expected);
        assertstate_setdescription("(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        failed_assert = true;
    }
    
    if (failed_assert) {
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertaboutequal(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char * restrict file, int line, const char * restrict format, ...)
{
    const long double diff = fabsl(expected - actual);
    if (isgreater(diff, fabsl(precision)) || isnan(diff) || isnan(precision)) {
        assertstate_setdescription("(%s) differs from (%s) by greater than %s(%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, PlusMinus, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotaboutequal(long double expected, const char *stringized_expected, long double actual, const char *stringized_actual, long double precision, const char * restrict file, int line, const char * restrict format, ...)
{
    const long double diff = fabsl(expected - actual);
    if (islessequal(diff, fabsl(precision))) {
        assertstate_setdescription("(%s) differs from (%s) by less than or equal to %s(%.*Lg): expected (%.*Lg), actual (%.*Lg)", stringized_expected, stringized_actual, PlusMinus, DECIMAL_DIG, precision, DECIMAL_DIG, expected, DECIMAL_DIG, actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertsame(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expected != actual) {
        assertstate_setdescription("(%s) is not the same as (%s): expected (%p), actual (%p)", stringized_expected, stringized_actual, expected, actual);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotsame(const void *expected, const char *stringized_expected, const void *actual, const char *stringized_actual, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expected == actual) {
        assertstate_setdescription("(%s) is the same as (%s): (%p)", stringized_expected, stringized_actual, expected);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertequalstrn(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char * restrict file, int line, const char * restrict format, ...)
{
    if ((expected && !actual) || (!expected && actual)
        || (expected && actual && (strncmp(expected, actual, n) != 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE], valuestr_actual[COMPVALUE_STR_SIZE];
        if ((size_t)snprintf(valuestr_expected, sizeof valuestr_expected, "%s", expected) >= sizeof valuestr_expected) {
            pretty_truncate(valuestr_expected, sizeof valuestr_expected);
        }
        if ((size_t)snprintf(valuestr_actual, sizeof valuestr_actual, "%s", actual) >= sizeof valuestr_actual) {
            pretty_truncate(valuestr_actual, sizeof valuestr_actual);
        }
        assertstate_setdescription("(%s) is not equal to (%s): expected (%s), actual (%s)", stringized_expected, stringized_actual, valuestr_expected, valuestr_actual);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotequalstrn(const char *expected, const char *stringized_expected, const char *actual, const char *stringized_actual, size_t n, const char * restrict file, int line, const char * restrict format, ...)
{
    if ((!expected && !actual) || (expected && actual && (strncmp(expected, actual, n) == 0))) {
        char valuestr_expected[COMPVALUE_STR_SIZE];
        if ((size_t)snprintf(valuestr_expected, sizeof valuestr_expected, "%s", expected) >= sizeof valuestr_expected) {
            pretty_truncate(valuestr_expected, sizeof valuestr_expected);
        }
        assertstate_setdescription("(%s) is equal to (%s): (%s)", stringized_expected, stringized_actual, valuestr_expected);
        
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}
