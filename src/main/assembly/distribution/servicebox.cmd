@echo off

rem ---------------------------------------------------------------------------
rem ServiceBox launch script
rem
rem This script starts the container with the 'launch' command that gets both
rem the default and user-supplied arguments. So the script takes care of both
rem the correct boot class path alongside standard bundle set and options.
rem
rem Environment variables can be used to set or override some parameters. Do
rem not set the variables in this script. For a particular deployment or
rem application the variables should be rather set by a specific wrapper.
rem
rem JAVA
rem   The command to launch JVM. Default assumes 'java' command available from
rem   PATH.
rem
rem JAVA_OPTS
rem   Additional Java runtime options passed to the JAVA command.
rem
rem SERVICEBOX_AUTOPATH
rem   The path to the directory which shall be scanned for .jar files to be
rem   added to the boot class path.
rem
rem SERVICEBOX_BOOTPATH
rem   The class path to be appended to the boot class path.
rem
rem SERVICEBOX_KIT
rem   The name of the ServiceBox kit to pick, depending on SERVICEBOX_KIT_PATH.
rem   If SERVICEBOX_KIT_PATH is empty, built-in kits are considered; if both
rem   variables are empty, 'default' built-in kit is chosen.
rem
rem SERVICEBOX_KIT_PATH
rem   The path to the ServiceBox kit location. If empty, a built-in kit shall
rem   be used according to SERVICEBOX_KIT. Otherwise the combination of both
rem   variables result in the location of the target kit.
rem
rem YOFL_LOGGING_FILE
rem   The desired output stream for the launcher logger. The value may be
rem   'stderr' or 'stdout', which applies as the default, or a file name.
rem
rem YOFL_LOGGING_LEVEL
rem   The logging level for the container launcher.
rem
rem ---------------------------------------------------------------------------

setlocal

rem Guess SERVICEBOX_HOME if not defined
if not "%SERVICEBOX_HOME%" == "" goto gotHome
rem Use the pushd/cd/popd sequence to get the path without trailing backslash
pushd "%~dp0"
set SERVICEBOX_HOME=%cd%
popd
:gotHome

set SERVICEPAD=%SERVICEBOX_HOME%\servicepad.cmd

if exist "%SERVICEPAD%" goto okHome
echo The SERVICEBOX_HOME environment variable is not defined correctly.
echo This environment variable is needed to run this program.
exit /B 1
:okHome

rem Set the kit to use
if "%SERVICEBOX_KIT_PATH%" == "" goto builtinKit
if not "%SERVICEBOX_KIT%" == "" set SERVICEBOX_KIT_PATH=%SERVICEBOX_KIT_PATH%\%SERVICEBOX_KIT%
goto checkKit
:builtinKit
if "%SERVICEBOX_KIT%" == "" set SERVICEBOX_KIT=default
set SERVICEBOX_KIT_PATH=%SERVICEBOX_HOME%\kits\%SERVICEBOX_KIT%
:checkKit
if exist "%SERVICEBOX_KIT_PATH%\etc" goto kitPresent
echo The kit determined from SERVICEBOX_KIT_PATH and SERVICEBOX_KIT environment
echo variables is missing or incomplete:
echo "%SERVICEBOX_KIT_PATH%"
exit /B 1
:kitPresent
rem Clear it because SERVICEBOX_KIT_PATH now points to the kit directly, which
rem preserves the documented semantics. This is actually important for running
rem SERVICEPAD as it would check the variables again.
set SERVICEBOX_KIT=

rem Launch the container

"%SERVICEPAD%" launch                                                       ^
  --framework-properties "%SERVICEBOX_KIT_PATH%\etc\framework.properties"   ^
  --launching-properties "%SERVICEBOX_KIT_PATH%\etc\launching.properties"   ^
  --system-properties "%SERVICEBOX_KIT_PATH%\etc\system.properties"         ^
  --bundle-store "%SERVICEBOX_KIT_PATH%\core"                               ^
  %*
