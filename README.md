# CinyTest

CinyTest is a lightweight library for defining and running unit tests in C.

## Features

- unit test and suite creation
- unit suite execution, including setup and teardown support
- detailed test run output to stdout
- test assertions including:
	- value equality, including approximate equality for floating point
	- pointer equality and NULL testing
	- C-string equality
	- general true/false asserts

## Build CinyTest

CinyTest was developed on macOS so an Xcode project is provided under the **mac** folder. There is also a [Makefile](http://www.gnu.org/software/make/) that will build CinyTest for either macOS ([clang](http://clang.llvm.org) by default) or Linux ([gcc](https://gcc.gnu.org) by default). On macOS the Xcode project and Makefile will give you identical libraries so pick whichever build method is more convenient.

For Windows builds there is a batch file: **winbuild.bat**. Microsoft's dev tools do not support several C99 and C11 features so the batch file uses clang instead of [cl.exe](http://msdn.microsoft.com/en-us/library/9s7c9wdw.aspx). See **Constraints and Assumptions** below for more detail on Windows support.

The Makefile has the following build targets:

- `release`: the default target; build CinyTest library and binary tree sample executables with full optimizations
- `debug`: build CinyTest library and binary tree sample executables with debug symbols and no optimizations
- `check`: verify CinyTest by running the sample tests
- `clean`: delete all build artifacts; run this when switching between debug and release builds to make sure all artifacts are rebuilt

All of the Makefile artifacts are placed in a folder named **build**.

The Windows batch file emulates a simplified version of the Makefile, building all targets unconditionally and clearing any previous build artifacts each time.

The Xcode project consists of the following targets:

- **CinyTest**: main target for CinyTest source code and unit tests; builds the CinyTest static library and runs the XCTest unit tests
- **Sample**: additional target illustrating the use of CinyTest to test a binary tree module; includes command-line binary to exercise the binary tree module and an XCTest class for bootstrapping the binary tree unit tests into Xcode

Finally, there are precompiled zip files under the releases tab on GitHub. The zip files include documentation generated from the [Doxygen](http://www.doxygen.org) configuration file.

## Example

A simple example demonstrating the use of CinyTest as an external dependency can be found in the [CinyTest-Example](https://github.com/drmonkeysee/CinyTest-Example) repo.

Running this example on the command line (assuming all tests pass) will output something like the following:

	Test suite 'rectangle_tests' started at 2017-02-02T20:21:19-0800
	[ ✓ ] - 'rectanglemake_createsrectangle' success
	[ ✓ ] - 'rectanglearea_calculatesarea' success
	[ ✓ ] - 'rectanglehypotenuse_calculateshypotenuse' success
	[ ✓ ] - 'rectangletostring_buildsrectanglestring' success
	Ran 4 tests (0.001 seconds): 4 passed, 0 failed, 0 ignored.
	Test suite 'circle_tests' started at 2017-02-02T20:21:19-0800
	[ ✓ ] - 'circlemake_createscircle' success
	[ ✓ ] - 'circlediameter_calculatesdiameter' success
	[ ✓ ] - 'circlearea_calculatesarea' success
	[ ✓ ] - 'circletostring_buildscirclestring' success
	Ran 4 tests (0.000 seconds): 4 passed, 0 failed, 0 ignored.
	[ SUCCESS ] - Ran 8 tests (0.001 seconds): 8 passed, 0 failed, 0 ignored.

This example runs two test suites of four test cases each.

## Options

Any program that CinyTest is compiled into will support a set of command-line options and environment variables that control CinyTest behavior. Command-line options take precedence over environment variables if both are specified. The available options are listed below.

### Command-line Options

- `--ct-help`: print CinyTest usage
- `--ct-version`: print CinyTest version
- `--ct-colorized`: toggle colorized output in test results
- `--ct-suite-breaks`: toggle test suite headers and result summaries

### Environment Variables

- `CINYTEST_COLORIZED`: equivalent to `--ct-colorized`
- `CINYTEST_SUITE_BREAKS`: equivalent to `--ct-suite-breaks`

## Why CinyTest?

The idea for CinyTest arose out of an exploration of the current landscape of C unit testing frameworks. I was looking for a test library that specifically targeted C instead of C++ and did not require standalone executables or linker tricks. I wanted a library that could be used within an IDE for red-green-refactor test-driven development.

Many C test frameworks did not fit the bill; some required make files as part of the execution cycle, others needed per-suite linker flags or multiple `main` function definitions. Some frameworks I found could be run in an IDE but were either heavier than I wanted or had what I felt were awkward or dated APIs. I decided to write my own and CinyTest is the result.

[cmocka](http://cmocka.org) provided initial inspiration for CinyTest. While the design goals of the two libraries are different, cmocka's API was a guide for the generality and brevity I wanted to achieve with CinyTest.

CinyTest provides a straightforward and terse public API for writing unit tests in C. While CinyTest does not integrate *directly* into an IDE test framework (due to lack of tool support) it is trivial to include bare-bones driver code to hook into any test framework of choice while still maintaining all the actual test code in native C.

In the sample code included in the CinyTest project, CinyTest is bootstrapped into XCTest using a small Objective-C test class. A similar approach would work for any other programming environment that can interoperate with C. In addition CinyTest could be run as a native C executable by defining and calling any test suites within a `main` function, which could then be built and run using whatever tool fits your needs. This approach is shown in the CinyTest-Example repo and as the `check` build target in the Makefile.

### Constraints and Assumptions

While I hope CinyTest is useful to others it is also a hobby exercise of mine. Its criteria fit my specific use case and I approached the problem in a very deliberate way. I wanted to see if I could write a library that used no platform-specific compiler features and targeted the latest C language standard, C11.

That original goal has been left behind at this point as I've expanded the library's scope and target platforms. However the majority of platform-specific code is nicely sequestered behind a common API and compiler targets. As of this writing there are POSIX and Windows compatibility source files.

#### Windows Support

CinyTest uses C99 and C11 features that are, as of this writing, not supported by Microsoft development tools natively; cl.exe is incapable of compiling CinyTest. Fortunately Microsoft has put some effort into supporting newer C standards. Specifically the [Universal CRT](https://blogs.msdn.microsoft.com/vcblog/2015/03/03/introducing-the-universal-crt/) provides headers and libraries bridging the gap to C99. Combined with clang, a C11 codebase like CinyTest can be compiled and deployed on Windows.

It is possible to develop CinyTest in Visual Studio by installing the [Clang with Microsoft CodeGen](https://blogs.msdn.microsoft.com/vcblog/2015/12/04/clang-with-microsoft-codegen-in-vs-2015-update-1/) feature (packaged by default in Visual Studio 2015+) but **winbuild.bat** is sufficient to build artifacts.

To build CinyTest on Windows install the following tools:

- [Visual C++ 2015 Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools) (as of this writing LLVM 3.9.1 does not work with Visual Studio 2017 Build Tools)
- clang
- Doxygen (set the _WIN64 preprocessor macro in the Predefined section to select the right documentation)

Use the x64 Native Build Tools Command Prompt in order to get the correct environment.

### A Word on Warnings

CinyTest strives for zero warnings under `-Wall -Wextra -pedantic`. This is achieved for the library itself but certain usages of the library contain some minor caveats.

CinyTest uses variadic macros for its test assertions. The call signature has an optional assert message and can be called either as `ct_assert_true(foo)` or `ct_assert_true(foo, "Expected true expression")`.

However the `ct_assert_true(foo)` form will trigger a missing variadic arguments warning for `-pedantic`. This can be suppressed either by always specifying an assert message (as shown above) or by including a trailing comma which satisfies the preprocessor: `ct_assert_true(foo,)`. In addition any tests that don't use the test context parameter will trigger unused parameter warnings if `-Wextra` is used. This can be suppressed by casting the argument to void: `(void)context;`.

I tend to be more lax for test code than production code so I would likely omit the warnings for unit tests. In my experience all warnings triggered by usage of CinyTest would be caught by `-Wno-unused-parameter -Wno-gnu-zero-variadic-macro-arguments` (gcc does not define the latter flag so use `-Wno-pedantic` on test builds). If that's an unappealing option then use one of the syntax remedies described above.

The Xcode project builds with the same warning level as the Makefile. However XCTest uses some GNU extensions and a couple macros that trigger `-pedantic` issues so the project selectively scales back certain warnings either on the individual targets or as compiler pragmas when necessary. On Windows the UCRT headers mark several stdlib functions as deprecated that are supported fine on Linux and macOS so the batch file includes the `-Wno-deprecated-declarations` option.

### How do I pronounce CinyTest?

I don't know. The name is a visual pun on "C" and "Tiny". Some possibilities:

- TinyTest
- ChinyTest
- SinyTest
- ShinyTest
- ???
