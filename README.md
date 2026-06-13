# War on the Sea 简体中文补丁 | Simplified Chinese Localization Patch

[![Version](https://img.shields.io/badge/patch-v1.0-blue)]() [![Game](https://img.shields.io/badge/game-v1.09a%20(Steam)-green)]() [![License](https://img.shields.io/badge/license-Free%20%C2%B7%20Non--commercial-orange)]()

为 Killerfish Games 的二战海战游戏 **《War on the Sea》** 制作的完整简体中文本地化补丁，完全免费。

A free, complete Simplified Chinese localization patch for **War on the Sea** by Killerfish Games.

---

## 📥 下载安装 / Download & Install

1. 从 [Releases](../../releases) 或 [`release/`](release/) 目录下载 `War_on_the_Sea_简体中文补丁_v1.0.zip`
2. 解压后双击 **`中文补丁安装器.bat`**
3. 点击 **「汉化为简体中文」** —— 完成！（随时可点「还原为初始状态」恢复英文）

1. Download the zip from [Releases](../../releases) or the [`release/`](release/) folder
2. Extract and double-click **`中文补丁安装器.bat`** (the GUI installer)
3. Click the green button to install Chinese — done! (The red button restores English anytime.)

> 安装器会自动定位 Steam 游戏目录；未找到时可手动浏览选择。
> The installer auto-detects your Steam game folder, with a manual browse fallback.

## ⚠️ 版本与正版声明 / Version & Genuine Copy Notice

- 本补丁基于 **Steam 正版 v1.09a** 制作并测试，其他版本未必能正常使用，且不提供支持。
- **请支持正版游戏** —— 开发者的持续更新离不开每一位玩家的正版支持。
- Built and tested on the **genuine Steam release v1.09a**. Other versions are not supported.
- **Please buy the game** — ongoing development depends on genuine players.

## 📋 汉化范围 / Coverage

| 内容 / Content | 状态 / Status |
|---|---|
| 菜单、选项、按键设置 / Menus, options, keybinds | ✅ |
| 战斗 HUD、信息日志、损管、战斗报告 / Combat HUD, message log, damage control, reports | ✅ |
| 战役界面与剧情（瞭望台行动、瓜岛战役、教学战役）/ Campaign UI, briefings & events | ✅ |
| 87 篇教程任务 / All 87 tutorial pages | ✅ |
| 40 个历史海战简介 / 40 historical battle descriptions | ✅ |
| 识别手册：93 型舰船与飞机（级名、同级舰名、武器挂载）/ Recognition Manual: all 93 classes | ✅ |
| HUD 缩写（SPD/HDG/BRG 等）/ HUD abbreviations | 保留英文 kept in English（对齐敏感 / layout-sensitive） |

共翻译 **268 个文本文件**。日舰舰名采用标准汉字写法（雪风、吹雪、大和……），美英舰名采用通行中文译名。

**268 text files** translated in total. Japanese ship names use standard kanji-derived Chinese; US/UK ship names use established Chinese transliterations.

## 🔧 实现原理 / How It Works

补丁使用游戏内置的 `override` 模组目录与语言加载机制，**不修改任何原版文件**：

```
WarOnTheSea_Data\StreamingAssets\override\language\chinese\   ← 268 个翻译文本
WarOnTheSea_Data\StreamingAssets\override\config.txt          ← "language":"chinese"
```

- 存档完全兼容，随装随卸 / Saves fully compatible, install/uninstall anytime
- 游戏更新不会破坏补丁 / Game updates won't break the patch
- 中文通过 Unity 动态字体回退（微软雅黑）渲染 / Chinese renders via Unity's dynamic-font OS fallback

The patch leverages the game's built-in `override` mod folder and language system — **no original file is ever modified**.

## 🗂️ 仓库结构 / Repository Layout

```
patch/chinese/        268 个汉化文本（开发者可直接取用）/ the translated files (devs: feel free to take these)
installer.ps1         图形安装器 / GUI installer (PowerShell + WinForms)
中文补丁安装器.bat      安装器启动入口 / installer launcher
release/              打包好的安装包 / packaged release zip
```

## ❤️ 致谢 / Acknowledgements

衷心感谢 **Killerfish Games** 带来这么好的海战游戏——从《Cold Waters》到《War on the Sea》，你们对海战模拟的热爱与匠心有目共睹。希望这款游戏持续更新，越做越好！

Huge thanks to **Killerfish Games** for this outstanding WWII naval warfare game. From *Cold Waters* to *War on the Sea*, your passion and craftsmanship shine through. We hope the updates keep coming!

翻译、逆向分析、校验工具与安装器由 **Claude Fable 5 (Anthropic)** 完成。

Translation, reverse engineering, QA tooling and the installer were done by **Claude Fable 5 (Anthropic)**.

## 💌 致开发团队 / To Killerfish Games

> 诚挚邀请你们将本翻译**无偿**收编为官方简体中文。中文海战玩家社区庞大而热情，官方中文支持必将吸引更多中文玩家。`patch/chinese/` 中的全部文件可直接使用，如需任何配合请随时联系。
>
> You are warmly invited to adopt this translation as the official Simplified Chinese localization — **free of charge, no strings attached**. The Chinese naval-sim community is large and passionate; official Chinese support would bring many more players to the game. Everything under `patch/chinese/` is ready to use as-is.

## 📜 许可 / License

本补丁永久免费，欢迎转载分享（请保留说明文件）。**禁止任何形式的商业用途与收费传播。** Killerfish Games 可无偿将本翻译用于游戏官方本地化。

This patch is free forever. Share freely (keep the readme intact). **Commercial use and paid distribution are prohibited.** Killerfish Games is explicitly granted free use of this translation for official localization.
