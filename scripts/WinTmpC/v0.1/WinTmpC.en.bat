@echo off
title Windows Temp Cleaner
echo    WinTmpC - Windows Temporary Files Cleaner
echo ================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] Now is not running as administrator. Trying to elevate...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    timeout /t 1 >nul
    echo [!] If the UAV does not pop up or you click "No", the program will exit
    exit /b 1
)

echo [ok] Running as administrator.

set TempDirs=%TEMP%;%TMP%;C:\Windows\Temp;C:\Windows\Prefetch

echo [i] The following temporary directories will be cleaned:
for %%D in (%TempDirs%) do (
    echo    %%D
)

echo.
echo [i] This operation will permanently delete files in the above directories.
echo [i] It is recommended to close other applications before proceeding.
echo [i] Press any key to continue, or press Ctrl+C to cancel.
pause >nul
echo.

:: Strt cleaning
for %%D in (%TempDirs%) do (
    if exist "%%D" (
        echo [*] Cleaning %%D ...
        del /f /s /q "%%D\*.*" >nul 2>&1
        for /d %%i in ("%%D\*") do rd /s /q "%%i"
    )
)

echo.
echo [ok] Temporary files cleanup completed.
echo.
pause >nul

exit /b 0
