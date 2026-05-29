@echo off
setlocal

rem Usage: sign.bat <input_directory> <output.zip>

if "%~1"=="" ( echo Usage: sign.bat ^<input_dir^> ^<output.zip^> & exit /b 1 )
if "%~2"=="" ( echo Usage: sign.bat ^<input_dir^> ^<output.zip^> & exit /b 1 )

set SCRIPTDIR=%~dp0
set SCRIPTDIR=%SCRIPTDIR:~0,-1%
set KEYDIR=%SCRIPTDIR%\..\Keys
set JAVA=%SCRIPTDIR%\..\..\Tools\Java-15\bin\java.exe
if not exist "%JAVA%" set JAVA=java
set TEMPDIR=%SCRIPTDIR%\tmp

if exist "%TEMPDIR%" rmdir /s /q "%TEMPDIR%"
mkdir "%TEMPDIR%"
xcopy /E /I /Y "%~1\*" "%TEMPDIR%\" >nul
if not exist "%TEMPDIR%\META-INF\com\google\android" mkdir "%TEMPDIR%\META-INF\com\google\android"
copy /Y "%SCRIPTDIR%\update-binary" "%TEMPDIR%\META-INF\com\google\android\" >nul

set TEMP_ZIP=%TEMPDIR%\update.zip
powershell -NoProfile -Command "Add-Type -Assembly System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('%TEMPDIR%', '%TEMP_ZIP%', 'Optimal', $false)"

"%JAVA%" -Xmx2048m -cp "%SCRIPTDIR%\signapk.jar;%SCRIPTDIR%\conscrypt-openjdk-uber.jar;%SCRIPTDIR%\bcprov-jdk15on-1.64.jar;%SCRIPTDIR%\bcpkix-jdk15on-1.64.jar" SignApk -w "%KEYDIR%\testkey.x509.pem" "%KEYDIR%\testkey.pk8" "%TEMP_ZIP%" "%~2"

rmdir /s /q "%TEMPDIR%"
echo Signed archive created at %~2
