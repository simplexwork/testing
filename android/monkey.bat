@REM The MIT License (MIT)

@REM Copyright (c) 2016 simplexwork

@REM Permission is hereby granted, free of charge, to any person obtaining a copy
@REM of this software and associated documentation files (the "Software"), to deal
@REM in the Software without restriction, including without limitation the rights
@REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@REM copies of the Software, and to permit persons to whom the Software is
@REM furnished to do so, subject to the following conditions:

@REM The above copyright notice and this permission notice shall be included in all
@REM copies or substantial portions of the Software.

@REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@REM SOFTWARE.

@ECHO OFF
CLS

echo.
echo. monkey test @simplexwork
echo.

cd /d %~dp0

setlocal enabledelayedexpansion

@REM Ŀ¼����

set BASE=%CD%
set CONFIG=%BASE%\config
set DIR_LOG=%BASE%\logs
set DIR_TEMP=%BASE%\temp
set PATH=%PATH%;%BASE%\..\bin



@REM ������ʱĿ¼

if not exist %DIR_LOG% md %DIR_LOG%
if not exist %DIR_TEMP% md %DIR_TEMP%

@REM �ж��Ƿ����ANDROID SDK

if not "%ANDROID_HOME%" == "" goto OKAHOME

echo.
echo * �밲װ ANDROID SDK�������ڻ������������� ANDROID_HOME
echo.
goto END

:OKAHOME

set ADB_EXEC="%ANDROID_HOME%\platform-tools\adb.exe"

if exist %ADB_EXEC% goto OKADB  
  
echo.
echo * ����%ADB_EXEC%�Ƿ����  
echo.
goto END

:OKADB

@REM ���ò���

set options=--hprof --monitor-native-crashes

echo.
set /p package=����Ҫ���Եİ���(package):
set options=%options% -p %package%

echo.
set /p yn1=���Գ�ʱ?(Y/N):
if /i "%yn1%" == "Y" set options=%options% --ignore-crashes

echo.
set /p yn2=���Ա���?(Y/N):
if /i "%yn2%" == "Y" set options=%options% --ignore-timeouts

echo.
set /p yn3=���԰�ȫ�쳣?(Y/N):
if /i "%yn3%" == "Y" set options=%options% --ignore-security-exceptions

echo.
set /p t=�¼���ʱʱ��(����):
if not "%t%" == "" set options=%options% --throttle %t%

echo.
set /p p1=�����¼�ռ�ٷֱ�(0-100,ĳ��һλ��down+up):
if not "%p1%" == "" set options=%options% --pct-touch %p1%

echo.
set /p p2=�����¼�ռ�ٷֱ�(0-100,ĳ��down+α����¼�+up���):
if not "%p2%" == "" set options=%options% --pct-motion %p2%

echo.
set /p p3=�켣�¼�ռ�ٷֱ�(0-100,ĳ��down+α����¼�+up���):
if not "%p3%" == "" set options=%options% --pct-trackball %p3%

echo.
set /p p4=ϵͳ����ռ�ٷֱ�(0-100,�����������绰�����ء���ҳ��):
if not "%p4%" == "" set options=%options% --pct-syskeys %p4%

echo.
set /p v=��Ϣ��ӡ����(0-2)[Ĭ��:0]:
if "%v%" == "" set v=0
:VLOOP
set /a v=%v%-1
set options=%options% -v
if %v% GEQ 0 goto VLOOP 

echo.
set /p s=�������[Ĭ��:100]:
if "%s%" == "" set s=100
set options=%options% -s %s%

echo.
set /p c=ģ���¼���[Ĭ��:100]:
if "%c%" == "" set /a c=100
set options=%options% %c%

@REM �����ļ�

set DATE=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%

set LOG_FILE=%DIR_LOG%\%DATE%.log

set CMD=%ADB_EXEC% shell monkey %options%

@REM echo.
@REM set /p yn4=��ʼ����?(Y/N):
@REM if "%yn4%" == "N" goto CONFIG

echo.
echo ��ʼ���� %time:~0,8%

echo.
echo ������...

%CMD% > %LOG_FILE%

echo.
echo ���Խ��� %time:~0,8%

@REM �������
echo.
echo ������ʼ...
echo.
echo �����쳣
findstr /i "exception" %LOG_FILE% | wc -l

echo.
echo ��������Ӧ
findstr /i "anr" %LOG_FILE% | wc -l

echo.
echo ���ұ���
findstr /i "crash" %LOG_FILE% | wc -l

echo.
echo ��������

echo.
echo ��������: %CMD%

echo.
echo ���Խű�:%TMP_CMD%

echo.
echo ������־:%LOG_FILE%

set TMP_CMD=%DIR_TEMP%\%package%-%DATE%.cmd
echo %CMD% >> %TMP_CMD%

echo.
set /p yn5=����־�ļ�?(Y/N):
if /i "%yn5%" == "Y" start /max %LOG_FILE%

:END
echo.

@REM pause>nul
