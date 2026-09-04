@echo off
setlocal

cd /d "%~dp0"

set "HRMS_FLUTTER_SDK=C:\Users\JOHN J\Documents\flutter"
if not exist "%HRMS_FLUTTER_SDK%\bin\flutter.bat" (
  echo Flutter SDK was not found at:
  echo %HRMS_FLUTTER_SDK%
  exit /b 1
)

rem Flutter native-asset hooks currently fail when the SDK path contains a
rem space. A temporary drive alias gives the SDK a stable no-space path while
rem keeping the installed SDK and project in their existing locations.
subst T: /d >nul 2>nul
subst T: "%HRMS_FLUTTER_SDK%"
if errorlevel 1 (
  echo Could not create the temporary Flutter SDK drive T:.
  exit /b 1
)

call T:\bin\flutter.bat pub get
if errorlevel 1 goto :failed

call T:\bin\flutter.bat run -d chrome
set "HRMS_EXIT_CODE=%ERRORLEVEL%"
goto :finish

:failed
set "HRMS_EXIT_CODE=%ERRORLEVEL%"

:finish
subst T: /d >nul 2>nul
exit /b %HRMS_EXIT_CODE%
