<p align="right">
  <a href="README.md">English</a> ·
  <a href="README.zh-Hans.md">简体中文</a> ·
  <strong>繁體中文</strong>
</p>

# KeyLinger

[![CI](https://github.com/myweihp/KeyLinger/actions/workflows/ci.yml/badge.svg)](https://github.com/myweihp/KeyLinger/actions/workflows/ci.yml)
[![最新版本](https://img.shields.io/github/v/release/myweihp/KeyLinger)](https://github.com/myweihp/KeyLinger/releases/latest)
[![授權條款：MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 查看 macOS 此刻仍然認為處於按下狀態的按鍵。

KeyLinger 是一款輕量的 macOS 鍵盤狀態診斷工具。它**直接查詢目前的鍵位狀態**，而不是依靠收到的 `keydown` 和 `keyup` 事件來還原狀態。

這正是它與一般按鍵測試工具不同的地方。事件監聽器只知道啟動之後收到的事件；如果遠端桌面、虛擬機、輸入工具或某個應用程式漏掉了一次 `keyup`，事後再開啟事件檢視器通常已經無法還原現場。KeyLinger 會直接詢問 macOS 目前的工作階段「哪些鍵仍被認為按著」，因此在啟動前就已經卡住的鍵，也能在第一次讀取時出現。

## 它有什麼不同

| | 事件監聽方式 | KeyLinger |
| --- | --- | --- |
| 資料來源 | 啟動後新收到的鍵盤事件 | macOS 目前回報的鍵位狀態 |
| 啟動前已經卡住的鍵 | 通常無法從缺失的事件中推斷 | 可以立即顯示 |
| 主要用途 | 觀察接下來發生的輸入事件 | 診斷目前工作階段的按鍵狀態 |
| 歷史記錄 | 可能保留事件日誌 | 不儲存按鍵歷史 |

KeyLinger 內部持續查詢：

```swift
CGEventSource.keyState(.combinedSessionState, key: keyCode)
```

預設讀取頻率為 10 Hz，可在 2–30 Hz 之間調整。KeyLinger 只讀取狀態，不會模擬按鍵事件，也不會嘗試強制放開卡住的鍵。

## 介面

<table>
  <tr>
    <td width="50%" valign="top">
      <p align="center">
        <strong>鍵盤 Map</strong><br>
        <sub>被按下的鍵一目了然；ANSI 配置之外的鍵仍會顯示在下方</sub>
      </p>
      <a href="docs/images/keylinger-main.png">
        <img src="docs/images/keylinger-main.png" alt="KeyLinger 鍵盤 Map" width="100%">
      </a>
    </td>
    <td width="50%" valign="top">
      <p align="center">
        <strong>按鍵列表</strong><br>
        <sub>用精簡的文字列表快速讀取目前結果</sub>
      </p>
      <a href="docs/images/keylinger-list.png">
        <img src="docs/images/keylinger-list.png" alt="KeyLinger 按鍵列表" width="100%">
      </a>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <p align="center">
        <strong>小視窗模式</strong><br>
        <sub>只保留核心狀態，適合放在螢幕邊緣</sub>
      </p>
      <a href="docs/images/keylinger-compact.png">
        <img src="docs/images/keylinger-compact.png" alt="KeyLinger 小視窗模式" width="100%">
      </a>
    </td>
    <td width="50%" valign="top">
      <p align="center">
        <strong>設定</strong><br>
        <sub>語言、讀取頻率、外觀、隱私說明和更新檢查</sub>
      </p>
      <a href="docs/images/keylinger-settings.png">
        <img src="docs/images/keylinger-settings.png" alt="KeyLinger 設定視窗" width="100%">
      </a>
    </td>
  </tr>
</table>

## 適用情境

- 遠端控制結束後，修飾鍵、字母、數字或空白鍵仍被系統認為處於按下狀態。
- 某個應用程式表現得像一直按著某個鍵，但一時無法確定來源。
- 希望檢查目前工作階段狀態，又不想記錄實際輸入過的內容。
- 問題已經發生，需要事後確認究竟是哪個鍵卡住。

專案最初源於排查 RustDesk 工作階段中遺失 `keyup` 訊號的問題；同樣的狀態查詢方式也適用於任何出現「卡鍵」現象的應用程式。

## 功能

- 響應式 MacBook/ANSI 鍵盤 Map，清楚標出按下狀態。
- 按鍵列表檢視，適合用文字快速確認結果。
- 數字鍵盤、ISO、JIS 等 Map 外按鍵透過標籤補充顯示。
- 可跨桌面顯示的置頂面板，以及常駐選單列入口。
- 適合放在螢幕邊緣的小視窗模式。
- 2–30 Hz 可調讀取頻率，顯示偏好會自動儲存。
- English、简体中文和繁體中文介面。
- 分別提供 Apple Silicon 與 Intel 原生版本。

## 下載與安裝

前往 [GitHub Releases](https://github.com/myweihp/KeyLinger/releases/latest) 下載對應的 DMG：

- **Apple Silicon：** M 系列 Mac 選擇檔名包含 `Apple-Silicon` 的版本。
- **Intel：** 選擇檔名包含 `Intel` 的版本。

開啟 DMG，將 `KeyLinger.app` 拖入 Applications。

目前的安裝套件使用 ad-hoc 簽章，尚未通過 Apple Developer ID 公證。首次啟動時 macOS 可能會阻止開啟；請在 Finder 中按住 Control 點按或按右鍵點按 KeyLinger，選擇**打開**，再確認提示。

## 權限與系統需求

- macOS 13 或更新版本。
- 當焦點位於其他應用程式時，要可靠讀取字母、數字和空白鍵等一般按鍵，需要授予「輸入監控」權限。
- 授權後可能需要重新啟動 KeyLinger，失焦偵測才會生效。

權限缺失時，KeyLinger 會顯示說明，並可開啟對應的系統設定頁面。

## 隱私

KeyLinger 只讀取 macOS 目前回報為「按下」的按鍵集合。它不會儲存按鍵事件歷史、還原輸入內容、將鍵盤資料寫入磁碟，也不會上傳鍵盤資料。

只有手動點按**檢查更新**時，程式才會存取 GitHub。

## 從原始碼建置

建置並開啟目前機器的 App：

```bash
./build_app.sh release native
open "dist/KeyLinger.app"
```

開發時也可以透過 Swift Package Manager 直接執行：

```bash
swift run KeyLinger
```

分別建置不同架構的 App 與 DMG：

```bash
./build_app.sh release arm64
./scripts/create_dmg.sh arm64

./build_app.sh release x86_64
./scripts/create_dmg.sh x86_64
```

執行 `./build_app.sh release universal` 可以在本機產生通用 App。鍵盤配置資料也可以單獨驗證：

```bash
swift run KeyLinger --validate-keyboard-layout
```

## 已知限制

- KeyLinger 顯示的是 macOS 目前工作階段的邏輯狀態，而不是實體鍵盤的電氣狀態。
- 鍵盤 Map 目前採用常見的 MacBook/ANSI 排列；數字鍵盤、ISO、JIS 等配置外按鍵被按下時會以標籤顯示，不會從診斷結果中消失。
- 部分廠商自訂功能鍵、Touch Bar 動作或消費類媒體鍵不使用標準虛擬鍵碼，可能無法顯示。
- KeyLinger 用於診斷卡鍵，不會強制修改或放開按鍵狀態。

## 文件語言

- [English](README.md)
- [简体中文](README.zh-Hans.md)
- **繁體中文**

## 授權條款

KeyLinger 以 [MIT License](LICENSE) 開源。
