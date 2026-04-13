# Missing Binaries Guide

This document lists every JRE and native library bundle you need to add so that the launcher works on **all** platforms. The scripts (`start.sh`, `start.bat`, `start.command`) already detect the OS and architecture automatically — you just need to drop the right files in the right folders.

---

## Current state

| Platform | JRE | Natives | Status |
|---|---|---|---|
| Windows x64 | `jre/jdk8u472-b08-jre_windows_x64/` | `mcdata/natives/windows-x64/` | Working |
| Linux x64 | `jre/jdk8u472-b08-jre_linux_x64/` | `mcdata/natives/linux-x64/` | Working |
| macOS x64 (Intel) | **MISSING** | **MISSING** | Broken |
| macOS aarch64 (Apple Silicon) | **MISSING** | **MISSING** | Broken |
| Linux aarch64 (ARM 64-bit) | **MISSING** | **MISSING** | Broken |
| Windows x86 (32-bit) | **MISSING** | **MISSING** | Broken |
| Linux x86 (32-bit) | **MISSING** | **MISSING** | Broken |

---

## Step 1: Download the JREs

All JREs must be **Java 8** (to match Minecraft 1.8.9 + Forge). The project currently uses **Adoptium (Eclipse Temurin) 8u472-b08**. Use the same version for consistency, or any Java 8 JRE that works.

### Where to download

Go to: **https://adoptium.net/temurin/releases/?version=8**

Select **JRE** (not JDK) and download for each target:

| Platform | Adoptium filter | Expected archive |
|---|---|---|
| macOS x64 | OS: macOS, Arch: x64 | `OpenJDK8U-jre_x64_mac_hotspot_8uXXX.tar.gz` |
| macOS aarch64 | OS: macOS, Arch: aarch64 | `OpenJDK8U-jre_aarch64_mac_hotspot_8uXXX.tar.gz` |
| Linux aarch64 | OS: Linux, Arch: aarch64 | `OpenJDK8U-jre_aarch64_linux_hotspot_8uXXX.tar.gz` |
| Windows x86 | OS: Windows, Arch: x86 | `OpenJDK8U-jre_x86-32_windows_hotspot_8uXXX.msi` or `.zip` |
| Linux x86 | OS: Linux, Arch: x86 | *Not available from Adoptium* — see note below |

> **Note on Linux x86:** Adoptium does not provide 32-bit Linux builds for Java 8. You can try [Azul Zulu](https://www.azul.com/downloads/?version=java-8-lts&os=linux&architecture=x86-32-bit&package=jre) instead. 32-bit Linux is rare in 2025+ so this is low priority.

### How to install each JRE

1. Download the archive (`.tar.gz` or `.zip`)
2. Extract it
3. Rename the extracted folder to match this exact naming convention:

```
jre/
  jdk8u472-b08-jre_macos_x64/
    bin/
      java          <-- must exist and be executable
    lib/
    ...
  jdk8u472-b08-jre_macos_aarch64/
    bin/
      java
    lib/
    ...
  jdk8u472-b08-jre_linux_aarch64/
    bin/
      java
    lib/
    ...
  jdk8u472-b08-jre_windows_x86/
    bin/
      java.exe
    lib/
    ...
```

The naming convention is: `jdk8u472-b08-jre_{os}_{arch}/`

Where:
- `{os}` = `linux`, `macos`, or `windows`
- `{arch}` = `x64`, `aarch64`, or `x86`

**Important:** The folder name is how the launch scripts find the JRE. If you use a different JDK version, you need to update the folder name AND the reference in both `start.sh` and `start.bat` (search for `jdk8u472-b08-jre`).

### Verification

After placing a JRE, verify it works:

```bash
# Linux/macOS
./jre/jdk8u472-b08-jre_macos_x64/bin/java -version

# Windows (in cmd)
jre\jdk8u472-b08-jre_windows_x86\bin\java.exe -version
```

It should print something like: `openjdk version "1.8.0_472"`

---

## Step 2: Add native libraries

Minecraft 1.8.9 uses **LWJGL 2** and **JInput** for graphics, audio, and controller support. Each OS needs platform-specific `.dll`, `.so`, or `.dylib` files.

### Target folder structure

```
mcdata/natives/
  windows-x64/       <-- already exists
  linux-x64/         <-- already exists
  macos-x64/         <-- NEEDS TO BE CREATED
  macos-aarch64/     <-- NEEDS TO BE CREATED (see note)
  linux-aarch64/     <-- NEEDS TO BE CREATED
  windows-x86/       <-- NEEDS TO BE CREATED
  linux-x86/         <-- NEEDS TO BE CREATED
```

### Where to find the native libraries

#### Option A: Mojang's API (recommended — this is how the existing natives were obtained)

Mojang provides an API that lists every library and native download URL for every Minecraft version. This is the same API the official launcher uses internally.

**Step 1 — Get the version manifest:**

```
GET https://launchermeta.mojang.com/mc/game/version_manifest_v2.json
```

This returns a JSON with a `versions` array. Find the entry where `"id": "1.8.9"` and grab its `url` field.

For 1.8.9, the version JSON URL is:

```
https://piston-meta.mojang.com/v1/packages/d546f1707a3f2b7d034eece5ea2e311eda875787/1.8.9.json
```

**Step 2 — Fetch the version JSON:**

```
GET https://piston-meta.mojang.com/v1/packages/d546f1707a3f2b7d034eece5ea2e311eda875787/1.8.9.json
```

Inside the response, look at the `libraries` array. Libraries with a `natives` key contain platform-specific native downloads. The actual files are under `downloads.classifiers`.

**Step 3 — Download the native JARs:**

Here are the direct download URLs for all native libraries for 1.8.9:

**LWJGL Platform 2.9.4-nightly-20150209** (graphics, windowing):

| Platform | URL |
|---|---|
| Linux | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.4-nightly-20150209/lwjgl-platform-2.9.4-nightly-20150209-natives-linux.jar` |
| macOS | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.4-nightly-20150209/lwjgl-platform-2.9.4-nightly-20150209-natives-osx.jar` |
| Windows | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.4-nightly-20150209/lwjgl-platform-2.9.4-nightly-20150209-natives-windows.jar` |

**LWJGL Platform 2.9.2-nightly-20140822** (older version, also required):

| Platform | URL |
|---|---|
| Linux | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.2-nightly-20140822/lwjgl-platform-2.9.2-nightly-20140822-natives-linux.jar` |
| macOS | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.2-nightly-20140822/lwjgl-platform-2.9.2-nightly-20140822-natives-osx.jar` |
| Windows | `https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.2-nightly-20140822/lwjgl-platform-2.9.2-nightly-20140822-natives-windows.jar` |

**JInput Platform 2.0.5** (keyboard, mouse, controller input):

| Platform | URL |
|---|---|
| Linux | `https://libraries.minecraft.net/net/java/jinput/jinput-platform/2.0.5/jinput-platform-2.0.5-natives-linux.jar` |
| macOS | `https://libraries.minecraft.net/net/java/jinput/jinput-platform/2.0.5/jinput-platform-2.0.5-natives-osx.jar` |
| Windows | `https://libraries.minecraft.net/net/java/jinput/jinput-platform/2.0.5/jinput-platform-2.0.5-natives-windows.jar` |

**Twitch Platform 6.5** (Twitch integration — optional, Windows/macOS only):

| Platform | URL |
|---|---|
| macOS | `https://libraries.minecraft.net/tv/twitch/twitch-platform/6.5/twitch-platform-6.5-natives-osx.jar` |
| Windows 32-bit | `https://libraries.minecraft.net/tv/twitch/twitch-platform/6.5/twitch-platform-6.5-natives-windows-32.jar` |
| Windows 64-bit | `https://libraries.minecraft.net/tv/twitch/twitch-platform/6.5/twitch-platform-6.5-natives-windows-64.jar` |

**Twitch External Platform 4.5** (Windows only, optional):

| Platform | URL |
|---|---|
| Windows 32-bit | `https://libraries.minecraft.net/tv/twitch/twitch-external-platform/4.5/twitch-external-platform-4.5-natives-windows-32.jar` |
| Windows 64-bit | `https://libraries.minecraft.net/tv/twitch/twitch-external-platform/4.5/twitch-external-platform-4.5-natives-windows-64.jar` |

**Step 4 — Extract the native files:**

Each URL above downloads a `.jar` file (which is just a `.zip`). Extract it and you'll find the native `.dll`/`.so`/`.dylib` files inside. Ignore the `META-INF/` folder — just copy the native binary files into the appropriate `mcdata/natives/{os}-{arch}/` directory.

Example for macOS:

```bash
# Download the jars
curl -O https://libraries.minecraft.net/org/lwjgl/lwjgl/lwjgl-platform/2.9.4-nightly-20150209/lwjgl-platform-2.9.4-nightly-20150209-natives-osx.jar
curl -O https://libraries.minecraft.net/net/java/jinput/jinput-platform/2.0.5/jinput-platform-2.0.5-natives-osx.jar

# Create the target folder
mkdir -p mcdata/natives/macos-x64

# Extract native files (skip META-INF)
unzip -o lwjgl-platform-2.9.4-nightly-20150209-natives-osx.jar -d mcdata/natives/macos-x64/ -x "META-INF/*"
unzip -o jinput-platform-2.0.5-natives-osx.jar -d mcdata/natives/macos-x64/ -x "META-INF/*"
```

#### Option B: Extract from an existing Minecraft installation

If you have Minecraft installed on a target platform, the natives are extracted to:
- **Windows:** `%APPDATA%\.minecraft\versions\1.8.9\1.8.9-natives-XXXXXXX\`
- **macOS:** `~/Library/Application Support/minecraft/versions/1.8.9/1.8.9-natives-XXXXXXX/`
- **Linux:** `~/.minecraft/versions/1.8.9/1.8.9-natives-XXXXXXX/`

Copy all files from that folder into the appropriate `mcdata/natives/{os}-{arch}/` directory.

### What files go in each natives folder

#### macos-x64

```
liblwjgl.dylib
libopenal.dylib
libjinput-osx.jnilib
```

#### macos-aarch64

> **Note:** LWJGL 2 does NOT have official aarch64 macOS builds. On Apple Silicon Macs, the scripts will automatically use the `macos-x64` natives via Rosetta 2. So you only strictly need to create `macos-x64/`. If you want true native aarch64 support, you would need to compile LWJGL 2 from source for aarch64 — this is advanced and not recommended.

**Recommended approach:** Just create `macos-x64/` with the Intel natives. The start script already handles the Rosetta 2 fallback automatically.

#### linux-aarch64

```
liblwjgl.so
libopenal.so
libjinput-linux.so
```

> **Note:** LWJGL 2 does not provide official aarch64 Linux builds either. You may need to compile from source or find community-built binaries. This is the hardest platform to support. Search for "LWJGL 2 aarch64" community builds.

#### windows-x86

```
lwjgl.dll
OpenAL32.dll
jinput-dx8.dll
jinput-raw.dll
jinput-wintab.dll
```

These are the 32-bit versions. Get them from the LWJGL 2.9.4 `native/windows/` directory (the 32-bit DLLs, not the `*64.dll` ones).

#### linux-x86

```
liblwjgl.so
libopenal.so
libjinput-linux.so
```

32-bit Linux versions from LWJGL 2.9.4 `native/linux/`.

---

## Step 3: Test each platform

After adding JREs and natives, test on each platform:

1. Run the launcher (`start.sh`, `start.bat`, or `start.command`)
2. Verify it prints `[info] detected platform: {os}-{arch}`
3. Verify it prints `[info] using bundled JRE: ...`
4. Verify Minecraft starts and renders correctly
5. Verify audio works (OpenAL)
6. Verify keyboard/mouse input works (JInput)

---

## Priority order

If you can't do everything at once, here's the recommended priority:

1. **macOS x64** — most common Mac still in use, completes the "big three" OS support
2. **macOS aarch64** — Apple Silicon is the default for new Macs (use x64 natives + Rosetta 2)
3. **Windows x86** — some older machines and institutional computers are still 32-bit
4. **Linux aarch64** — Raspberry Pi, some Chromebooks, cloud ARM instances
5. **Linux x86** — very rare in 2025+, lowest priority

---

## Quick checklist

- [ ] Download macOS x64 JRE -> place in `jre/jdk8u472-b08-jre_macos_x64/`
- [ ] Download macOS aarch64 JRE -> place in `jre/jdk8u472-b08-jre_macos_aarch64/`
- [ ] Download Linux aarch64 JRE -> place in `jre/jdk8u472-b08-jre_linux_aarch64/`
- [ ] Download Windows x86 JRE -> place in `jre/jdk8u472-b08-jre_windows_x86/`
- [ ] Extract macOS x64 natives -> place in `mcdata/natives/macos-x64/`
- [ ] Extract Windows x86 natives -> place in `mcdata/natives/windows-x86/`
- [ ] Extract Linux aarch64 natives -> place in `mcdata/natives/linux-aarch64/`
- [ ] Extract Linux x86 natives -> place in `mcdata/natives/linux-x86/`
- [ ] Test on each platform
