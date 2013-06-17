@Echo Off

REM          Copyright Antony Polukhin 2013.
REM Distributed under the Boost Software License, Version 1.0.
REM    (See accompanying file LICENSE_1_0.txt or copy at
REM          http://www.boost.org/LICENSE_1_0.txt)

sh -c "echo MSYS found. Running ./build-android.sh"
If %ERRORLEVEL% EQU 0 GOTO MSYSOK 
echo This script requires MSYS installed and path to its bin folder added to PATH variable
echo Read http://www.mingw.org/wiki/MSYS for more information
GOTO:EOF
:MSYSOK

sh -c "./build-android.sh %*"
