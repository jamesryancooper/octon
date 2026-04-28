@echo off
setlocal enabledelayedexpansion

REM Resolve .octon directory from this script location.
set RUNTIME_DIR=%~dp0
REM Remove trailing backslash.
if "%RUNTIME_DIR:~-1%"=="\" set RUNTIME_DIR=%RUNTIME_DIR:~0,-1%

for %%I in ("%RUNTIME_DIR%\..") do set ENGINE_DIR=%%~fI
for %%I in ("%ENGINE_DIR%\..") do set FRAMEWORK_DIR=%%~fI
for %%I in ("%FRAMEWORK_DIR%\..") do set OCTON_DIR=%%~fI
set RUNTIME_OPS_DIR=%ENGINE_DIR%\_ops
set ENGINE_BUILD_DIR=%OCTON_DIR%\generated\.tmp\engine\build\runtime-crates-target
set TARGETS_FILE=%RUNTIME_DIR%\release-targets.yml
set STRICT_PACKAGING=%OCTON_RUNTIME_STRICT_PACKAGING%
if not defined STRICT_PACKAGING set STRICT_PACKAGING=0

REM Detect architecture robustly (handles WOW64).
set ARCH=%PROCESSOR_ARCHITECTURE%
if defined PROCESSOR_ARCHITEW6432 set ARCH=%PROCESSOR_ARCHITEW6432%

set TARGET_OS=windows
set TARGET_ARCH=x86_64
if /I "%ARCH%"=="ARM64" set TARGET_ARCH=arm64

set TARGET_BINARY=
set LOCAL_LAUNCHABLE=
set SHIPPABLE_RELEASE=
set TARGET_DECLARED=0
set BIN=
set FORCE_SOURCE_ONLY=0

call :load_target_fields "%TARGETS_FILE%" "%TARGET_OS%" "%TARGET_ARCH%"
if defined TARGET_BINARY set TARGET_DECLARED=1
if defined LOCAL_LAUNCHABLE set TARGET_DECLARED=1
if defined SHIPPABLE_RELEASE set TARGET_DECLARED=1

if "%~1"=="" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="-h" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="--help" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="help" set FORCE_SOURCE_ONLY=1
if "%STRICT_PACKAGING%"=="1" goto after_source_command_routing
if /I "%~1"=="studio" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="workflow" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="start" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="profile" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="plan" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="arm" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="continue" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="mission" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="decide" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="connector" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="support" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="capability" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="steward" set FORCE_SOURCE_ONLY=1
if /I "%~1"=="run" set FORCE_SOURCE_ONLY=1
:after_source_command_routing

if "%FORCE_SOURCE_ONLY%"=="0" if /I "%LOCAL_LAUNCHABLE%"=="true" if defined TARGET_BINARY set BIN=%RUNTIME_OPS_DIR%\bin\%TARGET_BINARY%

if defined BIN if exist "%BIN%" (
  if "%STRICT_PACKAGING%"=="1" goto exec_bin
  if not "%OCTON_RUNTIME_PREFER_SOURCE%"=="1" goto exec_bin
)

if "%FORCE_SOURCE_ONLY%"=="0" if "%TARGET_DECLARED%"=="1" if /I not "%LOCAL_LAUNCHABLE%"=="true" (
  echo No local launchable runtime target is declared for %TARGET_OS%/%TARGET_ARCH% in "%TARGETS_FILE%".
  exit /b 1
)

if "%FORCE_SOURCE_ONLY%"=="0" if "%STRICT_PACKAGING%"=="1" (
  if "%TARGET_DECLARED%"=="0" (
    echo Strict packaging disallows source fallback for undeclared target %TARGET_OS%/%TARGET_ARCH%.
  ) else (
    echo Strict packaging requires packaged runtime binary at "%BIN%".
  )
  exit /b 1
)

:fallback
REM Development fallback: run from source.
REM Requires Rust + cargo on PATH.
if not exist "%ENGINE_BUILD_DIR%" mkdir "%ENGINE_BUILD_DIR%"
set CARGO_TARGET_DIR=%ENGINE_BUILD_DIR%
cargo run -q --manifest-path "%RUNTIME_DIR%\crates\Cargo.toml" -p octon_kernel -- %*
exit /b %ERRORLEVEL%

:exec_bin
"%BIN%" %*
exit /b %ERRORLEVEL%

:load_target_fields
setlocal enabledelayedexpansion
set "file=%~1"
set "match_os=%~2"
set "match_arch=%~3"
set "current_os="
set "current_arch="
set "current_binary="
set "current_local="
set "current_ship="
set "found_binary="
set "found_local="
set "found_ship="

for /f "usebackq tokens=* delims=" %%L in ("%file%") do (
  set "line=%%L"
  if "!line:~0,7!"=="  - id:" (
    if /I "!current_os!"=="!match_os!" if /I "!current_arch!"=="!match_arch!" (
      set "found_binary=!current_binary!"
      set "found_local=!current_local!"
      set "found_ship=!current_ship!"
    )
    set "current_os="
    set "current_arch="
    set "current_binary="
    set "current_local="
    set "current_ship="
  ) else if "!line:~0,7!"=="    os:" (
    set "current_os=!line:~7!"
    for /f "tokens=* delims= " %%A in ("!current_os!") do set "current_os=%%A"
    set "current_os=!current_os:"=!"
  ) else if "!line:~0,9!"=="    arch:" (
    set "current_arch=!line:~9!"
    for /f "tokens=* delims= " %%A in ("!current_arch!") do set "current_arch=%%A"
    set "current_arch=!current_arch:"=!"
  ) else if "!line:~0,16!"=="    binary_name:" (
    set "current_binary=!line:~16!"
    for /f "tokens=* delims= " %%A in ("!current_binary!") do set "current_binary=%%A"
    set "current_binary=!current_binary:"=!"
  ) else if "!line:~0,21!"=="    local_launchable:" (
    set "current_local=!line:~21!"
    for /f "tokens=* delims= " %%A in ("!current_local!") do set "current_local=%%A"
    set "current_local=!current_local:"=!"
  ) else if "!line:~0,23!"=="    shippable_release:" (
    set "current_ship=!line:~23!"
    for /f "tokens=* delims= " %%A in ("!current_ship!") do set "current_ship=%%A"
    set "current_ship=!current_ship:"=!"
  )
)

if /I "!current_os!"=="!match_os!" if /I "!current_arch!"=="!match_arch!" (
  set "found_binary=!current_binary!"
  set "found_local=!current_local!"
  set "found_ship=!current_ship!"
)

endlocal & (
  set "TARGET_BINARY=%found_binary%"
  set "LOCAL_LAUNCHABLE=%found_local%"
  set "SHIPPABLE_RELEASE=%found_ship%"
)
exit /b 0
