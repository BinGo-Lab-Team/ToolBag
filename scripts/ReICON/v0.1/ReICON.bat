@echo off
setlocal enabledelayedexpansion
title Refresh IconCache
echo    ReICON(v0.1) - �ؽ� Windows ͼ�껺��
echo ================================
echo.

echo [i] �ò�����Ҫ�رղ�������Դ���������ᵼ�´򿪵��ļ��д��ڹرգ��뱣�����Ҫ���ݡ�
echo [i] ���������п��ܻ����һС����������ĵȴ���
echo [i] ����������밴�������...
pause >nul
echo.

taskkill /f /im explorer.exe
CD /d %userprofile%\AppData\Local
DEL IconCache.db /a
start explorer.exe

echo.
echo [ok] ͼ�껺�����ؽ���ɣ�
pause >nul
exit /b 0
