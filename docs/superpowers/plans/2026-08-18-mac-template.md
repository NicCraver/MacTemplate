# MacTemplate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地可运行的 macOS 15 SwiftUI 日常骨架：侧栏、菜单、Settings、关于窗、ChunUI 换肤、rename 脚本。

**Architecture:** xcodegen App + Tests；Theme/Session 注入 Environment；三个 Scene；资料库内存占位。

**Tech Stack:** SwiftUI, macOS 15, xcodegen, ChunUI（本地 SPM）, Swift Testing

## Global Constraints

- macOS 15.0+；Swift 5 语言模式 + 默认 MainActor + Approachable Concurrency
- SPM 依赖 `../ChunUI` 产品 `ChunUI`
- 视觉：Color.cc / Font.cc / PikaIcon；唯一彩色为 `Color.cc.primary`
- Mac 窗口用 SwiftUI Scene，不走 ChunUI UIKit AppHelper
- 无沙盒、无公证、无 Sparkle、无 SwiftData
- 设置键：`macTemplate.appearanceMode`、`macTemplate.brandColorHex`

## Files

- Create: `project.yml`, `.gitignore`, `README.md`, `AGENTS.md`
- Create: `Scripts/rename.sh`
- Create: `Sources/App/MacTemplateApp.swift`, `Sources/App/AppCommands.swift`, `Sources/App/AppInfo.swift`, `Sources/App/AppSession.swift`
- Create: `Sources/Theme/AppearanceMode.swift`, `Sources/Theme/BrandColor.swift`, `Sources/Theme/AppTheme.swift`
- Create: `Sources/Navigation/AppSection.swift`, `Sources/Navigation/SidebarView.swift`, `Sources/Navigation/RootSplitView.swift`
- Create: `Sources/Features/Overview/OverviewPage.swift`
- Create: `Sources/Features/Library/LibraryItem.swift`, `LibraryPage.swift`, `LibraryDetailPage.swift`
- Create: `Sources/Settings/SettingsRootView.swift`, `GeneralSettingsView.swift`, `AppearanceSettingsView.swift`
- Create: `Sources/Windows/AboutView.swift`
- Create: `Tests/*.swift`
- Copy: `skills/chunui/` from `../ChunUI/skills/chunui`
- Create: `skills/mac-template/SKILL.md`

### Task 1: 工程骨架与纯逻辑

**Files:** `project.yml`, Theme/Navigation 纯类型, Tests, `.gitignore`

- [x] 实现 `AppearanceMode` / `BrandColor` / `AppSection` / `LibraryItem.filtered` / `AppTheme`
- [x] Swift Testing 覆盖过滤、回退、映射
- [x] `project.yml` 含 App + Tests

### Task 2: 三个 Scene 与导航壳

**Files:** App / Navigation / Commands / Overview / Library / Settings / About

- [x] WindowGroup + Settings + about Window
- [x] 菜单：关于、前往 ⌘1/⌘2、SidebarCommands
- [x] 换肤 revision 重建根视图

### Task 3: 脚本、文档、skill、编译

**Files:** `Scripts/rename.sh`, `README.md`, `AGENTS.md`, skills

- [x] rename 脚本校验参数并替换标识符
- [x] `xcodegen generate && xcodebuild test`
