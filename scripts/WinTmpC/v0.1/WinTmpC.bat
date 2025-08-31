@echo off
title Windows Temp Cleaner
echo    WinTmpC - 临时文件清理工具
echo ================================
echo.

:: 检查管理员权限
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

:: 定义要清理的目录
set TempDirs=%TEMP%;%TMP%;C:\Windows\Temp;C:\Windows\Prefetch

echo [i] 将会清理以下目录：
for %%D in (%TempDirs%) do (
    echo    %%D
)

echo.
echo [i] 在继续前，请确保你已经关闭了所有正在运行的程序，尤其是那些可能正在使用临时文件的程序。
echo [i] 一定要保存重要数据！
echo [i] 如果继续，请按下任意键...
pause >nul
echo.

:: 开始删除
for %%D in (%TempDirs%) do (
    if exist "%%D" (
        echo [*] 正在清理 %%D ...
        del /f /s /q "%%D\*.*" >nul 2>&1
        for /d %%i in ("%%D\*") do rd /s /q "%%i"
    )
)

echo.
echo [ok] 清理完成！
echo.
pause >nul

exit /b 0
