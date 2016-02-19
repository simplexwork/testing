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

@REM 目录设置

set BASE=%CD%
set CONFIG=%BASE%\config
set DIR_LOG=%BASE%\logs
set DIR_TEMP=%BASE%\temp
set PATH=%PATH%;%BASE%\..\bin



@REM 创建临时目录

if not exist %DIR_LOG% md %DIR_LOG%
if not exist %DIR_TEMP% md %DIR_TEMP%

@REM 判断是否存在ANDROID SDK

if not "%ANDROID_HOME%" == "" goto OKAHOME

echo.
echo * 请安装 ANDROID SDK，并且在环境变量中设置 ANDROID_HOME
echo.
goto END

:OKAHOME

set ADB_EXEC="%ANDROID_HOME%\platform-tools\adb.exe"

if exist %ADB_EXEC% goto OKADB  
  
echo.
echo * 请检查%ADB_EXEC%是否存在  
echo.
goto END

:OKADB

@REM 配置参数

set options=--hprof --monitor-native-crashes

echo.
set /p package=输入要测试的包名(package):
set options=%options% -p %package%

echo.
set /p yn1=忽略超时?(Y/N):
if /i "%yn1%" == "Y" set options=%options% --ignore-crashes

echo.
set /p yn2=忽略崩溃?(Y/N):
if /i "%yn2%" == "Y" set options=%options% --ignore-timeouts

echo.
set /p yn3=忽略安全异常?(Y/N):
if /i "%yn3%" == "Y" set options=%options% --ignore-security-exceptions

echo.
set /p t=事件延时时间(毫秒):
if not "%t%" == "" set options=%options% --throttle %t%

echo.
set /p p1=触摸事件占百分比(0-100,某单一位置down+up):
if not "%p1%" == "" set options=%options% --pct-touch %p1%

echo.
set /p p2=动作事件占百分比(0-100,某处down+伪随机事件+up组成):
if not "%p2%" == "" set options=%options% --pct-motion %p2%

echo.
set /p p3=轨迹事件占百分比(0-100,某处down+伪随机事件+up组成):
if not "%p3%" == "" set options=%options% --pct-trackball %p3%

echo.
set /p p4=系统按键占百分比(0-100,包含音量、电话、返回、首页键):
if not "%p4%" == "" set options=%options% --pct-syskeys %p4%

echo.
set /p v=信息打印级别(0-2)[默认:0]:
if "%v%" == "" set v=0
:VLOOP
set /a v=%v%-1
set options=%options% -v
if %v% GEQ 0 goto VLOOP 

echo.
set /p s=随机种子[默认:100]:
if "%s%" == "" set s=100
set options=%options% -s %s%

echo.
set /p c=模拟事件数[默认:100]:
if "%c%" == "" set /a c=100
set options=%options% %c%

@REM 设置文件

set DATE=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%

set LOG_FILE=%DIR_LOG%\%DATE%.log

set CMD=%ADB_EXEC% shell monkey %options%

@REM echo.
@REM set /p yn4=开始测试?(Y/N):
@REM if "%yn4%" == "N" goto CONFIG

echo.
echo 开始测试 %time:~0,8%

echo.
echo 测试中...

%CMD% > %LOG_FILE%

echo.
echo 测试结束 %time:~0,8%

@REM 分析结果
echo.
echo 分析开始...
echo.
echo 查找异常
findstr /i "exception" %LOG_FILE% | wc -l

echo.
echo 查找无响应
findstr /i "anr" %LOG_FILE% | wc -l

echo.
echo 查找崩溃
findstr /i "crash" %LOG_FILE% | wc -l

echo.
echo 分析结束

echo.
echo 测试命令: %CMD%

echo.
echo 测试脚本:%TMP_CMD%

echo.
echo 测试日志:%LOG_FILE%

set TMP_CMD=%DIR_TEMP%\%package%-%DATE%.cmd
echo %CMD% >> %TMP_CMD%

echo.
set /p yn5=打开日志文件?(Y/N):
if /i "%yn5%" == "Y" start /max %LOG_FILE%

:END
echo.

@REM pause>nul
