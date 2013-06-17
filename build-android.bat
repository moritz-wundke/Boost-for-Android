@Echo Off

REM          Copyright Antony Polukhin 2013.
REM Distributed under the Boost Software License, Version 1.0.
REM    (See accompanying file LICENSE_1_0.txt or copy at
REM          http://www.boost.org/LICENSE_1_0.txt)

sh -c "echo MSYS is installed. Running ./build-android.sh"
If %ERRORLEVEL% EQU 0 GOTO MSYSOK 
echo You need MSYS installed to run this script
GOTO:EOF
:MSYSOK

sh -c "export SHELLOPTS;set -o igncr;./build-android.sh %*"
