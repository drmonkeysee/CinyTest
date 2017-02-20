@ECHO OFF
SETLOCAL

SET build_dir=build
SET src_dir=src
SET obj_dir=%build_dir%\obj

SET cc=clang
SET cflags=-Wall -Wextra -Wno-deprecated-declarations -pedantic -Werror -std=c11 -Os

RMDIR /S /Q %build_dir%
MKDIR %obj_dir%

%cc% %cflags%  -iquote%src_dir% -c %src_dir%\ciny.c -o %obj_dir%\ciny.o -v
IF "%ERRORLEVEL%" NEQ "0" GOTO end

:end
ENDLOCAL
EXIT /B %ERRORLEVEL%
