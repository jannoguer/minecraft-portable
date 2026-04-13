#!/usr/bin/env bash
set -euo pipefail

# ── Resolve script directory (works through symlinks) ──────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

MC_DIR="$SCRIPT_DIR/mcdata"
RAM_AMOUNT=""
JAVA_CMD=""

# ── Detect OS ──────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)
      echo ""
      ;;
  esac
}

# ── Detect architecture ───────────────────────────────────────────────────
detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)   echo "x64" ;;
    aarch64|arm64)   echo "aarch64" ;;
    i686|i386)       echo "x86" ;;
    *)
      echo ""
      ;;
  esac
}

# ── Detect available RAM and set allocation ───────────────────────────────
detect_ram() {
  local total_mb=0

  case "$OS_NAME" in
    linux)
      if [ -f /proc/meminfo ]; then
        total_mb=$(awk '/MemTotal/ {printf "%d", $2 / 1024}' /proc/meminfo)
      fi
      ;;
    macos)
      local total_bytes
      total_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
      total_mb=$((total_bytes / 1024 / 1024))
      ;;
  esac

  if [ "$total_mb" -gt 0 ] 2>/dev/null; then
    if [ "$total_mb" -ge 8192 ]; then
      RAM_AMOUNT="4G"
    elif [ "$total_mb" -ge 4096 ]; then
      RAM_AMOUNT="2G"
    elif [ "$total_mb" -ge 2048 ]; then
      RAM_AMOUNT="1G"
    else
      RAM_AMOUNT="512M"
    fi
    echo "[info] detected ${total_mb}MB total RAM -> allocating ${RAM_AMOUNT} to Minecraft."
  else
    RAM_AMOUNT="1G"
    echo "[info] could not detect RAM. defaulting to ${RAM_AMOUNT}."
  fi
}

# ── Find a working Java binary ────────────────────────────────────────────
find_java() {
  # 1) Try bundled JRE matching this OS + arch
  local bundled_dir="$SCRIPT_DIR/jre/jdk8u472-b08-jre_${OS_NAME}_${ARCH_NAME}"
  if [ -d "$bundled_dir" ] && [ -x "$bundled_dir/bin/java" ]; then
    JAVA_CMD="$bundled_dir/bin/java"
    echo "[info] using bundled JRE: $bundled_dir"
    return
  fi

  # 2) On macOS with Apple Silicon, try Rosetta 2 with the x64 JRE
  if [ "$OS_NAME" = "macos" ] && [ "$ARCH_NAME" = "aarch64" ]; then
    local rosetta_dir="$SCRIPT_DIR/jre/jdk8u472-b08-jre_macos_x64"
    if [ -d "$rosetta_dir" ] && [ -x "$rosetta_dir/bin/java" ]; then
      if arch -x86_64 /usr/bin/true 2>/dev/null; then
        JAVA_CMD="$rosetta_dir/bin/java"
        echo "[warn] no native aarch64 JRE found. using macOS x64 JRE via Rosetta 2."
        return
      fi
    fi
  fi

  # 3) Try any bundled JRE for this OS (different arch, may work under emulation)
  for dir in "$SCRIPT_DIR"/jre/jdk8u472-b08-jre_${OS_NAME}_*; do
    if [ -d "$dir" ] && [ -x "$dir/bin/java" ]; then
      JAVA_CMD="$dir/bin/java"
      echo "[warn] no exact JRE for ${OS_NAME}-${ARCH_NAME}. trying: $dir"
      return
    fi
  done

  # 4) Fall back to system Java
  if command -v java &>/dev/null; then
    JAVA_CMD="java"
    echo "[warn] no bundled JRE for ${OS_NAME}-${ARCH_NAME}. falling back to system Java."
    echo "[warn] system Java version:"
    java -version 2>&1 | head -1
    return
  fi

  # 5) Nothing found
  echo ""
  echo "[error] no Java runtime found for ${OS_NAME}-${ARCH_NAME}."
  echo ""
  echo "options:"
  echo "  1) place a JRE in: $SCRIPT_DIR/jre/jdk8u472-b08-jre_${OS_NAME}_${ARCH_NAME}/"
  echo "  2) install Java 8 system-wide (https://adoptium.net/)"
  echo ""
  echo "see MISSING_BINARIES.md for detailed instructions."
  echo ""
  read -rp "Press Enter to close..."
  exit 1
}

# ── Select natives directory ──────────────────────────────────────────────
find_natives() {
  # Exact match first
  if [ -d "$MC_DIR/natives/${OS_NAME}-${ARCH_NAME}" ]; then
    NATIVES_DIR="$MC_DIR/natives/${OS_NAME}-${ARCH_NAME}"
    return
  fi

  # On macOS aarch64, try the x64 natives (LWJGL 2 is x64-only, runs via Rosetta)
  if [ "$OS_NAME" = "macos" ] && [ "$ARCH_NAME" = "aarch64" ]; then
    if [ -d "$MC_DIR/natives/macos-x64" ]; then
      NATIVES_DIR="$MC_DIR/natives/macos-x64"
      echo "[warn] no aarch64 natives found. using macos-x64 natives (Rosetta 2)."
      return
    fi
  fi

  echo ""
  echo "[error] no native libraries found for ${OS_NAME}-${ARCH_NAME}."
  echo "expected directory: $MC_DIR/natives/${OS_NAME}-${ARCH_NAME}/"
  echo ""
  echo "see MISSING_BINARIES.md for detailed instructions."
  echo ""
  read -rp "Press Enter to close..."
  exit 1
}

# ── Build classpath ───────────────────────────────────────────────────────
build_classpath() {
  CLASSPATH="$MC_DIR/versions/1.8.9-forge/1.8.9-forge.jar:$MC_DIR/versions/1.8.9/1.8.9.jar"
  while IFS= read -r -d '' jar; do
    CLASSPATH="$CLASSPATH:$jar"
  done < <(find "$MC_DIR/libraries" -name "*.jar" -type f -print0)
}

# ── Main ──────────────────────────────────────────────────────────────────

OS_NAME="$(detect_os)"
ARCH_NAME="$(detect_arch)"

if [ -z "$OS_NAME" ]; then
  echo "[error] unsupported operating system: $(uname -s)"
  echo "this launcher supports Linux, macOS, and Windows (via Git Bash/MSYS2)."
  read -rp "Press Enter to close..."
  exit 1
fi

if [ -z "$ARCH_NAME" ]; then
  echo "[error] unsupported CPU architecture: $(uname -m)"
  echo "this launcher supports x64 (Intel/AMD 64-bit), aarch64 (ARM 64-bit), and x86 (32-bit)."
  read -rp "Press Enter to close..."
  exit 1
fi

echo "===================="
echo " Minecraft Portable"
echo " 1.8.9 Forge"
echo "===================="
echo ""
echo "[info] detected platform: ${OS_NAME}-${ARCH_NAME}"

detect_ram
find_java
find_natives

echo ""
read -rp "username: " PLAYER_NAME

if [ -z "$PLAYER_NAME" ]; then
  echo "[error] username cannot be empty."
  read -rp "Press Enter to close..."
  exit 1
fi

echo ""
echo "building classpath... this may take a moment."
build_classpath

echo ""
echo "launching minecraft..."
echo ""

"$JAVA_CMD" \
  -Xmx"$RAM_AMOUNT" \
  -XX:+UseConcMarkSweepGC \
  -Djava.library.path="$NATIVES_DIR" \
  -Dorg.lwjgl.librarypath="$NATIVES_DIR" \
  -Dnet.java.games.input.librarypath="$NATIVES_DIR" \
  -cp "$CLASSPATH" \
  net.minecraft.launchwrapper.Launch \
  --username "$PLAYER_NAME" \
  --version 1.8.9-forge \
  --gameDir "$MC_DIR" \
  --assetsDir "$MC_DIR/assets" \
  --assetIndex 1.8 \
  --uuid 00000000-0000-0000-0000-000000000000 \
  --accessToken 0 \
  --userProperties {} \
  --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo ""
  echo "[CRASH] minecraft closed with error code $EXIT_CODE."
  echo ""
  read -rp "Press Enter to close..."
fi
