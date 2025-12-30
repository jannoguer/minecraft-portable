#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

MC_DIR="$SCRIPT_DIR/mcdata"
JAVA_HOME="$SCRIPT_DIR/jre/jdk8u472-b08-jre_linux_x64"
NATIVES_DIR="$MC_DIR/natives"
RAM_AMOUNT="2G"

echo -n "username: "
read PLAYER_NAME

# --- Build Classpath ---
echo "building Classpath... this may take a moment."

CLASSPATH="$MC_DIR/versions/1.8.9-forge/1.8.9-forge.jar:$MC_DIR/versions/1.8.9/1.8.9.jar"

LIBS=$(find "$MC_DIR/libraries" -name "*.jar" -type f)
for jar in $LIBS; do
    CLASSPATH="$CLASSPATH:$jar"
done

# --- Launch Arguments ---
# Note: --uuid and --accessToken are set to defaults for offline mode.
# To be truly "legal" and online, you would need to pass a valid Microsoft auth token here.
ARGS="--username $PLAYER_NAME --version 1.8.9-forge --gameDir $MC_DIR --assetsDir $MC_DIR/assets --assetIndex 1.8 --uuid 00000000-0000-0000-0000-000000000000 --accessToken 0 --userProperties {} --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker"

echo ""
echo "launching minecraft..."
echo ""

"$JAVA_HOME/bin/java" -Xmx$RAM_AMOUNT -XX:+UseConcMarkSweepGC -Djava.library.path="$NATIVES_DIR" -cp "$CLASSPATH" net.minecraft.launchwrapper.Launch $ARGS

# Handle crash/exit
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "[CRASH] minecraft closed with error code $EXIT_CODE."
    echo "Press Enter to close..."
    read unused
fi