@ECHO OFF
SETLOCAL

SET build_dir=build
SET src_dir=src
SET samp_src_dir=%src_dir%\sample
SET samp_test_src_dir=test\sample
SET obj_dir=%build_dir%\obj
SET lib_dir=%build_dir%\lib
SET inc_dir=%build_dir%\include

SET cc=clang
SET cflags=-Wall -Wextra -Werror -pedantic -Wno-deprecated-declarations -std=c17 -Os -v

RMDIR /S /Q %build_dir%

ECHO:
ECHO Build CinyTest Library...
MKDIR %obj_dir%
%cc% %cflags% -iquote%src_dir% -c %src_dir%\ciny.c -o %obj_dir%\ciny.obj
IF "%ERRORLEVEL%" NEQ "0" GOTO end

%cc% %cflags% -iquote%src_dir% -c %src_dir%\ciny_win.c -o %obj_dir%\ciny_win.obj
IF "%ERRORLEVEL%" NEQ "0" GOTO end

MKDIR %lib_dir%
LIB %obj_dir%\ciny.obj %obj_dir%\ciny_win.obj /OUT:%lib_dir%\cinytest.lib /VERBOSE /NOLOGO
IF "%ERRORLEVEL%" NEQ "0" GOTO end

MKDIR %inc_dir%
COPY %src_dir%\ciny.h %inc_dir%
IF "%ERRORLEVEL%" NEQ "0" GOTO end

ECHO:
ECHO Build CinyTest Sample...
%cc% %cflags% -iquote%samp_src_dir% %samp_src_dir%\binarytree.c %samp_src_dir%\main.c -o %build_dir%\sample.exe
IF "%ERRORLEVEL%" NEQ "0" GOTO end

ECHO:
ECHO Build CinyTest Sample Tests...
%cc% %cflags% -Wno-gnu-zero-variadic-macro-arguments -Wno-unused-parameter -iquote%build_dir%\include -iquote%samp_src_dir% ^
	-L%lib_dir% -lcinytest %samp_src_dir%\binarytree.c %samp_test_src_dir%\main.c %samp_test_src_dir%\binarytree_tests.c ^
	-o %build_dir%\sampletests.exe
IF "%ERRORLEVEL%" NEQ "0" GOTO end

:end
ENDLOCAL
EXIT /B %ERRORLEVEL%
