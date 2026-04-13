# Minecraft Portable 1.8.9 Forge

A lightweight, portable version of Minecraft 1.8.9 with Forge pre-installed. This version functions without external launchers or system-wide installation. It is designed to run directly from a USB drive or a local folder.

## Features

* **Portable:** Runs completely self-contained — no installation, no registry, no app data.
* **Forge 1.8.9:** Ready for modding out of the box.
* **No Launcher:** Bypasses standard launchers for immediate play.
* **Customization:** Set your own username and manage mods easily.
* **Cross-Platform:** Includes launch scripts for Windows, Linux, and macOS.
* **Smart Detection:** Automatically detects your OS, CPU architecture, and available RAM.
* **Java Fallback:** If the bundled JRE doesn't match your system, falls back to your system Java.

## Installation

1. Download the repository.
2. Extract the files to a folder of your choice (e.g., on a USB stick or Desktop).

## Usage

### Windows

Double-click `start.bat`.

### Linux

Open a terminal in the folder and run:

```bash
chmod +x start.sh
./start.sh
```

### macOS

Double-click `start.command`, or open a terminal and run:

```bash
chmod +x start.sh start.command
./start.sh
```

Upon launching, the script will detect your platform, allocate an appropriate amount of RAM, and prompt you for a username before the game starts.

## Managing Mods

1. Open the `mods` folder located in the root directory.
2. Paste your `.jar` mod files (compatible with Forge 1.8.9) into this folder.

## Platform Support

| Platform | Status |
|---|---|
| Windows x64 | Working |
| Linux x64 | Working |
| macOS x64 (Intel) | Needs JRE + natives |
| macOS aarch64 (Apple Silicon) | Needs JRE + natives |
| Linux aarch64 (ARM) | Needs JRE + natives |
| Windows x86 (32-bit) | Needs JRE + natives |

The launch scripts already handle all of these platforms automatically. The only missing pieces are the bundled JRE and native library files for platforms beyond Windows/Linux x64.

## Contributing

If you want to add support for a missing platform, see [`docs/MISSING_BINARIES.md`](docs/MISSING_BINARIES.md) for a step-by-step guide on downloading and placing the required JRE and native binaries.

## To Do

- [x] Add support for Linux/Unix systems.
- [x] Cross-platform OS and architecture auto-detection.
- [x] RAM auto-detection.
- [x] System Java fallback.
- [x] macOS launcher (`start.command`).
- [ ] Bundle macOS JRE and natives.
- [ ] Bundle macOS Apple Silicon JRE and natives.
- [ ] Add support for 32-bit systems.
- [ ] Optimize minecraft config files.
