# mitmdump Android ARM64 bundle notes

## Goal

Build a managed Android ARM64 mitmdump runtime bundle for FSploit instead of assuming a single native binary.

## Why this exists

`mitmdump` is not like `bettercap`.

It depends on:
- a Python runtime
- Python standard library
- Python packages
- `mitmproxy_rs` native extension
- shared libraries required by the Android Python runtime

So the correct delivery shape is a bundle, not a single executable file.

## Bundle layout

```text
toolchain/mitmdump/
  bin/mitmdump
  python/bin/python3
  python/lib/...
  lib/...
```

## Runtime source

Current runtime base:
- official Python Android embeddable package
- example version used during research: `3.14.3`
- source: `https://test.python.org/downloads/android/`

## Native extension source

`mitmproxy_rs` is built from source for `aarch64-linux-android` with Android NDK.

## Important constraints

1. You cannot rely on PyPI to provide a complete Android wheel set for all mitmproxy dependencies.
2. Pure-Python wheels can be staged easily.
3. Native pieces must be handled explicitly.
4. First goal should be `mitmdump --version` / minimal startup, not full feature parity on day one.

## Scripts

- `scripts/fetch-python-android-runtime.sh`
- `scripts/build-mitmproxy-rs-android.sh`
- `scripts/assemble-mitmdump-bundle.sh`

## Release recommendation

Do not commit generated runtime trees or tarballs into git.
Recommended:
- commit scripts/docs/wrappers
- upload final `mitmdump-android-aarch64-bundle-*.tar.gz` to GitHub Releases
