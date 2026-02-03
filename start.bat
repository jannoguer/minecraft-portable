@echo off
title mc 1.8.9
cd /d "%~dp0"

set "MC_DIR=%cd%\mcdata"
set "JAVA_HOME=%cd%\jre\jdk8u472-b08-jre_windows_x64"
set "NATIVES_DIR=%MC_DIR%\natives\windows-x64"
set "RAM_AMOUNT=2G"

set /p PLAYER_NAME="username: "

echo building Classpath... this may take a moment.
setlocal enabledelayedexpansion

set "CLASSPATH=%MC_DIR%\versions\1.8.9-forge\1.8.9-forge.jar;%MC_DIR%\versions\1.8.9\1.8.9.jar"

for /R "%MC_DIR%\libraries" %%i in (*.jar) do (
    set "CLASSPATH=!CLASSPATH!;%%i"
)

set "ARGS=--username %PLAYER_NAME% --version 1.8.9-forge --gameDir "%MC_DIR%" --assetsDir "%MC_DIR%\assets" --assetIndex 1.8 --uuid 00000000-0000-0000-0000-000000000000 --accessToken 0 --userProperties {} --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker"

echo.
echo launching minecraft...
echo.

"%JAVA_HOME%\bin\java.exe" -Xmx%RAM_AMOUNT% -XX:+UseConcMarkSweepGC ^
  -Djava.library.path="%NATIVES_DIR%" ^
  -Dorg.lwjgl.librarypath="%NATIVES_DIR%" ^
  -Dnet.java.games.input.librarypath="%NATIVES_DIR%" ^
  -cp "!CLASSPATH!" net.minecraft.launchwrapper.Launch %ARGS%

set "EXITCODE=!ERRORLEVEL!"
if NOT "!EXITCODE!"=="0" (
    echo.
    echo [CRASH] minecraft closed with error code !EXITCODE!.
    pause
)