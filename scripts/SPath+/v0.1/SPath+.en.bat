@echo off
setlocal EnableExtensions EnableDelayedExpansion
title System PATH Adder
echo    SPath+ - Add Directory to System Path
echo ================================
echo.

:: ---------------------------
:: 1) Check for Administrator
:: ---------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] Currently not with administrator privileges. Try to apply for administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    timeout /t 1 >nul
    echo [!] If UAC did not pop up or you clicked "No", the script will exit.
    exit /b 1
)

echo [ok] Running with administrator privileges.

:: ---------------------------
:: 2) Prompt user for path and normalize
:: ---------------------------
set "USERPATH="
set /p "USERPATH=Please enter the full directory path to add to the [System Path] (e.g., C:\Tools\bin): "

if "!USERPATH!"=="" (
    echo [err] No input provided, exiting.
    pause >nul
    exit /b 1
)

for %%I in ("%USERPATH%") do set "USERPATH=%%~fI"

if not "!USERPATH!"=="\" (
    if "!USERPATH:~-1!"=="\" set "USERPATH=!USERPATH:~0,-1!"
)

:: ---------------------------
:: 3) Check if directory exists
:: ---------------------------
if not exist "!USERPATH!\" (
    echo [err] The directory does not exist.  "!USERPATH!"
    pause >nul
    exit /b 1
)

:: ---------------------------
:: 4) Read current system Path and check for duplicates
:: ---------------------------
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine')"`) do (
    set "CURPATH=%%P"
)

set "CHECK=;!CURPATH!;"
set "NEEDLE=;!USERPATH!;"
if /I not "!CHECK!"=="!CHECK:%NEEDLE%=!" (
    echo [i] The system PATH already includes: "!USERPATH!"
    goto :BroadcastAndDone
)

:: ---------------------------
:: 5) Write to system Path (append) and remove extra semicolons
:: ---------------------------
echo [i] "!USERPATH!" is being appended to the system PATH...

powershell -NoProfile -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','Machine');" ^
  "$add='%USERPATH%';" ^
  "if(-not $p){$p=''};" ^
  "$np=($p.TrimEnd(';')+';'+$add).Trim(';');" ^
  "[Environment]::SetEnvironmentVariable('Path',$np,'Machine')"

if %errorlevel% neq 0 (
    echo [err] Failed to write to system Path.
    pause >nul
    exit /b 1
)

echo [ok] Successfully added to system Path.

:BroadcastAndDone
:: ---------------------------
:: 6) Broadcast environment change
:: ---------------------------
powershell -NoProfile -Command ^
  "Add-Type -Namespace Win32 -Name Native -MemberDefinition '[DllImport(\"user32.dll\",SetLastError=true,CharSet=CharSet.Auto)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd,int Msg,IntPtr wParam,string lParam,int fuFlags,int uTimeout,out IntPtr lpdwResult);';" ^
  "$r=[IntPtr]::Zero;[Win32.Native]::SendMessageTimeout([IntPtr]0xffff,0x1A,[IntPtr]0,'Environment',2,5000,[ref]$r) | Out-Null"

echo .
echo [done] Operation completed. Some programs may require a restart to recognize the updated PATH.
endlocal
pause >nul
exit /b 0
