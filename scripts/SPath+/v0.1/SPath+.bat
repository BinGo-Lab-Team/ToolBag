@echo off
setlocal EnableExtensions EnableDelayedExpansion
title System PATH Adder
echo    SPath+ - ���Ŀ¼��ϵͳ Path
echo ================================
echo.

:: ---------------------------
:: 1) ����Ƿ����Ա
:: ---------------------------
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

:: ---------------------------
:: 2) ѯ���û�·�����淶��
:: ---------------------------
set "USERPATH="
set /p "USERPATH=������Ҫ��ӵ���ϵͳ Path��������Ŀ¼·��(���� C:\Tools\bin): "

if "!USERPATH!"=="" (
    echo [err] δ�����κ����ݣ��˳���
    pause >nul
    exit /b 1
)

:: ȥ�����Ų��淶�ɾ���·��
for %%I in ("%USERPATH%") do set "USERPATH=%%~fI"

:: ȥ��ĩβ�ķ�б�ܣ���Ŀ¼���⣩
if not "!USERPATH!"=="\" (
    if "!USERPATH:~-1!"=="\" set "USERPATH=!USERPATH:~0,-1!"
)

:: ---------------------------
:: 3) ���Ŀ¼�Ƿ����
:: ---------------------------
if not exist "!USERPATH!\" (
    echo [err] Ŀ¼�����ڣ� "!USERPATH!"
    pause >nul
    exit /b 1
)

:: ---------------------------
:: 4) ��ȡ��ǰϵͳ Path��������Ƿ��Ѵ��ڣ�ȥ�أ�
::    ʹ�� PowerShell ��ȡ/д�룬���� setx �ĳ��Ƚض�����
:: ---------------------------
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine')"`) do (
    set "CURPATH=%%P"
)

:: ƴ�ӷֺţ���������飨��Сд�����У�
set "CHECK=;!CURPATH!;"
set "NEEDLE=;!USERPATH!;"
if /I not "!CHECK!"=="!CHECK:%NEEDLE%=!" (
    echo [i] ϵͳ Path �Ѱ����� "!USERPATH!"
    goto :BroadcastAndDone
)

:: ---------------------------
:: 5) д��ϵͳ Path��׷�ӣ�����ȥ������ֺ�
:: ---------------------------
echo [i] ���ڰ� "!USERPATH!" ׷�ӵ�ϵͳ Path...

powershell -NoProfile -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','Machine');" ^
  "$add='%USERPATH%';" ^
  "if(-not $p){$p=''};" ^
  "$np=($p.TrimEnd(';')+';'+$add).Trim(';');" ^
  "[Environment]::SetEnvironmentVariable('Path',$np,'Machine')"

if %errorlevel% neq 0 (
    echo [err] д��ϵͳ Path ʧ�ܡ�
    pause >nul
    exit /b 1
)

echo [ok] ��д��ϵͳ Path��

:BroadcastAndDone
:: ---------------------------
:: 6) �㲥�������������֪ͨ�Ѵ򿪵ĳ��򣻲��ֳ�������������
:: ---------------------------
powershell -NoProfile -Command ^
  "Add-Type -Namespace Win32 -Name Native -MemberDefinition '[DllImport(\"user32.dll\",SetLastError=true,CharSet=CharSet.Auto)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd,int Msg,IntPtr wParam,string lParam,int fuFlags,int uTimeout,out IntPtr lpdwResult);';" ^
  "$r=[IntPtr]::Zero;[Win32.Native]::SendMessageTimeout([IntPtr]0xffff,0x1A,[IntPtr]0,'Environment',2,5000,[ref]$r) | Out-Null"

echo .
echo [done] ��ɡ��¿����ն˻�̳����µ� Path��
endlocal
pause >nul
exit /b 0
