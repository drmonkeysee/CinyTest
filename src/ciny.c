//
//  ciny.c
//  CinyTest
//
//  Created by Brandon Stansbury on 4/8/14.
//  Copyright (c) 2014 Brandon Stansbury. All rights reserved.
//

#include "ciny.h"

#include <complex.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <setjmp.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <time.h>

/////
// Platform-specific Definitions
/////

uint64_t ct_get_currentmsecs(void);
void ct_startcolor(FILE *, size_t),
     ct_endcolor(FILE *);
FILE *ct_replacestream(FILE *);
void ct_restorestream(FILE *, FILE *);

#ifdef _WIN64
// windows console doesn't support utf-8 nicely
static const char * const restrict Ellipsis = "...",
                  * const restrict PlusMinus = "+/-",
                  * const restrict PassedTestSymbol = "+",
                  * const restrict FailedTestSymbol = "x",
                  * const restrict SkippedTestSymbol = "/";
#else
static const char * const restrict Ellipsis = "\u2026",
                  * const restrict PlusMinus = "\u00B1",
                  * const restrict PassedTestSymbol = "\u2713",
                  * const restrict FailedTestSymbol = "\u2717",
                  * const restrict SkippedTestSymbol = "\u2205";
#endif

/////
// Type and Data Definitions
/////

static const char * const restrict HelpOption = "--ct-help",
                  * const restrict VersionOption = "--ct-version",
                  * const restrict VerboseOption = "--ct-verbose",
                  * const restrict ColorizedOption = "--ct-colorized",
                  * const restrict SuppressOutputOption = "--ct-suppress-output",
                  * const restrict IncludeFilterOption = "--ct-include",
                  * const restrict ExcludeFilterOption = "--ct-exclude",
                  * const restrict IgnoredTestSymbol = "?";

enum text_highlight {
    HIGHLIGHT_SUCCESS,
    HIGHLIGHT_FAILURE,
    HIGHLIGHT_IGNORE,
    HIGHLIGHT_SKIPPED,
};

static const char FilterTargetDelimiter = ':';
enum filtertarget {
    FILTER_ANY,
    FILTER_SUITE,
    FILTER_CASE,
    FILTER_ALL,
};
struct testfilter {
    const char *start, *end;
    struct testfilter *next;
    enum filtertarget apply;
};
typedef struct testfilter filterlist;

#define ENV_COPY_COUNT 2u
enum verbositylevel {
    VERBOSITY_MINIMAL,
    VERBOSITY_LIST,
    VERBOSITY_DEFAULT,
    VERBOSITY_FULL,
};
static struct {
    FILE *out, *err;
    filterlist *include, *exclude;
    char *env_copies[ENV_COPY_COUNT];
    enum verbositylevel verbosity;
    bool help, version, colorized;
} RunContext;

#define COMPVALUE_STR_SIZE 75u
enum assert_type {
    ASSERT_UNKNOWN,
    ASSERT_FAILURE,
    ASSERT_IGNORE,
};
static struct {
    const struct testfilter *matched;
    const char *file;
    int line;
    enum assert_type type;
    char description[200 + (COMPVALUE_STR_SIZE * 2)],
         message[1002];
} AssertState;
static jmp_buf AssertSignal;

static const size_t InvalidSuite;
enum suitebreak {
    SUITEBREAK_END,
    SUITEBREAK_OPEN,
    SUITEBREAK_CLOSE,
};
struct runledger {
    size_t passed, failed, ignored;
};
static struct runsummary {
    struct runledger ledger;
    size_t test_count;
    uint64_t total_time;
} RunTotals;

/////
// Inline Function Call Sites
/////

extern inline struct ct_version ct_getversion(void);
extern inline uint32_t ct_versionhex(const struct ct_version[static 1]);
extern inline struct ct_testsuite ct_makesuite_setup_teardown_named(const char *, const struct ct_testcase[], size_t, ct_setupteardown_function *, ct_setupteardown_function *);
extern inline size_t ct_runsuite_withargs(const struct ct_testsuite[static 1], int, const char *[]),
                     ct_runsuite(const struct ct_testsuite[static 1]);
extern inline struct ct_comparable_value ct_makevalue_integer(int, intmax_t),
                                         ct_makevalue_uinteger(int, uintmax_t),
                                         ct_makevalue_floatingpoint(int, long double),
                                         ct_makevalue_complex(int, ct_lcomplex),
                                         ct_makevalue_invalid(int, ...);

/////
// Function Declarations
/////

static void testfilter_print(const struct testfilter *, enum text_highlight);

/////
// Printing and Text Manipulation
/////

#define printout(...) fprintf(RunContext.out, __VA_ARGS__)
#define printerr(...) fprintf(RunContext.err, __VA_ARGS__)

static void print_title(const char * restrict format, ...)
{
    printout("---=== ");
    
    va_list format_args;
    va_start(format_args, format);
    vfprintf(RunContext.out, format, format_args);
    va_end(format_args);

    printout(" ===---\n");
}

static void print_usage(void)
{
    print_title("CinyTest Usage");
    printout("This program contains CinyTest tests and can accept the following command line options:\n\n");
    printout("  %s\t\tPrint this help message (does not run tests).\n", HelpOption);
    printout("  %s\t\tPrint CinyTest version (does not run tests).\n", VersionOption);
    printout("  %s=[0,3]\tOutput verbosity (default: 2).\n", VerboseOption);
    printout("  %s=[yes|no|1|0|true|false]\n\t\t\tColorize test results (default: yes).\n", ColorizedOption);
    printout("  %s=[yes|no|1|0|true|false]\n\t\t\tSuppress output from standard streams (default: yes).\n", SuppressOutputOption);
    printout("  %s=[suite:case,suite:case,...]\n", IncludeFilterOption);
    printout("  %s=[suite:case,suite:case,...]\n", ExcludeFilterOption);
    printout("\t\t\tRun only tests matching include filters and not matching exclude filters;\n\t\t\t'?' matches any character, '*' matches any substring;\n\t\t\t'suite:' and ':case' are shorthand for 'suite:*' and '*:case'.\n");
}

static void print_version(void)
{
    const struct ct_version v = ct_getversion();
    printout("CinyTest %u.%u.%u", v.major, v.minor, v.patch);
#ifdef __VERSION__
    printout(" (" __VERSION__ ")");
#endif
    printout("\n");
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

static void print_labelbox(enum text_highlight style, const char *result_label)
{
    printout("[ ");
    print_highlighted(style, result_label);
    printout(" ] - ");
}

static void print_testresult(enum text_highlight style, const char *result_label, const char *name)
{
    if (RunContext.verbosity == VERBOSITY_MINIMAL) {
        static bool first_call = true;
        if (first_call) {
            first_call = false;
        } else {
            printout(" ");
        }
        print_highlighted(style, result_label);
        return;
    }

    print_labelbox(style, result_label);
    printout("'%s'", name);

    if (RunContext.verbosity > VERBOSITY_LIST) {
        const char *status;
        // if printing a filter it's an include filter...
        enum text_highlight filter_style = HIGHLIGHT_SUCCESS,
                            nomatch_style = filter_style;
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
            case HIGHLIGHT_SKIPPED:
                status = "skipped";
                // ...unless test is skipped
                filter_style = HIGHLIGHT_FAILURE;
                nomatch_style = HIGHLIGHT_SKIPPED;
                break;
            default:
                status = "unknown";
                break;
        }
        printout(" %s", status);

        if (RunContext.verbosity == VERBOSITY_FULL
            && (RunContext.include || RunContext.exclude)) {
            printout(" (filtered: ");
            if (AssertState.matched) {
                testfilter_print(AssertState.matched, filter_style);
            } else {
                print_highlighted(nomatch_style, "no match");
            }
            printout(")");
        }
    }

    printout("\n");
}

static void print_linemessage(const char *message)
{
    if (printout("%s", message) > 0) {
        printout("\n");
    }
}

static bool pretty_truncate(char buffer[], size_t size)
{
    const size_t ellipsis_length = strlen(Ellipsis);
    const ptrdiff_t truncation_index = size - 1 - ellipsis_length;
    
    const bool can_fit_ellipsis = truncation_index >= 0;
    if (can_fit_ellipsis) {
        buffer[truncation_index] = '\0';
        strcat(buffer, Ellipsis);
    }
    
    return can_fit_ellipsis;
}

/////
// Arg Parsing
/////

static bool argflag_on(const char *value)
{
    static const char off_flags[] = {'n', 'N', 'f', 'F', '0'};
    static const size_t flags_count = sizeof off_flags;

    if (!value) return true;
    
    for (size_t i = 0; i < flags_count; ++i) {
        if (*value == off_flags[i]) return false;
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
    return (struct testfilter){.apply = FILTER_ANY};
}

static bool testfilter_match(const struct testfilter self[static 1], const char *name)
{
    static const char char_wildcard = '?', str_wildcard = '*';

    if (!name) return false;

    const char *fcursor = self->start, *ncursor = name,
               *wc_fmarker = NULL, *wc_nmarker = NULL;
    while (*ncursor) {
        if (*fcursor == *ncursor || *fcursor == char_wildcard) {
            ++fcursor;
            ++ncursor;
        } else if (*fcursor == str_wildcard) {
            ++fcursor;
            if (fcursor < self->end) {
                // mark start of wildcard pattern and current name position
                wc_fmarker = fcursor;
                wc_nmarker = ncursor;
            } else {
                // wildcard at end of filter so it automatically matches rest of name
                return true;
            }
        } else if (wc_fmarker) {
            // Wildcard match failed; reset to beginning of wildcard pattern
            // and advance name marker one character to retry match.
            fcursor = wc_fmarker;
            ncursor = ++wc_nmarker;
        } else {
            break;
        }
    }
    const bool eof = fcursor == self->end || (*fcursor == str_wildcard && (fcursor + 1) == self->end);
    return eof && !(*ncursor);
}

static void testfilter_print_prefixed(const struct testfilter self[static 1], enum text_highlight style, bool include_prefix)
{
    const char *prefix = "";
    if (!RunContext.colorized && include_prefix) {
        switch (style) {
            case HIGHLIGHT_SUCCESS:
                prefix = "+";
                break;
            case HIGHLIGHT_FAILURE:
                prefix = "-";
                break;
            default:
                break;
        }
    }
    print_highlighted(style, "%s%.*s", prefix, (int)(self->end - self->start), self->start);
}

static void testfilter_print_noprefix(const struct testfilter self[static 1], enum text_highlight style)
{
    testfilter_print_prefixed(self, style, false);
}

static void testfilter_print(const struct testfilter self[static 1], enum text_highlight style)
{
    testfilter_print_prefixed(self, style, true);
}

static filterlist *filterlist_new(void)
{
    return NULL;
}

static void filterlist_push(filterlist * restrict self[static 1], struct testfilter filter)
{
    struct testfilter * const filter_node = malloc(sizeof *filter_node);
    *filter_node = filter;
    filter_node->next = *self;
    *self = filter_node;
}

static bool filterlist_any(const filterlist *self, enum filtertarget target)
{
    for (; self; self = self->next) {
        if (self->apply == target) return true;
    }
    return false;
}

static struct testfilter *filterlist_apply(filterlist * restrict self, const char * restrict suite_name, const char * restrict case_name)
{
    for (; self; self = self->next) {
        switch (self->apply) {
            case FILTER_ANY:
                if (testfilter_match(self, suite_name) || testfilter_match(self, case_name)) return self;
                break;
            case FILTER_SUITE:
                if (testfilter_match(self, suite_name)) return self;
                break;
            case FILTER_CASE:
                if (testfilter_match(self, case_name)) return self;
                break;
            case FILTER_ALL: {
                // target ALL filters come in case, suite pairs; consume both filters here
                struct testfilter * const case_filter = self,
                                  * const suite_filter = self = self->next;
                if (testfilter_match(suite_filter, suite_name) && testfilter_match(case_filter, case_name)) return case_filter;
                break;
            }
            default:
                printerr("WARNING: unknown test filter target encountered!\n");
                break;
        }
    }
    return NULL;
}

static void filterlist_print(const filterlist *self, enum filtertarget match, enum text_highlight style)
{
    for (; self; self = self->next) {
        if (self->apply != match) continue;

        if (self->apply == FILTER_ALL) {
            const struct testfilter * const fcase = self,
                                    * const fsuite = self = self->next;
            testfilter_print(fsuite, style);
            print_highlighted(style, "%c", FilterTargetDelimiter);
            testfilter_print_noprefix(fcase, style);
        } else {
            testfilter_print(self, style);
        }
        
        if (filterlist_any(self->next, match)) {
            printout(", ");
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

static const char *parse_filterexpr(const char * restrict cursor, filterlist * restrict fl[static 1])
{
    static const char expr_delimiter = ',';

    struct testfilter filter = testfilter_make();

    filter.start = cursor;
    for (char c = *cursor; c && c != expr_delimiter; c = *(++cursor)) {
        if (c == FilterTargetDelimiter && filter.apply == FILTER_ANY) {
            // first target delimiter seen so this is a (possibly empty) suite filter
            filter.end = cursor;
            filter.apply = FILTER_SUITE;
        } else if (filter.apply == FILTER_SUITE) {
            // Suite filter followed by something other than end-of-expression,
            // so next filter is a case filter if current filter is empty
            // or this is a pair of all filters.
            enum filtertarget next_target = FILTER_CASE;

            if (filter.start < filter.end) {
                next_target = filter.apply = FILTER_ALL;
                filterlist_push(fl, filter);
            }

            filter = testfilter_make();
            filter.start = cursor;
            filter.apply = next_target;
        }
    }

    if (filter.apply != FILTER_SUITE) {
        filter.end = cursor;
    }
    
    if (filter.start < filter.end) {
        filterlist_push(fl, filter);
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

static const char *runcontext_capturevar(const char * restrict env_var, char * restrict slot[static 1])
{
    *slot = malloc(strlen(env_var) + 1);
    strcpy(*slot, env_var);
    return *slot;
}

static void runcontext_init(int argc, const char *argv[])
{
    RunContext.help = RunContext.version = false;
    RunContext.verbosity = VERBOSITY_DEFAULT;

    const char *color_option = NULL,
                *verbosity_option = NULL,
                *suppress_output_option = NULL,
                *include_filter_option = NULL,
                *exclude_filter_option = NULL;
    
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
            } else if (strstr(arg, ExcludeFilterOption)) {
                exclude_filter_option = arg_value(arg);
            }
        }
    }
    
    if (!verbosity_option) {
        verbosity_option = getenv("CINYTEST_VERBOSE");
    }
    RunContext.verbosity = argverbose(verbosity_option);
    
    if (!color_option) {
        color_option = getenv("CINYTEST_COLORIZED");
    }
    RunContext.colorized = argflag_on(color_option);

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
            include_filter_option = runcontext_capturevar(include_filter_option, RunContext.env_copies);
        }
    }
    RunContext.include = parse_filters(include_filter_option);

    if (!exclude_filter_option) {
        exclude_filter_option = getenv("CINYTEST_EXCLUDE");
        if (exclude_filter_option) {
            // copy env value to prevent invalidated pointers
            exclude_filter_option = runcontext_capturevar(exclude_filter_option, RunContext.env_copies + 1);
        }
    }
    RunContext.exclude = parse_filters(exclude_filter_option);
}

static bool runcontext_suppressoutput(void)
{
    return RunContext.out != stdout;
}

static void runcontext_printtargetedfilters(enum filtertarget target)
{
    const bool any_include = filterlist_any(RunContext.include, target),
               any_exclude = filterlist_any(RunContext.exclude, target),
               has_output = target == FILTER_ANY || any_include || any_exclude;

    const char *label;
    switch (target) {
        case FILTER_ANY:
            label = "Filters";
            break;
        case FILTER_SUITE:
            label = "Suites";
            break;
        case FILTER_CASE:
            label = "Cases";
            break;
        case FILTER_ALL:
            label = "All";
            break;
        default:
            label = "Unknown filter target";
            break;
    }
    if (has_output) {
        printout("%s: ", label);
    }

    if (any_include) {
        filterlist_print(RunContext.include, target, HIGHLIGHT_SUCCESS);
        if (any_exclude) {
            printout(", ");
        }
    }

    if (any_exclude) {
        filterlist_print(RunContext.exclude, target, HIGHLIGHT_FAILURE);
    }

    if (has_output) {
        printout("\n");
    }
}

static void runcontext_printfilters(void)
{
    if (!RunContext.include && !RunContext.exclude) return;

    runcontext_printtargetedfilters(FILTER_ANY);
    printout(" ");
    runcontext_printtargetedfilters(FILTER_SUITE);
    printout(" ");
    runcontext_printtargetedfilters(FILTER_CASE);
    printout(" ");
    runcontext_printtargetedfilters(FILTER_ALL);
}

static void runcontext_print(void)
{
    const struct ct_version v = ct_getversion();
    print_title("CinyTest v%u.%u.%u", v.major, v.minor, v.patch);
    printout("Colorized: %s\n", argflag_tostring(RunContext.colorized));
    printout("Suppress Output: %s\n", argflag_tostring(runcontext_suppressoutput()));
    runcontext_printfilters();
    printout("\n");
}

static void runcontext_cleanup(void)
{
    ct_restorestream(stdout, RunContext.out);
    RunContext.out = NULL;
    
    ct_restorestream(stderr, RunContext.err);
    RunContext.err = NULL;

    filterlist_free(RunContext.include);
    RunContext.include = NULL;

    filterlist_free(RunContext.exclude);
    RunContext.exclude = NULL;

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
    return (struct runsummary){.test_count = 0};
}

static void runsummary_print(const struct runsummary self[static 1])
{
    printout("Ran %zu tests (%.3f seconds): ", self->test_count, self->total_time / 1000.0);
    print_highlighted(HIGHLIGHT_SUCCESS, "%zu passed", self->ledger.passed);
    printout(", ");
    print_highlighted(HIGHLIGHT_FAILURE, "%zu failed", self->ledger.failed);
    printout(", ");
    print_highlighted(HIGHLIGHT_IGNORE, "%zu ignored", self->ledger.ignored);
    printout(".\n");
}

static void runtotals_add(const struct runsummary summary[static 1])
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
    AssertState.matched = NULL;
    AssertState.file = NULL;
    AssertState.line = 0;
    AssertState.description[0] = AssertState.message[0] = '\0';
}

static void assertstate_handlefailure(const char * restrict test_name, struct runledger ledger[restrict static 1])
{
    ++ledger->failed;

    print_testresult(HIGHLIGHT_FAILURE, FailedTestSymbol, test_name);

    if (RunContext.verbosity > VERBOSITY_MINIMAL) {
        printout("%s L.%d : %s\n", AssertState.file, AssertState.line, AssertState.description);
        print_linemessage(AssertState.message);
    }
}

static void assertstate_handleignore(const char * restrict test_name, struct runledger ledger[restrict static 1])
{
    ++ledger->ignored;
    
    print_testresult(HIGHLIGHT_IGNORE, IgnoredTestSymbol, test_name);

    if (RunContext.verbosity > VERBOSITY_MINIMAL) {
        print_linemessage(AssertState.message);
    }
}

static void assertstate_handle(const char * restrict test_name, struct runledger ledger[restrict static 1])
{
    switch (AssertState.type) {
        case ASSERT_FAILURE:
            assertstate_handlefailure(test_name, ledger);
            break;
        case ASSERT_IGNORE:
            assertstate_handleignore(test_name, ledger);
            break;
        default:
            printerr("WARNING: unknown assertion type encountered!\n");
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
static void assertstate_setvmessage(const char * restrict format, va_list format_args)
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

static bool comparable_value_equaltypes(const struct ct_comparable_value expected[static 1], const struct ct_comparable_value actual[static 1])
{
    return expected->type == actual->type;
}

static const char *comparable_value_typedescription(const struct ct_comparable_value value[static 1])
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

static bool comparable_value_equalvalues(const struct ct_comparable_value expected[static 1], const struct ct_comparable_value actual[static 1], enum ct_valuetype_annotation type)
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

static void comparable_value_valuedescription(const struct ct_comparable_value value[restrict static 1], char buffer[restrict], size_t size)
{
    int write_count;
    
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

static void testcase_run(const struct ct_testcase self[restrict static 1], void * restrict test_context, struct runledger ledger[restrict static 1])
{
    if (!self->test) {
        printerr("WARNING: Test case '%s' skipped, NULL function pointer found!\n", self->name);
        return;
    }
    
    self->test(test_context);
    
    ++ledger->passed;
    print_testresult(HIGHLIGHT_SUCCESS, PassedTestSymbol, self->name);
}

static void testsuite_printheader(const struct ct_testsuite self[static 1], time_t start_time)
{
    char formatted_datetime[30];
    const size_t format_length = strftime(formatted_datetime, sizeof formatted_datetime, "%FT%T%z", localtime(&start_time));
    printout("Test suite '%s' started at %s\n", self->name,
           format_length ? formatted_datetime : "Invalid Date (formatted output may have exceeded buffer size)");
}

static enum suitebreak suitebreak_make(void)
{
    return RunContext.verbosity > VERBOSITY_LIST ? SUITEBREAK_OPEN : SUITEBREAK_END;
}

static void suitebreak_open(enum suitebreak state[restrict static 1], const struct ct_testsuite suite[restrict static 1])
{
    if (*state == SUITEBREAK_OPEN) {
        testsuite_printheader(suite, time(NULL));
        *state = SUITEBREAK_CLOSE;
    }
}

static void suitebreak_close(enum suitebreak state[restrict static 1], const struct runsummary summary[restrict static 1])
{
    if (*state == SUITEBREAK_CLOSE) {
        runsummary_print(summary);
        *state = SUITEBREAK_END;
    }
}

static void testsuite_runcase(const struct ct_testsuite self[restrict static 1], const struct ct_testcase current_case[restrict static 1], struct runsummary summary[restrict static 1], enum suitebreak sb_ref[restrict static 1])
{
    assertstate_reset();

    if (RunContext.include) {
        const struct testfilter * const match = filterlist_apply(RunContext.include, self->name, current_case->name);
        if (match) {
            AssertState.matched = match;
        } else {
            --summary->test_count;

            if (RunContext.verbosity == VERBOSITY_FULL) {
                suitebreak_open(sb_ref, self);
                print_testresult(HIGHLIGHT_SKIPPED, SkippedTestSymbol, current_case->name);
            }
            
            return;
        }
    }
    
    if (RunContext.exclude) {
        const struct testfilter * const match = filterlist_apply(RunContext.exclude, self->name, current_case->name);
        if (match) {
            AssertState.matched = match;
            --summary->test_count;

            if (RunContext.verbosity == VERBOSITY_FULL) {
                suitebreak_open(sb_ref, self);
                print_testresult(HIGHLIGHT_SKIPPED, SkippedTestSymbol, current_case->name);
            }
            
            return;
        }
    }
    
    suitebreak_open(sb_ref, self);

    void *test_context = NULL;
    if (self->setup) {
        self->setup(&test_context);
    }
    
    if (setjmp(AssertSignal)) {
        assertstate_handle(current_case->name, &summary->ledger);
    } else {
        testcase_run(current_case, test_context, &summary->ledger);
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
        enum suitebreak sb = suitebreak_make();
        summary.test_count = self->count;

        for (size_t i = 0; i < self->count; ++i) {
            testsuite_runcase(self, self->tests + i, &summary, &sb);
        }
        
        summary.total_time = ct_get_currentmsecs() - start_msecs;
        suitebreak_close(&sb, &summary);
    } else {
        printerr("WARNING: NULL test suite or NULL test list detected, no tests run!\n");
        summary.ledger.failed = InvalidSuite;
    }
    
    runtotals_add(&summary);
}

/////
// Public Functions
/////

size_t ct_runcount_withargs(const struct ct_testsuite suites[], size_t count, int argc, const char *argv[])
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
            for (size_t i = 0; i < count; ++i) {
                testsuite_run(suites + i);
            }
            if (RunContext.verbosity == VERBOSITY_MINIMAL && RunTotals.test_count) {
                printout("\n");
            }
            runtotals_print();
        } else {
            printerr("WARNING: NULL test suite collection detected, no test suites run!\n");
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

void ct_internal_asserttrue(bool expression, const char *stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (!expression) {
        assertstate_setdescription("(%s) is true failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertfalse(bool expression, const char *stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is false failed", stringized_expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnull(const void * restrict expression, const char *stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
{
    if (expression) {
        assertstate_setdescription("(%s) is NULL failed: (%p)", stringized_expression, expression);
        assertstate_raise_signal(ASSERT_FAILURE, file, line, format);
    }
}

void ct_internal_assertnotnull(const void * restrict expression, const char *stringized_expression, const char * restrict file, int line, const char * restrict format, ...)
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
