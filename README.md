# Minecraft Portable 1.8.9 Forge

A lightweight, portable version of Minecraft 1.8.9 with Forge pre-installed. This version functions without external launchers or system-wide installation. It is designed to run directly from a USB drive or a local folder.

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
