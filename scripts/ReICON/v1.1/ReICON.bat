@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Rebuild Icon and Thumbnail Cache
echo    ReICON(v1.1) - �ع� Windows ͼ��������ͼ����
echo ================================
echo.

:: 0) ����Ա�������Ȩ
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [i] ��ǰ���ǹ���Ա��������Ȩ...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  goto :EOF
)

echo [ok] �Թ���Ա�������

echo [i] �ò�����Ҫ�رղ�������Դ���������ᵼ�´򿪵��ļ��д��ڹرգ��뱣�����Ҫ���ݡ�
echo [i] ���������п��ܻ����һС����������ĵȴ���
echo [i] ����������밴�������...
pause >nul
echo.

:: 1) ������Դ������
echo [i] ���ڽ��� explorer.exe ...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul

:: 2) Ŀ��·��
set "ROOT=%LocalAppData%"
set "NEW=%LocalAppData%\Microsoft\Windows\Explorer"

echo [i] Ŀ��Ŀ¼��
echo    %ROOT%
echo    %NEW%

:: 3) ɾ���ɰ滺�� (Win7/8 ����)
if exist "%ROOT%\IconCache.db" (
  attrib -h -s "%ROOT%\IconCache.db" >nul 2>&1
  del /f /q "%ROOT%\IconCache.db" >nul 2>&1
)

:: 4) ɾ�� Win10/11 ���棨ͼ��������ͼ��
if exist "%NEW%" (
  pushd "%NEW%" >nul 2>&1

  :: �������/ϵͳ���ԣ���Щ�ļ������ԣ�
  attrib -h -s iconcache*.* >nul 2>&1
  attrib -h -s thumbcache*.* >nul 2>&1

  echo [i] �������� iconcache*.db ...
  del /f /q iconcache*.db >nul 2>&1

  echo [i] �������� thumbcache*.db ...
  del /f /q thumbcache*.db >nul 2>&1

  popd >nul 2>&1
) else (
  echo [i] δ����Ŀ¼��%NEW% ������ϵͳ�汾��ͬ���ѱ�����
)

:: 5) ������Դ������
echo [i] �������� explorer.exe ...
start explorer.exe

echo.
echo [done] ��ɣ�ͼ��/����ͼ�����������ؽ����״δ��ļ���ʱ����������������
pause >nul
endlocal
exit /b 0
