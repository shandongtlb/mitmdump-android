#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$(pwd)}"
PKGROOT="${PKGROOT:-$ROOT/build/mitmdump-package}"
RUNTIME_PREFIX="${RUNTIME_PREFIX:-$ROOT/build/mitmdump-python-runtime/unpack/prefix}"
HOST_WHEELS="${HOST_WHEELS:-$ROOT/build/mitmdump-host-wheels}"
ANDROID_WHEEL="${ANDROID_WHEEL:-}"
OUT_TGZ="${OUT_TGZ:-$ROOT/build/mitmdump-android-aarch64-bundle-v0.tar.gz}"
if [ -z "$ANDROID_WHEEL" ]; then
  echo "ANDROID_WHEEL is required" >&2
  exit 1
fi
rm -rf "$PKGROOT"
BASE="$PKGROOT/toolchain/mitmdump"
mkdir -p "$BASE/bin" "$BASE/python/bin" "$BASE/lib" "$ROOT/build/stage-pure"
cp -a "$RUNTIME_PREFIX/." "$BASE/python/"
find "$BASE/python/lib" -maxdepth 1 -type f -name *.so* -exec cp -a {} "$BASE/lib/" \;
python3 - <<PY
import os, zipfile, glob, shutil
stage = os.path.join("$ROOT", "build/stage-pure")
if os.path.exists(stage):
    shutil.rmtree(stage)
os.makedirs(stage, exist_ok=True)
for whl in glob.glob(os.path.join("$HOST_WHEELS", "*.whl")):
    name = os.path.basename(whl)
    if any(tag in name for tag in ["manylinux", "linux_", "win", "macosx", "musllinux"]):
        continue
    with zipfile.ZipFile(whl) as z:
        z.extractall(stage)
with zipfile.ZipFile("$ANDROID_WHEEL") as z:
    z.extractall(stage)
PY
cp -a "$ROOT/build/stage-pure/." "$BASE/python/lib/python3.14/site-packages/"
cp packaging/mitmdump/bin/mitmdump "$BASE/bin/mitmdump"
cp packaging/mitmdump/python/bin/python3 "$BASE/python/bin/python3"
chmod +x "$BASE/bin/mitmdump" "$BASE/python/bin/python3"
mkdir -p "$(dirname "$OUT_TGZ")"
(cd "$PKGROOT" && tar -czf "$OUT_TGZ" toolchain)
printf "[ok] bundle created: %s\n" "$OUT_TGZ"
ls -lah "$OUT_TGZ"
