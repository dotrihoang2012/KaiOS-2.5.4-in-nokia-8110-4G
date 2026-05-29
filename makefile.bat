@echo off
setlocal enabledelayedexpansion

rem ── CONFIG ──────────────────────────────────────────────────────────────────
set PERSISTDIR=/data/media/0
set USERDATA=/dev/block/bootdevice/by-name/userdata

rem ── TOOLS ───────────────────────────────────────────────────────────────────
set AIK_WIN=Tools\Android Image Kitchen\Windows
set MAKE_EXT4FS=Tools\make_ext4fs\bin\make_ext4fs.exe
set SIGNER_DIR=Tools\OTA Signer
set JAVA=Tools\Java-15\bin\java.exe
set CLASSPATH=%SIGNER_DIR%\SignApk.jar;%SIGNER_DIR%\conscrypt-openjdk-uber.jar;%SIGNER_DIR%\bcprov-jdk15on-1.64.jar;%SIGNER_DIR%\bcpkix-jdk15on-1.64.jar
set CERT=Tools\Keys\testkey.x509.pem
set KEY=Tools\Keys\testkey.pk8
set ADB=Tools\adb\Windows\adb.exe
set FFMPEG=Tools\ffmpeg.exe
set SIGN_JAR=Tools\Sign\signapk.jar
set UPDATE_BINARY=Tools\Sign\update-binary

rem ── RESOURCES ───────────────────────────────────────────────────────────────
set BOOT_DIR=Resources\Boot
set RECOVERY_DIR=Resources\Recovery
set SYSTEM_DIR=Resources\System
set SPLASH_DIR=Resources\Splash
set OTA_DIR=Resources\Zip OTA
set BASE_SYSTEM_SIZE=838860800
set BACKUP_DIR=works\backups

if "%INPUT%"=="" set INPUT=input.zip
for %%F in ("%INPUT%") do set OUTPUT=%%~nF-signed.zip

if "%VERSION%"=="" (
    for /f "delims=" %%V in ('git rev-parse --short HEAD 2^>nul') do set VERSION=%%V
    if "!VERSION!"=="" set VERSION=unknown
)

set BUILDID=%RANDOM%

rem ── DISPATCH ────────────────────────────────────────────────────────────────
if "%1"=="" goto help
goto %1 2>nul
echo Unknown target: %1
call :help
exit /b 1

rem ── BUILD ───────────────────────────────────────────────────────────────────
:build
call :build-boot
call :build-recovery
call :build-splash
call :build-system
goto :eof

:build-boot
call :clean-boot
echo Building boot.img...
xcopy /E /I /Y "%BOOT_DIR%\split_img" "%AIK_WIN%\split_img\" >nul
xcopy /E /I /Y "%BOOT_DIR%\ramdisk"   "%AIK_WIN%\ramdisk\"   >nul
pushd "%AIK_WIN%"
call repackimg.bat
popd
if exist "%AIK_WIN%\image-new.img" (
    move /Y "%AIK_WIN%\image-new.img" boot.img
) else if exist "%AIK_WIN%\unsigned-new.img" (
    move /Y "%AIK_WIN%\unsigned-new.img" boot.img
)
rmdir /s /q "%AIK_WIN%\split_img" 2>nul
rmdir /s /q "%AIK_WIN%\ramdisk"   2>nul
del /f /q "%AIK_WIN%\ramdisk-new.cpio" 2>nul
echo -^> boot.img done
goto :eof

:build-recovery
call :clean-recovery
echo Building recovery.img...
xcopy /E /I /Y "%RECOVERY_DIR%\split_img" "%AIK_WIN%\split_img\" >nul
xcopy /E /I /Y "%RECOVERY_DIR%\ramdisk"   "%AIK_WIN%\ramdisk\"   >nul
pushd "%AIK_WIN%"
call repackimg.bat
popd
if exist "%AIK_WIN%\image-new.img" (
    move /Y "%AIK_WIN%\image-new.img" recovery.img
) else if exist "%AIK_WIN%\unsigned-new.img" (
    move /Y "%AIK_WIN%\unsigned-new.img" recovery.img
)
rmdir /s /q "%AIK_WIN%\split_img" 2>nul
rmdir /s /q "%AIK_WIN%\ramdisk"   2>nul
del /f /q "%AIK_WIN%\ramdisk-new.cpio" 2>nul
echo -^> recovery.img done
goto :eof

:build-system
echo Building system.img...
"%MAKE_EXT4FS%" -a "/system" -L "system" -j 0 -l %BASE_SYSTEM_SIZE% system.img "%SYSTEM_DIR%"
echo -^> system.img done
goto :eof

:build-splash
call :clean-splash
echo Building splash.img...
set SPLASH_TMP=%TEMP%\splash-raw-%RANDOM%.bin
"%FFMPEG%" -vcodec png -i "%SPLASH_DIR%\logo.png" -vcodec rawvideo -f rawvideo -pix_fmt bgr565 -s 240x320 -y "%SPLASH_TMP%"
copy /b "%SPLASH_DIR%\logohdr.bin" + "%SPLASH_TMP%" splash.img >nul
del /f /q "%SPLASH_TMP%"
echo -^> splash.img done
goto :eof

rem ── BACKUP ──────────────────────────────────────────────────────────────────
:backup
call :backup-boot
call :backup-recovery
call :backup-splash
call :backup-system
goto :eof

:backup-boot
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" shell dd of=%PERSISTDIR%/boot.backup.img if=/dev/block/bootdevice/by-name/boot bs=2048
"%ADB%" pull %PERSISTDIR%/boot.backup.img "%BACKUP_DIR%\boot.%BUILDID%.img"
"%ADB%" shell rm -f %PERSISTDIR%/boot.backup.img
echo -^> Backed up to %BACKUP_DIR%\boot.%BUILDID%.img
goto :eof

:backup-recovery
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" shell dd of=%PERSISTDIR%/recovery.backup.img if=/dev/block/bootdevice/by-name/recovery bs=2048
"%ADB%" pull %PERSISTDIR%/recovery.backup.img "%BACKUP_DIR%\recovery.%BUILDID%.img"
"%ADB%" shell rm -f %PERSISTDIR%/recovery.backup.img
echo -^> Backed up to %BACKUP_DIR%\recovery.%BUILDID%.img
goto :eof

:backup-system
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" shell dd of=%PERSISTDIR%/system.backup.img if=/dev/block/bootdevice/by-name/system bs=2048
"%ADB%" pull %PERSISTDIR%/system.backup.img "%BACKUP_DIR%\system.%BUILDID%.img"
"%ADB%" shell rm -f %PERSISTDIR%/system.backup.img
echo -^> Backed up to %BACKUP_DIR%\system.%BUILDID%.img
goto :eof

:backup-splash
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" shell dd of=%PERSISTDIR%/splash.backup.img if=/dev/block/bootdevice/by-name/splash bs=2048
"%ADB%" pull %PERSISTDIR%/splash.backup.img "%BACKUP_DIR%\splash.%BUILDID%.img"
"%ADB%" shell rm -f %PERSISTDIR%/splash.backup.img
echo -^> Backed up to %BACKUP_DIR%\splash.%BUILDID%.img
goto :eof

rem ── DEPLOY ──────────────────────────────────────────────────────────────────
:deploy
call :deploy-boot
call :deploy-recovery
call :deploy-splash
call :deploy-system
goto :eof

:deploy-boot
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" push boot.img %PERSISTDIR%/
"%ADB%" shell dd if=%PERSISTDIR%/boot.img of=/dev/block/bootdevice/by-name/boot bs=2048
"%ADB%" shell rm %PERSISTDIR%/boot.img
echo -^> boot.img deployed
goto :eof

:deploy-recovery
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" push recovery.img %PERSISTDIR%/
"%ADB%" shell dd if=%PERSISTDIR%/recovery.img of=/dev/block/bootdevice/by-name/recovery bs=2048
"%ADB%" shell rm %PERSISTDIR%/recovery.img
echo -^> recovery.img deployed
goto :eof

:deploy-system
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" push system.img %PERSISTDIR%/
"%ADB%" shell dd if=%PERSISTDIR%/system.img of=/dev/block/bootdevice/by-name/system bs=2048
"%ADB%" shell rm %PERSISTDIR%/system.img
echo -^> system.img deployed
goto :eof

:deploy-splash
"%ADB%" shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard %USERDATA% /data
"%ADB%" shell mkdir -p %PERSISTDIR%/
"%ADB%" push splash.img %PERSISTDIR%/
"%ADB%" shell dd if=%PERSISTDIR%/splash.img of=/dev/block/bootdevice/by-name/splash bs=2048
"%ADB%" shell rm %PERSISTDIR%/splash.img
echo -^> splash.img deployed
goto :eof

rem ── FLASH ───────────────────────────────────────────────────────────────────
:flash-recovery
"%ADB%" reboot recovery
goto :eof

:sideload
"%ADB%" sideload "%INPUT%"
goto :eof

:wipe
"%ADB%" shell recovery --wipe_data
goto :eof

rem ── SIGN & INSTALLER ────────────────────────────────────────────────────────
:sign
%JAVA% -cp "%CLASSPATH%" SignApk -w "%CERT%" "%KEY%" "%INPUT%" "%OUTPUT%"
goto :eof

:build-installer
call :clean
call :build-system
call :build-boot
call :build-recovery
call :build-splash
if not exist works\installer mkdir works\installer
xcopy /E /I /Y "%OTA_DIR%\*" "works\installer\" >nul
move /Y system.img   works\installer\
move /Y boot.img     works\installer\
move /Y recovery.img works\installer\
move /Y splash.img   works\installer\
if not exist "works\installer\META-INF\com\google\android" mkdir "works\installer\META-INF\com\google\android"
copy /Y "%UPDATE_BINARY%" "works\installer\META-INF\com\google\android\" >nul
set INSTALLER_NAME=Nokia_8110_4G_KaiOS2.5.4_%VERSION%
set TEMP_ZIP=%TEMP%\%INSTALLER_NAME%_unsigned.zip
powershell -NoProfile -Command "Add-Type -Assembly System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('works\installer', '%TEMP_ZIP%', 'Optimal', $false)"
%JAVA% -Xmx2048m -jar "%SIGN_JAR%" -w "%CERT%" "%KEY%" "%TEMP_ZIP%" "%INSTALLER_NAME%.zip"
del /f /q "%TEMP_ZIP%"
rmdir /s /q works\installer
echo -^> %INSTALLER_NAME%.zip done
goto :eof

rem ── CLEAN ───────────────────────────────────────────────────────────────────
:clean
call :clean-boot
call :clean-recovery
call :clean-system
call :clean-splash
call :clean-installer
goto :eof

:clean-boot
del /f /q boot.img 2>nul
rmdir /s /q "%AIK_WIN%\split_img"      2>nul
rmdir /s /q "%AIK_WIN%\ramdisk"        2>nul
del /f /q "%AIK_WIN%\ramdisk-new.cpio" 2>nul
del /f /q "%AIK_WIN%\image-new.img"    2>nul
goto :eof

:clean-recovery
del /f /q recovery.img 2>nul
rmdir /s /q "%AIK_WIN%\split_img"      2>nul
rmdir /s /q "%AIK_WIN%\ramdisk"        2>nul
del /f /q "%AIK_WIN%\ramdisk-new.cpio" 2>nul
del /f /q "%AIK_WIN%\image-new.img"    2>nul
goto :eof

:clean-system
del /f /q system.img 2>nul
rmdir /s /q works\system 2>nul
goto :eof

:clean-splash
del /f /q splash.img 2>nul
goto :eof

:clean-installer
rmdir /s /q works\installer 2>nul
del /f /q Nokia_8110_4G_KaiOS2.5.4_*.zip 2>nul
goto :eof

rem ── HELP ────────────────────────────────────────────────────────────────────
:help
echo.
echo   KaiOS 2.5.4 -- Nokia 8110 4G Build System (Windows)
echo   =====================================================
echo.
echo   BUILD
echo     makefilebuild                Build all images (boot, recovery, system, splash)
echo     makefilebuild-boot           Build boot.img  (via Android Image Kitchen)
echo     makefilebuild-recovery       Build recovery.img
echo     makefilebuild-system         Build system.img
echo     makefilebuild-splash         Build splash.img
echo.
echo   BACKUP  (device must be connected)
echo     makefilebackup               Backup all partitions
echo     makefilebackup-boot          Backup boot
echo     makefilebackup-system        Backup system
echo     makefilebackup-recovery      Backup recovery
echo     makefilebackup-splash        Backup splash
echo.
echo   DEPLOY  (requires Pris Recovery or Philz Touch Recovery)
echo     makefiledeploy               Flash all images
echo     makefiledeploy-boot          Flash boot.img
echo     makefiledeploy-recovery      Flash recovery.img
echo     makefiledeploy-system        Flash system.img
echo     makefiledeploy-splash        Flash splash.img
echo.
echo   FLASH
echo     makefileflash-recovery       Reboot device into recovery
echo     makefilesideload             Sideload INPUT zip via ADB
echo     makefilewipe                 Wipe data partition
echo.
echo   PACKAGE
echo     makefilesign                 Sign INPUT zip with test-keys
echo     makefilebuild-installer      Build OTA installer package
echo     set VERSION=1.0.0 ^& makefile build-installer
echo.
echo   CLEAN
echo     makefileclean                Remove all built images
echo.
goto :eof
