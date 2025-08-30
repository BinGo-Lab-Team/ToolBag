@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Rebuild Icon and Thumbnail Cache
echo    ReICON(v1.1) - 重构 Windows 图标与缩略图缓存
echo ================================
echo.

:: 0) 管理员检查与提权
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [i] 当前不是管理员，尝试提权...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  goto :EOF
)

echo [ok] 以管理员身份运行

echo [i] 该操作需要关闭并重启资源管理器，会导致打开的文件夹窗口关闭，请保存好重要数据。
echo [i] 重启过程中可能会白屏一小会儿，请耐心等待。
echo [i] 如果继续，请按下任意键...
pause >nul
echo.

:: 1) 结束资源管理器
echo [i] 正在结束 explorer.exe ...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul

:: 2) 目标路径
set "ROOT=%LocalAppData%"
set "NEW=%LocalAppData%\Microsoft\Windows\Explorer"

echo [i] 目标目录：
echo    %ROOT%
echo    %NEW%

:: 3) 删除旧版缓存 (Win7/8 遗留)
if exist "%ROOT%\IconCache.db" (
  attrib -h -s "%ROOT%\IconCache.db" >nul 2>&1
  del /f /q "%ROOT%\IconCache.db" >nul 2>&1
)

:: 4) 删除 Win10/11 缓存（图标与缩略图）
if exist "%NEW%" (
  pushd "%NEW%" >nul 2>&1

  :: 解除隐藏/系统属性（有些文件带属性）
  attrib -h -s iconcache*.* >nul 2>&1
  attrib -h -s thumbcache*.* >nul 2>&1

  echo [i] 正在清理 iconcache*.db ...
  del /f /q iconcache*.db >nul 2>&1

  echo [i] 正在清理 thumbcache*.db ...
  del /f /q thumbcache*.db >nul 2>&1

  popd >nul 2>&1
) else (
  echo [i] 未发现目录：%NEW% （可能系统版本不同或已被清理）
)

:: 5) 重启资源管理器
echo [i] 正在重启 explorer.exe ...
start explorer.exe

echo.
echo [done] 完成：图标/缩略图缓存已清理并重建（首次打开文件夹时可能稍慢属正常）
pause >nul
endlocal
exit /b 0
