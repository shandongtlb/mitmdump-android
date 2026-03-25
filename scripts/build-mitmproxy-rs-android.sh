#!/usr/bin/env bash
set -euo pipefail
: "${ANDROID_NDK_HOME:?set ANDROID_NDK_HOME}"
TARGET="${TARGET:-aarch64-linux-android}"
API="${API:-28}"
WORKDIR="${WORKDIR:-$(pwd)/build/mitmproxy-rs-android}"
RUNTIME_PREFIX="${RUNTIME_PREFIX:-$(pwd)/build/mitmdump-python-runtime/unpack/prefix}"
REPO_DIR="$WORKDIR/mitmproxy-rs"
VENV_DIR="$WORKDIR/hostvenv"
OUTDIR="$WORKDIR/dist"
mkdir -p "$WORKDIR" "$OUTDIR"
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone https://github.com/mitmproxy/mitmproxy_rs.git "$REPO_DIR"
fi
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python -m pip install -U pip setuptools wheel maturin
if [ ! -f "$HOME/.cargo/env" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi
source "$HOME/.cargo/env"
rustup target add "$TARGET"
export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export CC_aarch64_linux_android="aarch64-linux-android${API}-clang"
export CXX_aarch64_linux_android="aarch64-linux-android${API}-clang++"
export AR_aarch64_linux_android="llvm-ar"
export RANLIB_aarch64_linux_android="llvm-ranlib"
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="aarch64-linux-android${API}-clang"
export CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS="-L${RUNTIME_PREFIX}/lib"
export RUSTFLAGS="-L${RUNTIME_PREFIX}/lib"
export LIBRARY_PATH="${RUNTIME_PREFIX}/lib"
export PYO3_CROSS=1
export PYO3_CROSS_LIB_DIR="${RUNTIME_PREFIX}/lib/python3.14"
export PYO3_CROSS_PYTHON_VERSION=3.14
cd "$REPO_DIR/mitmproxy-rs"
maturin build --release --target "$TARGET" -i python3.12 -o "$OUTDIR"
printf "[ok] wheel(s) in: %s\n" "$OUTDIR"
ls -lah "$OUTDIR"
