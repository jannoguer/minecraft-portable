@echo off
title Minecraft Portable 1.8.9 Forge
cd /d "%~dp0"

echo ====================
echo  Minecraft Portable
echo  1.8.9 Forge
echo ====================
echo.

set "MC_DIR=%cd%\mcdata"
set "JAVA_CMD="
set "RAM_AMOUNT="
set "NATIVES_DIR="

:: ── Detect architecture ──────────────────────────────────────────────────
set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if not defined PROCESSOR_ARCHITEW6432 (
        set "ARCH=x86"
    )
)
echo [info] detected platform: windows-%ARCH%

:: ── Detect RAM ───────────────────────────────────────────────────────────
set "RAM_AMOUNT=1G"
for /f "skip=1 tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value 2^>nul') do (
    set "TOTAL_KB=%%A"
)
if defined TOTAL_KB (
    set /a "TOTAL_MB=%TOTAL_KB% / 1024" 2>nul
    if !TOTAL_MB! GEQ 8192 (
        set "RAM_AMOUNT=4G"
    ) else if !TOTAL_MB! GEQ 4096 (
        set "RAM_AMOUNT=2G"
    ) else if !TOTAL_MB! GEQ 2048 (
        set "RAM_AMOUNT=1G"
    ) else (
        set "RAM_AMOUNT=512M"
    )
)

setlocal enabledelayedexpansion

:: Recalculate with delayed expansion for the comparison
set "RAM_AMOUNT=1G"
if defined TOTAL_KB (
    set /a "TOTAL_MB=!TOTAL_KB! / 1024" 2>nul
    if !TOTAL_MB! GEQ 8192 (
        set "RAM_AMOUNT=4G"
    ) else if !TOTAL_MB! GEQ 4096 (
        set "RAM_AMOUNT=2G"
    ) else if !TOTAL_MB! GEQ 2048 (
        set "RAM_AMOUNT=1G"
    ) else (
        set "RAM_AMOUNT=512M"
    )
    echo [info] detected !TOTAL_MB!MB total RAM -^> allocating !RAM_AMOUNT! to Minecraft.
) else (
    echo [info] could not detect RAM. defaulting to !RAM_AMOUNT!.
)

:: ── Find Java ────────────────────────────────────────────────────────────

:: 1) Try bundled JRE for this arch
set "BUNDLED_DIR=%cd%\jre\jdk8u472-b08-jre_windows_%ARCH%"
if exist "!BUNDLED_DIR!\bin\java.exe" (
    set "JAVA_CMD=!BUNDLED_DIR!\bin\java.exe"
    echo [info] using bundled JRE: !BUNDLED_DIR!
    goto :java_found
)

:: 2) On 32-bit, try the 64-bit JRE (won't work, but inform the user)
::    On 64-bit, try whatever bundled JRE exists for windows
for /d %%D in ("%cd%\jre\jdk8u472-b08-jre_windows_*") do (
    if exist "%%D\bin\java.exe" (
        set "JAVA_CMD=%%D\bin\java.exe"
        echo [warn] no exact JRE for windows-!ARCH!. trying: %%D
        goto :java_found
    )
)

:: 3) Fall back to system Java
where java >nul 2>&1
if !ERRORLEVEL! EQU 0 (
    set "JAVA_CMD=java"
    echo [warn] no bundled JRE for windows-!ARCH!. falling back to system Java.
    java -version 2>&1 | findstr /i "version"
    goto :java_found
)

:: 4) Nothing found
echo.
echo [error] no Java runtime found for windows-!ARCH!.
echo.
echo options:
echo   1^) place a JRE in: %cd%\jre\jdk8u472-b08-jre_windows_!ARCH!\
echo   2^) install Java 8 system-wide (https://adoptium.net/^)
echo.
echo see docs\MISSING_BINARIES.md for detailed instructions.
echo.
pause
exit /b 1

:java_found

:: ── Find natives ─────────────────────────────────────────────────────────
set "NATIVES_DIR=!MC_DIR!\natives\windows-!ARCH!"
if not exist "!NATIVES_DIR!" (
    :: Try the x64 natives as fallback
    if exist "!MC_DIR!\natives\windows-x64" (
        set "NATIVES_DIR=!MC_DIR!\natives\windows-x64"
        echo [warn] no natives for windows-!ARCH!. trying windows-x64.
    ) else (
        echo.
        echo [error] no native libraries found for windows-!ARCH!.
        echo expected directory: !MC_DIR!\natives\windows-!ARCH!\
        echo.
        echo see docs\MISSING_BINARIES.md for detailed instructions.
        echo.
        pause
        exit /b 1
    )
)

:: ── Username prompt ──────────────────────────────────────────────────────
echo.
set /p PLAYER_NAME="username: "

if "!PLAYER_NAME!"=="" (
    echo [error] username cannot be empty.
    pause
    exit /b 1
)

:: ── Build classpath ──────────────────────────────────────────────────────
echo.
echo building classpath... this may take a moment.

set "CLASSPATH=!MC_DIR!\versions\1.8.9-forge\1.8.9-forge.jar;!MC_DIR!\versions\1.8.9\1.8.9.jar"

for /R "!MC_DIR!\libraries" %%i in (*.jar) do (
    set "CLASSPATH=!CLASSPATH!;%%i"
)

:: ── Launch ────────────────────────────────────────────────────────────────
echo.
echo launching minecraft...
echo.

"!JAVA_CMD!" -Xmx!RAM_AMOUNT! -XX:+UseConcMarkSweepGC ^
  -Djava.library.path="!NATIVES_DIR!" ^
  -Dorg.lwjgl.librarypath="!NATIVES_DIR!" ^
  -Dnet.java.games.input.librarypath="!NATIVES_DIR!" ^
  -cp "!CLASSPATH!" net.minecraft.launchwrapper.Launch ^
  --username "!PLAYER_NAME!" ^
  --version 1.8.9-forge ^
  --gameDir "!MC_DIR!" ^
  --assetsDir "!MC_DIR!\assets" ^
  --assetIndex 1.8 ^
  --uuid 00000000-0000-0000-0000-000000000000 ^
  --accessToken 0 ^
  --userProperties {} ^
  --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker

set "EXITCODE=!ERRORLEVEL!"
if NOT "!EXITCODE!"=="0" (
    echo.
    echo [CRASH] minecraft closed with error code !EXITCODE!.
    pause
)
