@echo off

rem ---------------------------------------------------------------------------
rem Application launch script
rem
rem This script starts the container with the 'launch' command that gets all
rem application defaults.
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
rem SERVICEAPP
rem   The command to launch the container. By default the built-in distribution
rem   is used.
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

rem Define the application home for the container to launch
rem Use the pushd/cd/popd sequence to get the path without trailing backslash
pushd "%~dp0"
set SERVICEBOX_APP=%cd%
popd

rem Set the command to run the application
if "%SERVICEAPP%" == "" set SERVICEAPP=%SERVICEBOX_APP%\sys\serviceapp.cmd

rem Use the default kit
set SERVICEBOX_KIT_PATH=
set SERVICEBOX_KIT=

rem Launch the application
"%SERVICEAPP%" %*
