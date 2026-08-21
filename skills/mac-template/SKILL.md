---
name: mac-template
description: Native macOS SwiftUI app template rules — WindowGroup, Settings scene, commands, AppTheme, ChunUI on Mac. Use when editing this repo, adding sidebar sections, windows, menus, or settings.
---

# MacTemplate

独立 macOS App 骨架。视觉组件源码在本仓库 `Packages/ChunUI`，SwiftUI Scene 管窗口。

## 三个 Scene

1. `WindowGroup` → `RootSplitView`（侧栏 + detail；资料库自己持有 `NavigationStack`）
2. `Window(id: "about")` → `AboutView`（跟 `theme.revision` 重建）
3. `MenuBarExtra` → 菜单栏状态项

侧栏：`AppSection.primary` 在上，`settings` 钉在最底部。加业务页改 `AppSection`（`primary` + `destination`）和 `Features/`。`AppCommands` / `StatusBarMenu` 遍历 `menuOrder`，不要再抄一份标题和快捷键。

## 状态

- `AppSession.section`：侧栏与「前往」菜单的单一来源；再点当前分区会 bump `navigationEpoch`（资料库回到根）
- `AppTheme`：键前缀 `macTemplate.*`（`PreferenceKey`）；`rename.sh` 会一起换掉
- 外观改 `preferredColorScheme`；品牌色走 `BrandPaletteApplying`，必须 bump `revision`

## 不要做

- 不要加窗口底栏
- 不要在 Mac 上用 UIKit `AppHelper` sheet 栈
- 不要引入 SwiftData / 网络 / Sparkle，除非用户明确要求
- 不要加 GitHub Actions 在 push/PR 上跑测试；推送前本地 `pnpm test`
- 不要在业务页手写空态，用 `CCEmptyState`
- 不要把侧栏选中图标设成 `primaryForeground`（那是铺在品牌色上的白字）

启动：`pnpm run start`。改完代码必须再跑一次。菜单栏状态项默认开启；设置 → 通用可关闭。开新项目：`./Scripts/rename.sh NewName com.you.newapp`
