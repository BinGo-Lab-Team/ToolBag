@echo off
setlocal EnableExtensions EnableDelayedExpansion
title System PATH Adder
echo    SPath+ - 添加目录到系统 Path
echo ================================
echo.

:: ---------------------------
:: 1) 检查是否管理员
:: ---------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] 当前不是管理员，会尝试申请管理员权限...
    :: 重新以管理员身份运行本脚本；UAC 被拒则不会启动新进程
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    :: 原进程中做一次简单判定；如果 UAC 被拒，新的进程就不会出现
    timeout /t 1 >nul
    echo [!] 如果没有彈出 UAC 或你點了“否”，脚本将退出。
    exit /b 1
)

echo [ok] 以管理员身份运行中。

:: ---------------------------
:: 2) 询问用户路径并规范化
:: ---------------------------
set "USERPATH="
set /p "USERPATH=请输入要添加到【系统 Path】的完整目录路径(例如 C:\Tools\bin): "

if "!USERPATH!"=="" (
    echo [err] 未输入任何内容，退出。
    pause >nul
    exit /b 1
)

:: 去掉引号并规范成绝对路径
for %%I in ("%USERPATH%") do set "USERPATH=%%~fI"

:: 去掉末尾的反斜杠（根目录除外）
if not "!USERPATH!"=="\" (
    if "!USERPATH:~-1!"=="\" set "USERPATH=!USERPATH:~0,-1!"
)

:: ---------------------------
:: 3) 检查目录是否存在
:: ---------------------------
if not exist "!USERPATH!\" (
    echo [err] 目录不存在： "!USERPATH!"
    pause >nul
    exit /b 1
)

:: ---------------------------
:: 4) 读取当前系统 Path，并检查是否已存在（去重）
::    使用 PowerShell 读取/写入，避免 setx 的长度截断问题
:: ---------------------------
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine')"`) do (
    set "CURPATH=%%P"
)

:: 拼接分号，做包含检查（大小写不敏感）
set "CHECK=;!CURPATH!;"
set "NEEDLE=;!USERPATH!;"
if /I not "!CHECK!"=="!CHECK:%NEEDLE%=!" (
    echo [i] 系统 Path 已包含： "!USERPATH!"
    goto :BroadcastAndDone
)

:: ---------------------------
:: 5) 写入系统 Path（追加），并去掉多余分号
:: ---------------------------
echo [i] 正在把 "!USERPATH!" 追加到系统 Path...

powershell -NoProfile -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','Machine');" ^
  "$add='%USERPATH%';" ^
  "if(-not $p){$p=''};" ^
  "$np=($p.TrimEnd(';')+';'+$add).Trim(';');" ^
  "[Environment]::SetEnvironmentVariable('Path',$np,'Machine')"

if %errorlevel% neq 0 (
    echo [err] 写入系统 Path 失败。
    pause >nul
    exit /b 1
)

echo [ok] 已写入系统 Path。

:BroadcastAndDone
:: ---------------------------
:: 6) 广播环境变量变更（通知已打开的程序；部分程序仍需重启）
:: ---------------------------
powershell -NoProfile -Command ^
  "Add-Type -Namespace Win32 -Name Native -MemberDefinition '[DllImport(\"user32.dll\",SetLastError=true,CharSet=CharSet.Auto)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd,int Msg,IntPtr wParam,string lParam,int fuFlags,int uTimeout,out IntPtr lpdwResult);';" ^
  "$r=[IntPtr]::Zero;[Win32.Native]::SendMessageTimeout([IntPtr]0xffff,0x1A,[IntPtr]0,'Environment',2,5000,[ref]$r) | Out-Null"

echo .
echo [done] 完成。新开的终端会继承最新的 Path。
endlocal
pause >nul
exit /b 0
