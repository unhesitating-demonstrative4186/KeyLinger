# KeyLinger

[![CI](https://github.com/myweihp/KeyLinger/actions/workflows/ci.yml/badge.svg)](https://github.com/myweihp/KeyLinger/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/myweihp/KeyLinger)](https://github.com/myweihp/KeyLinger/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

一个 macOS 菜单栏小工具，实时显示系统当前仍判定为“按下”的键。

它不是从启动时才开始记录 `keydown` / `keyup` 事件，而是每秒 10 次直接查询
macOS 的 combined session 键位状态。因此 RustDesk 等远程控制软件漏掉 `keyup`
时，即使随后才启动本工具，也能看到卡住的键。

## 下载

从 [GitHub Releases](https://github.com/myweihp/KeyLinger/releases/latest) 下载对应机型的 DMG：

- Apple Silicon：选择文件名包含 `Apple-Silicon` 的版本，适用于 Apple M 系列芯片。
- Intel：选择文件名包含 `Intel` 的版本。

打开 DMG 后，将 `KeyLinger.app` 拖入 Applications。

当前版本使用 ad-hoc 签名，尚未使用 Apple Developer ID 公证。第一次启动时如果 macOS 阻止打开，
请在 Finder 中右键点按 KeyLinger，选择“打开”，然后确认。

## 运行

```bash
chmod +x build_app.sh
./build_app.sh
open "dist/KeyLinger.app"
```

也可以开发运行：

```bash
swift run KeyLinger
```

分别构建 Apple Silicon 与 Intel App/DMG：

```bash
./build_app.sh release arm64
./scripts/create_dmg.sh v0.5.1 arm64

./build_app.sh release x86_64
./scripts/create_dmg.sh v0.5.1 x86_64
```

如需本地生成同时包含两种架构的 App，仍可运行 `./build_app.sh release universal`。

程序默认显示一个置顶小面板，同时常驻菜单栏。关闭面板不会退出；可从菜单栏再次显示或退出。

菜单栏保留“显示面板 / 小窗模式 / 设置 / 退出”等常用入口。设置窗口可以选择
“跟随系统 / 简体中文 / English”、2–30 Hz 刷新频率和窗口模式；这些选择会自动保存。
“关于”区域提供项目地址，并通过 GitHub Releases 检查新版本。

## 系统要求

- macOS 13 或更高版本
- 窗口失焦后读取普通字母、数字和空格需要“输入监控”权限。程序会显示授权提示，
  也可以从菜单栏选择“启用输入监控…”。授权后可能需要重启本程序。

## 已知边界

- 显示的是 macOS 当前会话的逻辑键位状态，正好适合排查远程输入的“粘键”。
- 部分厂商自定义功能键、Touch Bar 动作或消费类媒体键不使用标准键盘虚拟键码，可能无法显示。

## 许可证

KeyLinger 使用 [MIT License](LICENSE) 开源。
