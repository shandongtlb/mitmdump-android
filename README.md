# MITMDUMP Android ARM64 编译说明

这份文档说明如何为 FSploit 生成可受管下载的 `mitmdump` Android ARM64 bundle。

## 目标产物

```text
toolchain/mitmdump/
  bin/mitmdump
  python/bin/python3
  python/lib/...
  lib/...
```

最终建议发布为：

```text
mitmdump-android-aarch64-bundle-v0.tar.gz
```

然后通过 GitHub Releases 提供给应用下载。

---

## 设计结论

`mitmdump` 不能按 `bettercap` 的单二进制方式处理。

原因：
- `mitmdump` 本质是 Python 应用
- 依赖 Python 标准库
- 依赖 `mitmproxy_rs` 这类 native 扩展
- Android 平台需要显式带上 `libpython3.x.so`

所以正确交付形式是 **bundle**，不是单文件 ELF。

---

## 依赖前提

建议环境：Linux x86_64

需要：
- `python3`
- `git`
- `curl`
- `tar`
- Android NDK r26+
- Rust / cargo / rustup

建议环境变量：

```bash
export ANDROID_NDK_HOME=/path/to/android-ndk
```

---

## 第一步：获取官方 Android Python runtime

执行：

```bash
./scripts/fetch-python-android-runtime.sh
```

默认会拉取：
- Python `3.14.3`
- `aarch64-linux-android`

默认解包位置：

```text
build/mitmdump-python-runtime/unpack/prefix
```

这个 runtime 作为 bundle 基座使用。

---

## 第二步：构建 Android 版 mitmproxy_rs

执行：

```bash
ANDROID_NDK_HOME=/path/to/android-ndk \
./scripts/build-mitmproxy-rs-android.sh
```

默认输出位置：

```text
build/mitmproxy-rs-android/dist/
```

目标 wheel 类似：

```text
mitmproxy_rs-*.whl
```

---

## 第三步：准备 host wheels

当前实践里，先通过主机 Python 获取 `mitmproxy` 及其纯 Python 依赖，再在组装阶段过滤掉不适合 Android 的 host-native wheel。

建议把下载好的 host wheels 放到：

```text
build/mitmdump-host-wheels/
```

注意：
- 不能假设 PyPI 能提供完整 Android wheels
- 像 `aioquic` 这类依赖可能没有现成 Android 轮子
- 第一阶段目标应是最小启动链跑通

---

## 第四步：组装 bundle

执行：

```bash
ANDROID_WHEEL=/absolute/path/to/mitmproxy_rs-android.whl \
./scripts/assemble-mitmdump-bundle.sh
```

默认输出：

```text
build/mitmdump-android-aarch64-bundle-v0.tar.gz
```

---

## 当前已知限制

1. 这套流程首先追求“最小可启动 mitmdump”。
2. 不是所有 mitmproxy 依赖都能直接从 PyPI 获得 Android wheel。
3. 某些功能可能需要后续继续补 native 依赖。
4. 最终必须在 Android 真机或 emulator 上做实际启动验证。

---

## 建议提交到 GitHub 的内容

建议提交：
- `scripts/`
- `packaging/mitmdump/`
- `docs/mitmdump-android-bundle.md`
- 本说明文档 `MITMDUMP_ANDROID_BUILD.md`

不建议提交：
- 解压后的 Python runtime
- `target/`
- 虚拟环境
- 临时 stage 目录
- 最终 tar.gz 产物

最终 tar.gz 建议放 GitHub Releases。
