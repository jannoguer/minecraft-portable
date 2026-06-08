#!/usr/bin/env bash
# macOS double-click launcher, this file exists so Finder can run it.
# It just delegates to start.sh in the same directory.
cd "$(dirname "$0")" && exec ./start.sh
