@echo off
setlocal enabledelayedexpansion

REM Resolve .harmony directory from this script location.
set RUNTIME_DIR=%~dp0
REM Remove trailing backslash.
if "%RUNTIME_DIR:~-1%"=="\" set RUNTIME_DIR=%RUNTIME_DIR:~0,-1%

for %%I in ("%RUNTIME_DIR%\..") do set HARMONY_DIR=%%~fI
set RUNTIME_OPS_DIR=%RUNTIME_DIR%\_ops
set RUNTIME_STATE_DIR=%RUNTIME_OPS_DIR%\state

REM Detect architecture robustly (handles WOW64).
set ARCH=%PROCESSOR_ARCHITECTURE%
if defined PROCESSOR_ARCHITEW6432 set ARCH=%PROCESSOR_ARCHITEW6432%

set BIN=%RUNTIME_OPS_DIR%\bin\harmony-windows-x64.exe

if /I "%~1"=="studio" set BIN=
if "%~1"=="" set BIN=
if /I "%~1"=="-h" set BIN=
if /I "%~1"=="--help" set BIN=
if /I "%~1"=="help" set BIN=

if exist "%BIN%" (
  "%BIN%" %*
  exit /b %ERRORLEVEL%
)

REM Development fallback: run from source.
REM Requires Rust + cargo on PATH.
if not exist "%RUNTIME_STATE_DIR%\build\runtime-crates-target" mkdir "%RUNTIME_STATE_DIR%\build\runtime-crates-target"
set CARGO_TARGET_DIR=%RUNTIME_STATE_DIR%\build\runtime-crates-target
cargo run -q --manifest-path "%RUNTIME_DIR%\crates\Cargo.toml" -p harmony_kernel -- %*
exit /b %ERRORLEVEL%
