@echo off
setlocal enabledelayedexpansion
title Refresh IconCache
echo    ReICON(v0.1) - 重建 Windows 图标缓存
echo ================================
echo.

echo [i] 该操作需要关闭并重启资源管理器，会导致打开的文件夹窗口关闭，请保存好重要数据。
echo [i] 重启过程中可能会白屏一小会儿，请耐心等待。
echo [i] 如果继续，请按下任意键...
pause >nul
echo.

taskkill /f /im explorer.exe
CD /d %userprofile%\AppData\Local
DEL IconCache.db /a
start explorer.exe

echo.
echo [ok] 图标缓存已重建完成！
pause >nul
exit /b 0
