@echo off
title Windows Temp Cleaner
echo    WinTmpC - ��ʱ�ļ�������
echo ================================
echo.

:: ������ԱȨ��
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] ��ǰ���ǹ���Ա���᳢���������ԱȨ��...
    :: �����Թ���Ա������б��ű���UAC �����򲻻������½���
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    :: ԭ��������һ�μ��ж������ UAC ���ܣ��µĽ��̾Ͳ������
    timeout /t 1 >nul
    echo [!] ���û�Џ��� UAC �����c�ˡ��񡱣��ű����˳���
    exit /b 1
)

echo [ok] �Թ���Ա��������С�

:: ����Ҫ�����Ŀ¼
set TempDirs=%TEMP%;%TMP%;C:\Windows\Temp;C:\Windows\Prefetch

echo [i] ������������Ŀ¼��
for %%D in (%TempDirs%) do (
    echo    %%D
)

echo.
echo [i] �ڼ���ǰ����ȷ�����Ѿ��ر��������������еĳ�����������Щ��������ʹ����ʱ�ļ��ĳ���
echo [i] һ��Ҫ������Ҫ���ݣ�
echo [i] ����������밴�������...
pause >nul
echo.

:: ��ʼɾ��
for %%D in (%TempDirs%) do (
    if exist "%%D" (
        echo [*] �������� %%D ...
        del /f /s /q "%%D\*.*" >nul 2>&1
        for /d %%i in ("%%D\*") do rd /s /q "%%i"
    )
)

echo.
echo [ok] ������ɣ�
echo.
pause >nul

exit /b 0
