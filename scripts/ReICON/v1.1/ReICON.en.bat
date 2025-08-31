@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Rebuild Icon and Thumbnail Cache
echo    ReICON(v1.1) - Rebuild Windows icon & thumbnail cache
echo ================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [i] You are not running as administrator, trying to elevate...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  goto :EOF
)

echo [ok] Running as administrator

echo [i] This operation requires closing and restarting Explorer, which will close any open folder windows. Please save any important data.
echo [i] There may be a brief white screen during the restart process, please be patient.
echo [i] If you want to continue, please press any key...
pause >nul
echo.

echo [i] Stopping explorer.exe ...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul

set "ROOT=%LocalAppData%"
set "NEW=%LocalAppData%\Microsoft\Windows\Explorer"

echo [i] Target directories:
echo    %ROOT%
echo    %NEW%

if exist "%ROOT%\IconCache.db" (
  attrib -h -s "%ROOT%\IconCache.db" >nul 2>&1
  del /f /q "%ROOT%\IconCache.db" >nul 2>&1
)

if exist "%NEW%" (
  pushd "%NEW%" >nul 2>&1

  attrib -h -s iconcache*.* >nul 2>&1
  attrib -h -s thumbcache*.* >nul 2>&1

  echo [i] Cleaning iconcache*.db ...
  del /f /q iconcache*.db >nul 2>&1

  echo [i] Cleaning thumbcache*.db ...
  del /f /q thumbcache*.db >nul 2>&1

  popd >nul 2>&1
) else (
  echo [i] Not Found: %NEW% (possibly different system version or already cleaned up)
)

echo [i] Restarting explorer.exe ...
start explorer.exe

echo.
echo [done] Operation completed.
pause >nul
endlocal
exit /b 0
