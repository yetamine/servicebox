@echo off

rem ---------------------------------------------------------------------------
rem ServiceBox launch script
rem
rem This script launches the container with the provided parameters. It merely
rem takes care of supplying the correct boot class path, so that the container
rem could launch.
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

set YOFL=%SERVICEBOX_HOME%\bin\yofl.cmd

if exist "%YOFL%" goto okHome
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
rem Clear it because SERVICEBOX_KIT_PATH now points to the kit directly, although
rem it is not strictly necessary. However, it preserves the documented semantics.
set SERVICEBOX_KIT=

rem Specify the boot class path sources
set YOFL_AUTOPATH=%SERVICEBOX_AUTOPATH%
set YOFL_BOOTPATH=%SERVICEBOX_KIT_PATH%\boot\classes

rem Compose the local automatic boot path
pushd "%SERVICEBOX_KIT_PATH%\boot"
for %%G in (*.jar) do call:appendToBootpath %%G "%SERVICEBOX_KIT_PATH%\boot"
popd
rem Finish the boot path composition with the externally supplied part
if not "%SERVICEBOX_BOOTPATH%" == "" set YOFL_BOOTPATH=%YOFL_BOOTPATH%;%SERVICEBOX_BOOTPATH%
goto bootpathDone

:appendToBootpath
set filename=%~1
set suffix=%filename:~-4%
if %suffix% equ .jar set YOFL_BOOTPATH=%YOFL_BOOTPATH%;%~2\%filename%
goto :EOF
:bootpathDone

rem Supply JPMS options file
if exist "%SERVICEBOX_KIT_PATH%\boot\jpms.options" set JDK_JAVA_OPTIONS="@%SERVICEBOX_KIT_PATH%\boot\jpms.options" %JDK_JAVA_OPTIONS%

rem Take the control over java.util.logging
set JAVA_OPTS=-Djava.util.logging.config.class=net.yetamine.osgi.launcher.LoggerConfiguration %JAVA_OPTS%

rem Launch the container
"%YOFL%" %*
