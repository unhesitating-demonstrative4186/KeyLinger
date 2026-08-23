# Changelog

## 0.9.0 — 2026-08-23

- Added an optional Dock presence, enabled by default, with a menu-bar-only setting for users who prefer it.
- Dock activation now restores the main panel, with localized Dock and application menus.
- Added native window minimization, including the yellow title-bar control and Command-M, when Dock mode is enabled.
- Returned the main and settings windows to normal macOS layering so they no longer remain above unrelated apps.
- Reworked the app icon into a full-size single-squircle design without the previous nested outer bezel.

## 0.8.1 — 2026-08-23

- Migrated to the stable `io.github.myweihp.KeyLinger` bundle identifier, preserving existing app preferences.
- Existing users need to grant Input Monitoring once more after updating because macOS treats the stable bundle identifier as a new app identity.
- Stabilized the menu bar item with a fixed idle width, an adaptive template symbol, and a reliable pressed-key count.
- Added a text fallback for systems where the keyboard SF Symbol is unavailable.
- Aligned all three settings pickers and removed the duplicate accent-color swatch on macOS 26.

## 0.8.0 — 2026-08-23

- 新增响应式 MacBook/ANSI 键盘 Map，可直观看到被系统判定为按下的键帽。
- 完整面板支持按键列表与键盘 Map 切换，并自动记住上次选择。
- 数字小键盘、ISO/JIS 等布局外按键继续通过标签显示，避免诊断结果遗漏。

## 0.7.0 — 2026-08-23

- 新增跟随系统、薄荷绿、蓝色、靛蓝和紫色强调色主题。
- 主题应用于交互控件和界面点缀，状态语义色保持不变。

## 0.6.1 — 2026-08-23

- 设置中的 GitHub 项目入口改用 GitHub 官方 mark。

## 0.6.0 — 2026-08-23

- 新增繁体中文，并让“跟随系统”正确区分简体与繁体中文环境。
- 在设置与 README 中加入隐私说明。
- 加入应用界面截图与本地化文案一致性检查。

## 0.5.1 — 2026-08-23

- 分别提供 Apple Silicon（arm64）与 Intel（x86_64）DMG，方便按机型下载。
- 保留 Universal App 的本地构建支持。
- 加入 KeyLinger 应用图标，用于 Finder、应用程序目录和系统界面。

## 0.5.0 — 2026-08-23

- 实时读取 macOS 当前会话中的按下键位，而不是仅记录启动后的事件。
- 支持输入监控授权，在其他应用获得焦点时继续读取普通键。
- 提供完整面板、小窗模式和菜单栏状态。
- 支持简体中文、English 与跟随系统。
- 支持 2、5、10、20、30 Hz 刷新频率。
- 加入 GitHub 项目入口与 Release 更新检查。
- 提供 Apple Silicon 与 Intel 通用的 DMG 分发包。
