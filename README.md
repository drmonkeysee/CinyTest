# CinyTest

CinyTest is a lightweight library for defining and running unit tests in C. It targets the C17 standard (mostly) and follows the guidelines of [Modern C](https://modernc.gforge.inria.fr).

## Features

- unit test and suite creation
- unit suite execution, including setup and teardown support
- configurable test output to stdout
- include and exclude test filtering
- JUnit-style output support
- test assertions including:
	- value equality, including approximate equality for floating point
	- pointer equality and NULL testing
	- C-string equality
	- general true/false asserts

## Build CinyTest

The [Makefile](http://www.gnu.org/software/make/) will build CinyTest static and dynamic (shared) libraries for either macOS ([clang](http://clang.llvm.org)) or Linux ([gcc](https://gcc.gnu.org)). The **mac** folder also contains an Xcode project used for development that only builds a static library.

For Windows builds there is a batch file: **winbuild.bat**. Microsoft's dev tools do not support several C99 and C11 features so the batch file uses clang instead of [cl.exe](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options?view=vs-2019). See [Windows Support](#windows-support) below for more detail.

The Makefile has the following build targets:

- `release` the default target; build CinyTest libraries and binary tree sample executables with full optimizations
- `debug` build CinyTest libraries and binary tree sample executables with debug symbols and no optimizations
- `check` verify CinyTest by running the sample tests
- `install` add CinyTest artifacts to **/usr/local**
- `uninstall` remove CinyTest artifacts from **/usr/local**
- `clean` delete all build artifacts; run this when switching between debug and release builds to make sure all artifacts are rebuilt

All of the Makefile artifacts are placed in a folder named **build**.

The Windows batch file emulates a simplified version of the Makefile, building all targets unconditionally and clearing any previous build artifacts each time.

The Xcode project consists of the following targets:

- **CinyTest**: main target for CinyTest source code and unit tests; builds the CinyTest static library and runs the XCTest unit tests
- **Sample**: additional target illustrating the use of CinyTest to test a binary tree module; includes command-line binary to exercise the binary tree module and an XCTest class for bootstrapping the binary tree unit tests into Xcode

Finally, documentation can be generated using the [Doxygen](http://www.doxygen.org) configuration file provided in the **doc** folder.

## Example

A simple example demonstrating the use of CinyTest as an external dependency can be found in the [CinyTest-Example](https://github.com/drmonkeysee/CinyTest-Example) repo.

Running this example on the command line (assuming all tests pass) will output something like the following:

	Test suite 'rectangle_tests' started at 2019-09-03T22:24:06-0700
	[ ✓ ] - 'rectanglemake_createsrectangle' success
	[ ✓ ] - 'rectanglearea_calculatesarea' success
	[ ✓ ] - 'rectanglehypotenuse_calculateshypotenuse' success
	[ ✓ ] - 'rectangletostring_buildsrectanglestring' success
	[ ✓ ] - 'rectangleprint_printsrectangle' success
	Ran 5 tests (0.000 seconds): 5 passed.
	Test suite 'circle_tests' started at 2019-09-03T22:24:06-0700
	[ ✓ ] - 'circlemake_createscircle' success
	[ ✓ ] - 'circlediameter_calculatesdiameter' success
	[ ✓ ] - 'circlearea_calculatesarea' success
	[ ✓ ] - 'circletostring_buildscirclestring' success
	[ ✓ ] - 'circleprint_printscircle' success
	Ran 5 tests (0.001 seconds): 5 passed.
	[ SUCCESS ] - Ran 10 tests (0.001 seconds): 10 passed.

This example runs two test suites of four test cases each.

## Options

Any program that CinyTest is compiled into will support a set of command-line options and environment variables that control CinyTest behavior. Command-line options take precedence over environment variables if both are specified.

CLI Option             | Environment Variable       | Description
---------------------- | -------------------------- | -----------
`--ct-help`            | N/A                        | Print CinyTest usage
`--ct-version`         | N/A                        | Print CinyTest version
`--ct-verbose`         | `CINYTEST_VERBOSE`         | Set output verbosity
`--ct-colorized`       | `CINYTEST_COLORIZED`       | Toggle colorized output in test results
`--ct-suppress-output` | `CINYTEST_SUPPRESS_OUTPUT` | Toggle capture of standard stream output
`--ct-include`         | `CINYTEST_INCLUDE`         | Include test filters; see [Test Filters](#test-filters) section below for more details
`--ct-exclude`         | `CINYTEST_EXCLUDE`         | Exclude test filters; see [Test Filters](#test-filters) section below for more details
`--ct-xml`             | `CINYTEST_XML`             | Write a JUnit XML report to the specified file

### Test Filters

Test filters are used to select a subset of all the tests in a test run. Include filters run matched tests and skip everything else. Exclude filters skip matched tests and run everything else. Include filters are checked before exclude filters, so if both options are specified then tests that match any include filters and do not match any exclude filters will run.

Test filters can target individual test cases or an entire test suite using a simple format. A filter expression consists of a suite-pattern followed by a case-pattern separated by a `':'`. Either the suite-pattern or the case-pattern are optional and specifying one, the other, or both will result in different matching behavior. Both patterns can use `'?'` to match any single character and `'*'` to match any string of characters. Multiple filter expressions of the same type are separated by `','`.

Examples:

- `./mytests` no filters, all tests are run; equivalent to `--ct-include='*'`
- `./mytests --ct-include='foo_tests:frob_returns_true'` run only the `frob_returns_true` test in the `foo_tests` suite
- `./mytests --ct-include='foo_tests:'` run all tests in `foo_tests` suite; this is shorthand for `--ct-include='foo_tests:*'`
- `./mytests --ct-include=':verify_returns_null'` run any test named `verify_returns_null` across all suites; this is shorthand for `--ct-include='*:verify_returns_null'`
- `./mytests --ct-include='*foo'` run any case or suite that ends with `foo`
- `./mytests --ct-include='bar?:'` run any suite starting with `bar` followed by one character, e.g. `barn` or `bark`
- `./mytests --ct-include='*foo*,*bar*'` run all tests with `foo` or `bar` somewhere in the suite or case name
- `./mytests --ct-exclude='bar_tests:'` run all tests except the cases in the `bar_tests` suite
- `./mytests --ct-include='*foo*' --ct-exclude='*bar*'` run all tests with `foo` in the name except those tests that also have `bar` in the name (the order of the options does not matter; include is always checked before exclude)

A note of caution regarding wildcards: filters treat suite and case names as UTF-8 byte strings so multi-byte characters (such as high Basic Multilingual Plane characters or emojis) may be seen as more than one "character". This means the single character wildcard `'?'` will never match a multi-byte character. Instead use the substring wildcard `'*'`, as it will properly match the sequence of bytes that comprise the multi-byte character.

It is possible you may find your filters applying in unexpected ways, particularly when combining multiple filters in a single test run. Test filters can be debugged by turning up the output to its highest verbosity (`--ct-verbose=3`). At this output level all tests are printed, including the skipped tests, and annotated with their matched filter (or `no match`). In addition, all filter expressions are listed along with the rest of CinyTest's options at the start of the output.

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the current landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to write my own and CinyTest is the result.

[cmocka](http://cmocka.org) provided initial inspiration for CinyTest. While the design goals of the two libraries are different, cmocka's API was a guide for the generality and brevity I wanted to achieve with CinyTest.

CinyTest provides a straightforward and terse public API for writing unit tests in C. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest project, CinyTest is bootstrapped into XCTest using a small Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, which could then be built and run using whatever tool fits your needs. This approach is shown in the CinyTest-Example repo and as the `check` build target in the Makefile.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no platform-specific compiler features and targeted the latest C language standard, C17.

That original goal has been left behind at this point as I've expanded the library's scope and target platforms. However the majority of platform-specific code is nicely sequestered behind a common API and compiler targets. As of this writing there are POSIX and Windows compatibility source files.

#### Memory Usage

CinyTest is designed to be a small and simple library. To that point, it uses no dynamic memory in any of its default behaviors. However there are some advanced features that do require memory allocations. If your environment is sensitive to unexpected memory usage then take care when invoking the following options:

- include and exclude test filters
- JUnit test report

#### Windows Support

CinyTest uses C99 and C11 features that are, as of this writing, not supported by Microsoft development tools natively; cl.exe is incapable of compiling CinyTest. Fortunately Microsoft has put some effort into supporting newer C standards and current versions of Visual Studio include clang tooling and runtime libraries that cover the later standards.

It is possible to develop CinyTest in Visual Studio by installing the _C++ Clang tools for Windows_ feature (packaged in Visual Studio 2019+) but **winbuild.bat** is sufficient to build artifacts. Note that **winbuild.bat** only builds a static version of the CinyTest library.

To build CinyTest on Windows install the following tools:

- [Visual Studio Community 2019](https://visualstudio.microsoft.com)
	- Desktop development with C++
- clang
- Doxygen (set the `_WIN64` preprocessor macro in the Predefined section to select the right documentation)

Use the x64 Native Build Tools Command Prompt in order to get the correct environment.

### A Word on Warnings

CinyTest strives for zero warnings under `-Wall -Wextra -pedantic`. This is achieved for the library itself but certain usages of the library contain some minor caveats.

CinyTest uses variadic macros for its test assertions. The call signature has an optional assert message and can be called either as `ct_asserttrue(foo)` or `ct_asserttrue(foo, "Expected true expression")`.

However the `ct_asserttrue(foo)` form will trigger a missing variadic arguments warning for `-pedantic`. This can be suppressed either by always specifying an assert message (as shown above) or by including a trailing comma which satisfies the preprocessor: `ct_asserttrue(foo,)`. In addition any tests that don't use the test context parameter will trigger unused parameter warnings if `-Wextra` is used. This can be suppressed by casting the argument to void: `(void)context;`.

I tend to be more lax for test code than production code so I would likely omit the warnings for unit tests. In my experience all warnings triggered by usage of CinyTest would be caught by `-Wno-unused-parameter -Wno-gnu-zero-variadic-macro-arguments` (gcc does not define the latter flag so use `-Wno-pedantic` on test builds). If that's an unappealing option then use one of the syntax remedies described above.

The Xcode project builds with the same warning level as the Makefile. However XCTest uses some GNU extensions and a couple macros that trigger `-pedantic` issues so the project selectively scales back certain warnings either on the individual targets or as compiler pragmas when necessary. On Windows the UCRT headers mark several stdlib functions as deprecated that are supported fine on Linux and macOS so the batch file includes the `-Wno-deprecated-declarations` option.

### How do I pronounce CinyTest?

I don't know. The name is a visual pun on "C" and "Tiny". Some possibilities:

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???
