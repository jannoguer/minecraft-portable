# Minecraft Portable 1.8.9 Forge

A lightweight, portable version of Minecraft 1.8.9 with Forge pre-installed. This version functions without external launchers or system-wide installation. It is designed to run directly from a USB drive or a local folder.

## Features

* **Portable:** Runs completely self-contained.
* **Forge 1.8.9:** Ready for modding.
* **No Launcher:** Bypasses standard launchers for immediate play.
* **Customization:** Set your own username and manage mods easily.
* **Cross-Platform:** Includes scripts for both Windows and Linux/Unix.

## Installation

1. Download the repository.
2. Extract the files to a folder of your choice (e.g., on a USB stick or Desktop).

## Usage

### Windows

Double-click the `start.bat` file.

### Linux / macOS

Open a terminal in the folder and grant execution permissions to the script:

```bash
chmod +x start.sh

```

Then execute the script:

```bash
./start.sh

```

Upon launching, the script will allow you to input your desired username before the game starts.

## Managing Mods

To add mods to your game:

1. Open the `mods` folder located in the root directory.
2. Paste your `.jar` mod files (compatible with forge 1.8.9) into this folder.

## To Do

[  ] Add support for 32-bit systems. \
[X] Add support for Linux/Unix systems. \
[  ] Optimize config files.
