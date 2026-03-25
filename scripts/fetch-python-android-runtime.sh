#!/usr/bin/env bash
set -euo pipefail
PY_VER="${PY_VER:-3.14.3}"
ARCH="${ARCH:-aarch64}"
WORKDIR="${WORKDIR:-$(pwd)/build/mitmdump-python-runtime}"
URL="https://www.python.org/ftp/python/${PY_VER}/python-${PY_VER}-${ARCH}-linux-android.tar.gz"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
ARCHIVE="python-${PY_VER}-${ARCH}-linux-android.tar.gz"
if [ ! -f "$ARCHIVE" ]; then
  curl -L "$URL" -o "$ARCHIVE"
fi
rm -rf unpack
mkdir -p unpack
tar -xzf "$ARCHIVE" -C unpack
printf "[ok] runtime unpacked at: %s\n" "$WORKDIR/unpack/prefix"
