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
void ct_startcolor(FILE *, size_t);
void ct_endcolor(FILE *);
FILE *ct_replacestream(FILE *);
void ct_restorestream(FILE *, FILE *);

#ifdef _WIN64
// windows console doesn't support utf-8 nicely
static const char * const restrict Ellipsis = "...";
static const char * const restrict PlusMinus = "+/-";
static const char * const restrict PassedTestSymbol = "+";
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
static const char * const restrict VerboseOption = "--ct-verbose";
static const char * const restrict ColorizedOption = "--ct-colorized";
static const char * const restrict SuppressOutputOption = "--ct-suppress-output";
static const char * const restrict IncludeFilterOption = "--ct-include";
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

enum filter_target_flags {
    FILTER_NONE = 0,
    FILTER_SUITE = 1 << 0,
    FILTER_CASE = 1 << 1,
    FILTER_ALL = FILTER_SUITE | FILTER_CASE
};
struct testfilter {
    const char *start, *end;
    struct testfilter *next;
    enum filter_target_flags apply;
};
typedef struct testfilter filterlist;

#define ENV_COPY_COUNT 2
enum verbosity_level {
    VERBOSITY_MINIMAL,
    VERBOSITY_LIST,
    VERBOSITY_DEFAULT,
    VERBOSITY_FULL
};
static struct {
    FILE *out, *err;
    filterlist *include;
    char *env_copies[ENV_COPY_COUNT];
    enum verbosity_level verbosity;
    bool help;
    bool version;
    bool colorized;
} RunContext;

/////
// Inline Function Call Sites
/////

extern inline struct ct_version ct_getversion(void);
extern inline uint32_t ct_versionhex(const struct ct_version *);
extern inline struct ct_testsuite ct_makesuite_setup_teardown_named(const char * restrict, const struct ct_testcase[], size_t, ct_setupteardown_function, ct_setupteardown_function);
extern inline size_t ct_runsuite_withargs(const struct ct_testsuite *, int, const char *[]);
extern inline size_t ct_runsuite(const struct ct_testsuite *);
extern inline struct ct_comparable_value ct_makevalue_integer(int, intmax_t);
extern inline struct ct_comparable_value ct_makevalue_uinteger(int, uintmax_t);
extern inline struct ct_comparable_value ct_makevalue_floatingpoint(int, long double);
extern inline struct ct_comparable_value ct_makevalue_complex(int, ct_lcomplex);
extern inline struct ct_comparable_value ct_makevalue_invalid(int, ...);

/////
// Printing and Text Manipulation
/////

static void print_title(const char * restrict format, ...)
{
    fprintf(RunContext.out, "---=== ");
    
    va_list format_args;
    va_start(format_args, format);
    vfprintf(RunContext.out, format, format_args);
    va_end(format_args);

    fprintf(RunContext.out, " ===---\n");
}

static void print_usage(void)
{
    print_title("CinyTest Usage");
    fprintf(RunContext.out, "This program contains CinyTest tests and can accept the following command line options:\n\n");
    fprintf(RunContext.out, "  %s\t\tPrint this help message (does not run tests).\n", HelpOption);
    fprintf(RunContext.out, "  %s\t\tPrint CinyTest version (does not run tests).\n", VersionOption);
    fprintf(RunContext.out, "  %s=[0,3]\tOutput verbosity (default: 2).\n", VerboseOption);
    fprintf(RunContext.out, "  %s=[yes|no|1|0|true|false]\n\t\t\tColorize test results (default: yes).\n", ColorizedOption);
    fprintf(RunContext.out, "  %s=[yes|no|1|0|true|false]\n\t\t\tSuppress output from standard streams (default: yes).\n", SuppressOutputOption);
}

static void print_version(void)
{
    const struct ct_version v = ct_getversion();
    fprintf(RunContext.out, "CinyTest %u.%u.%u", v.major, v.minor, v.patch);
#ifdef __VERSION__
    fprintf(RunContext.out, " (" __VERSION__ ")");
#endif
    fprintf(RunContext.out, "\n");
}

static void print_highlighted(enum text_highlight style, const char * restrict format, ...)
{
    if (RunContext.colorized) {
        ct_startcolor(RunContext.out, style);
    }
    
    va_list format_args;
    va_start(format_args, format);
    vfprintf(RunContext.out, format, format_args);
    va_end(format_args);
    
    if (RunContext.colorized) {
        ct_endcolor(RunContext.out);
    }
}

static void print_labelbox(enum text_highlight style, const char * restrict result_label)
{
    fprintf(RunContext.out, "[ ");
    print_highlighted(style, result_label);
    fprintf(RunContext.out, " ] - ");
}

static void print_testresult(enum text_highlight style, const char * restrict result_label, const char * restrict name)
{
    if (RunContext.verbosity == VERBOSITY_MINIMAL) {
        print_highlighted(style, "%s ", result_label);
        return;
    }

    print_labelbox(style, result_label);
    fprintf(RunContext.out, "'%s'", name);

    if (RunContext.verbosity > VERBOSITY_LIST) {
        const char *status;
        switch (style) {
            case HIGHLIGHT_SUCCESS:
                status = "success";
                break;
            case HIGHLIGHT_FAILURE:
                status = "failure";
                break;
            case HIGHLIGHT_IGNORE:
                status = "ignored";
                break;
            default:
                status = "unknown";
                break;
        }
        fprintf(RunContext.out, " %s", status);
    }

    fprintf(RunContext.out, "\n");
}

static void print_linemessage(const char *message)
{
    if (fprintf(RunContext.out, "%s", message) > 0) {
        fprintf(RunContext.out, "\n");
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
// Arg Parsing
/////

static bool argflag_on(const char *value)
{
    static const char off_flags[] = { 'n', 'N', 'f', 'F', '0' };
    static const size_t flags_count = sizeof off_flags;

    if (!value) return true;
    
    for (size_t i = 0; i < flags_count; ++i) {
        if (value[0] == off_flags[i]) return false;
    }

    return true;
}

static int argverbose(const char *value)
{
    if (!value) return VERBOSITY_DEFAULT;

    const int arg = atoi(value);
    return arg < VERBOSITY_MINIMAL ? VERBOSITY_MINIMAL : (arg > VERBOSITY_FULL ? VERBOSITY_FULL : arg);
}

static const char *argflag_tostring(bool value)
{
    return value ? "Yes" : "No";
}

static const char *arg_value(const char *arg)
{
    const char *delimiter = strrchr(arg, '=');
    
    if (delimiter) return ++delimiter;
    
    return NULL;
}

/////
// Test Filters
/////

static struct testfilter testfilter_make(void)
{
    return (struct testfilter){ .apply = FILTER_NONE };
}

static bool testfilter_apply(const struct testfilter *self, const char * restrict name)
{
    if (!self || !self->start || !self->end || !name) return false;

    const char *fcursor = self->start, *ncursor = name;
    while (fcursor < self->end && *ncursor) {
        if (*fcursor == *ncursor) {
            ++fcursor, ++ncursor;
        } else {
            break;
        }
    }
    return fcursor == self->end && !(*ncursor);
}

static filterlist *filterlist_new(void)
{
    return NULL;
}

static void filterlist_push(filterlist **self_ref, struct testfilter filter)
{
    struct testfilter * const filter_node = malloc(sizeof *filter_node);
    *filter_node = filter;
    filter_node->next = *self_ref;
    *self_ref = filter_node;
}

static bool filterlist_any(filterlist *self, enum filter_target_flags match)
{
    for (; self; self = self->next) {
        if (self->apply == match) return true;
    }

    return false;
}

static struct testfilter *filterlist_apply(filterlist *self, enum filter_target_flags target, const char * restrict name)
{
    for (; self; self = self->next) {
        if ((self->apply & target) != target) continue;

        if (testfilter_apply(self, name)) return self;
    }
    return NULL;
}

static void filterlist_print(filterlist *self, enum filter_target_flags match, enum text_highlight style)
{
    for (; self; self = self->next) {
        if (self->apply != match) continue;

        print_highlighted(style, "%s%.*s", RunContext.colorized ? "" : "+", (int)(self->end - self->start), self->start);
        
        if (filterlist_any(self->next, match)) {
            fprintf(RunContext.out, ", ");
        }
    }
}

static void filterlist_free(filterlist *self)
{
    while (self) {
        struct testfilter * const head = self;
        self = head->next;
        free(head);
    }
}

static const char *parse_filterexpr(const char * restrict cursor, filterlist **fl_ref)
{
    static const char target_delimiter = ':';
    static const char expr_delimiter = ',';

    struct testfilter filter = testfilter_make();

    filter.start = cursor;
    for (char c = *cursor; c && c != expr_delimiter; c = *(++cursor)) {
        // First target delimiter seen so this expression contains
        // a suite-only filter and a test-only filter.
        if (c == target_delimiter && filter.apply != FILTER_CASE) {
            filter.end = cursor;
            filter.apply = FILTER_SUITE;

            // only add the filter if it's not empty
            if (filter.start < filter.end) {
                filterlist_push(fl_ref, filter);
            }

            filter = testfilter_make();
            // start after the delimiter but let the for loop advance the cursor
            filter.start = cursor + 1;
            filter.apply = FILTER_CASE;
        }
    }
    filter.end = cursor;
    
    // If filter target has not been determined by now
    // then no target delimiters were encountered and
    // this filter applies to all targets.
    if (filter.apply == FILTER_NONE) {
        filter.apply = FILTER_ALL;
    }
    
    // only add the filter if it's not empty
    if (filter.start < filter.end) {
        filterlist_push(fl_ref, filter);
    }
    
    // Finish the expression either by consuming the
    // delimiter or clearing the cursor.
    if (*cursor == expr_delimiter) {
        ++cursor;
    } else {
        cursor = NULL;
    }

    return cursor;
}

static filterlist *parse_filters(const char *filter_option)
{
    filterlist *fl = filterlist_new();

    const char *cursor = filter_option;
    while (cursor) {
        cursor = parse_filterexpr(cursor, &fl);
    }

    return fl;
}

/////
// Run Context
/////

static void runcontext_init(int argc, const char *argv[])
{
    RunContext.help = RunContext.version = false;
    RunContext.verbosity = VERBOSITY_DEFAULT;

    const char *color_option = NULL,
                *verbosity_option = NULL,
                *suppress_output_option = NULL,
                *include_filter_option = NULL;
    
    if (argv) {
        for (int i = 0; i < argc; ++i) {
            const char * const arg = argv[i];
            if (!arg) {
                continue;
            } else if (strstr(arg, HelpOption)) {
                RunContext.help = true;
            } else if (strstr(arg, VersionOption)) {
                RunContext.version = true;
            } else if (strstr(arg, VerboseOption)) {
                verbosity_option = arg_value(arg);
            } else if (strstr(arg, ColorizedOption)) {
                color_option = arg_value(arg);
            } else if (strstr(arg, SuppressOutputOption)) {
                suppress_output_option = arg_value(arg);
            } else if (strstr(arg, IncludeFilterOption)) {
                include_filter_option = arg_value(arg);
            }
        }
    }
    
    if (!color_option) {
        color_option = getenv("CINYTEST_COLORIZED");
    }
    RunContext.colorized = argflag_on(color_option);

    if (!verbosity_option) {
        verbosity_option = getenv("CINYTEST_VERBOSE");
    }
    RunContext.verbosity = argverbose(verbosity_option);
    
    if (!suppress_output_option) {
        suppress_output_option = getenv("CINYTEST_SUPPRESS_OUTPUT");
    }
    if (argflag_on(suppress_output_option)) {
        RunContext.out = ct_replacestream(stdout);
        RunContext.err = ct_replacestream(stderr);
    } else {
        RunContext.out = stdout;
        RunContext.err = stderr;
    }

    if (!include_filter_option) {
        include_filter_option = getenv("CINYTEST_INCLUDE");
        if (include_filter_option) {
            // copy env value to prevent invalidated pointers
            RunContext.env_copies[0] = malloc(strlen(include_filter_option) + 1);
            strcpy(RunContext.env_copies[0], include_filter_option);
            include_filter_option = RunContext.env_copies[0];
        }
    }
    RunContext.include = parse_filters(include_filter_option);
}

static bool runcontext_suppressoutput(void)
{
    return RunContext.out != stdout;
}

static void runcontext_printfilters(void)
{
    if (!RunContext.include) return;

    fprintf(RunContext.out, "Filters: ");
    filterlist_print(RunContext.include, FILTER_ALL, HIGHLIGHT_SUCCESS);
    fprintf(RunContext.out, "\n");

    if (filterlist_any(RunContext.include, FILTER_SUITE)) {
        fprintf(RunContext.out, "  Suites: ");
        filterlist_print(RunContext.include, FILTER_SUITE, HIGHLIGHT_SUCCESS);
        fprintf(RunContext.out, "\n");
    }

    if (filterlist_any(RunContext.include, FILTER_CASE)) {
        fprintf(RunContext.out, "  Cases: ");
        filterlist_print(RunContext.include, FILTER_CASE, HIGHLIGHT_SUCCESS);
        fprintf(RunContext.out, "\n");
    }
}

static void runcontext_print(void)
{
    const struct ct_version v = ct_getversion();
    print_title("CinyTest v%u.%u.%u", v.major, v.minor, v.patch);
    fprintf(RunContext.out, "Colorized: %s\n", argflag_tostring(RunContext.colorized));
    fprintf(RunContext.out, "Suppress Output: %s\n", argflag_tostring(runcontext_suppressoutput()));
    runcontext_printfilters();
    fprintf(RunContext.out, "\n");
}

static void runcontext_cleanup(void)
{
    ct_restorestream(stdout, RunContext.out);
    RunContext.out = NULL;
    
    ct_restorestream(stderr, RunContext.err);
    RunContext.err = NULL;

    filterlist_free(RunContext.include);
    RunContext.include = NULL;

    for (size_t i = 0; i < ENV_COPY_COUNT; ++i) {
        free(RunContext.env_copies[i]);
        RunContext.env_copies[i] = NULL;
    }
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
    fprintf(RunContext.out, "Ran %zu tests (%.3f seconds): ", self->test_count, self->total_time / 1000.0);
    print_highlighted(HIGHLIGHT_SUCCESS, "%zu passed", self->ledger.passed);
    fprintf(RunContext.out, ", ");
    print_highlighted(HIGHLIGHT_FAILURE, "%zu failed", self->ledger.failed);
    fprintf(RunContext.out, ", ");
    print_highlighted(HIGHLIGHT_IGNORE, "%zu ignored", self->ledger.ignored);
    fprintf(RunContext.out, ".\n");
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
        print_labelbox(HIGHLIGHT_FAILURE, "FAILED");
    } else {
        print_labelbox(HIGHLIGHT_SUCCESS, "SUCCESS");
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
    AssertState.description[0] = AssertState.message[0] = '\0';
}

static void assertstate_handlefailure(const char * restrict test_name, struct runledger *ledger)
{
    ++ledger->failed;

    print_testresult(HIGHLIGHT_FAILURE, FailedTestSymbol, test_name);

    if (RunContext.verbosity > VERBOSITY_MINIMAL) {
        fprintf(RunContext.out, "%s L.%d : %s\n", AssertState.file, AssertState.line, AssertState.description);
        print_linemessage(AssertState.message);
    }
}

static void assertstate_handleignore(const char * restrict test_name, struct runledger *ledger)
{
    ++ledger->ignored;
    
    print_testresult(HIGHLIGHT_IGNORE, IgnoredTestSymbol, test_name);

    if (RunContext.verbosity > VERBOSITY_MINIMAL) {
        print_linemessage(AssertState.message);
    }
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
            fprintf(RunContext.err, "WARNING: unknown assertion type encountered!\n");
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
} while (false)

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
        fprintf(RunContext.err, "WARNING: Test case at index %zu skipped, NULL function pointer found!\n", index);
        return;
    }
    
    self->test(test_context);
    
    ++ledger->passed;
    print_testresult(HIGHLIGHT_SUCCESS, PassedTestSymbol, self->name);
}

static void testsuite_printheader(const struct ct_testsuite *self, time_t start_time)
{
    char formatted_datetime[30];
    const size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, "%FT%T%z", localtime(&start_time));
    fprintf(RunContext.out, "Test suite '%s' started at %s\n", self->name,
           format_length ? formatted_datetime : "Invalid Date (formatted output may have exceeded buffer size)");
}

static void testsuite_runcase(const struct ct_testsuite *self, size_t index, struct runsummary *summary)
{
    assertstate_reset();
    const struct ct_testcase * const current_test = self->tests + index;

    if (RunContext.include) {
        const struct testfilter * const applied_include = filterlist_apply(RunContext.include, FILTER_CASE, current_test->name);
        if (!applied_include) {
            --summary->test_count;
            return;
        }
    }
    
    void *test_context = NULL;
    if (self->setup) {
        self->setup(&test_context);
    }
    
    if (setjmp(AssertSignal)) {
        assertstate_handle(current_test->name, &summary->ledger);
    } else {
        testcase_run(current_test, test_context, index, &summary->ledger);
    }
    
    if (self->teardown) {
        self->teardown(&test_context);
    }
}

static void testsuite_run(const struct ct_testsuite *self)
{
    struct runsummary summary = runsummary_make();
    
    if (self && self->tests) {
        if (RunContext.include) {
            const struct testfilter * const applied_include = filterlist_apply(RunContext.include, FILTER_SUITE, self->name);
            if (!applied_include) return;
        }

        const uint64_t start_msecs = ct_get_currentmsecs();
        summary.test_count = self->count;
        if (RunContext.verbosity > VERBOSITY_LIST) {
            testsuite_printheader(self, time(NULL));
        }
        
        for (size_t i = 0; i < self->count; ++i) {
            testsuite_runcase(self, i, &summary);
        }
        
        summary.total_time = ct_get_currentmsecs() - start_msecs;
        if (RunContext.verbosity > VERBOSITY_LIST) {
            runsummary_print(&summary);
        }
    } else {
        fprintf(RunContext.err, "WARNING: NULL test suite or NULL test list detected, no tests run!\n");
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
        if (RunContext.verbosity == VERBOSITY_FULL) {
            runcontext_print();
        }

        if (suites) {
            if (RunContext.verbosity == VERBOSITY_MINIMAL) {
                fprintf(RunContext.out, "[ ");
            }
            for (size_t i = 0; i < count; ++i) {
                const struct ct_testsuite * const suite = suites + i;
                testsuite_run(suite);
            }
            if (RunContext.verbosity == VERBOSITY_MINIMAL) {
                fprintf(RunContext.out, "]\n");
            }
            runtotals_print();
        } else {
            fprintf(RunContext.err, "WARNING: NULL test suite collection detected, no test suites run!\n");
            RunTotals.ledger.failed = InvalidSuite;
        }
    }

    runcontext_cleanup();
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
