@echo off

rem ---------------------------------------------------------------------------
rem ServiceBox application launch script
rem
rem This script invokes ServiceBox configured to use the application's resource
rem to deploy the application's bundles and configuration files.
rem
rem Environment variables can be used to set or override some parameters. Do not
rem not set the variables in this script.
rem
rem JAVA
rem   The command to launch JVM. Default employs 'java' command available from
rem   PATH.
rem
rem JAVA_OPTS
rem   Additional Java runtime options passed to JAVA command.
rem
rem SERVICEBOX_APP
rem   The directory where the application to launch resides. By default the
rem   current working directory is used.
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

rem Set the command
set SERVICEBOX=%SERVICEBOX_HOME%\servicebox.cmd

if exist "%SERVICEBOX%" goto okServiceBoxHome
echo The SERVICEBOX_HOME environment variable is not defined correctly.
echo This environment variable is needed to run this program.
exit /B 1
:okServiceBoxHome

rem Set the application home
if "%SERVICEBOX_APP%" == "" set SERVICEBOX_APP=.

if exist "%SERVICEBOX_APP%\etc" goto okServiceBoxApp
echo The SERVICEBOX_APP environment variable is not defined correctly.
echo This environment variable is needed to run this program.
exit /B 1
:okServiceBoxApp

rem Prepare settings for ServiceBox
set SERVICEBOX_AUTOPATH=%SERVICEBOX_APP%\boot
set SERVICEBOX_BOOTPATH=%SERVICEBOX_APP%\boot\classes

rem Supply JPMS options file
if not exist "%SERVICEBOX_APP%\boot\jpms.options" goto jpmsDone
set JDK_JAVA_OPTIONS="@%SERVICEBOX_APP%\boot\jpms.options" %JDK_JAVA_OPTIONS%
:jpmsDone

rem Launch the container

"%SERVICEBOX%"                                                          ^
  --create-configuration "%SERVICEBOX_APP%\conf"                        ^
  --framework-properties "%SERVICEBOX_APP%\etc\framework.properties"    ^
  --launching-properties "%SERVICEBOX_APP%\etc\launching.properties"    ^
  --system-properties "%SERVICEBOX_APP%\etc\system.properties"          ^
  --bundle-store "%SERVICEBOX_APP%\core"                                ^
  %*
