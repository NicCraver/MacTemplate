# MacTemplate 日常开发骨架

日期：2026-08-18  
状态：已批准（架构、组件；数据流/错误处理/测试由实现者按本节落地）

## 目标

独立的 macOS 15+ SwiftUI 工程，依赖本地 `../ChunUI`。复制仓库、跑 rename 脚本后即可开新 App。覆盖窗口壳、侧栏导航、菜单命令、设置持久化、关于窗口。不含沙盒/公证/Sparkle。

## 架构

`MacTemplateApp` 挂三个 Scene：

- `WindowGroup`：主窗口，`NavigationSplitView` 侧栏 + detail
- `Settings`：系统设置窗口（⌘,）
- `Window(id: "about")`：关于窗口，按内容尺寸、隐藏标题栏

侧栏只有 **概览**、**资料库**。设置不进侧栏。

视觉走 ChunUI（语义色、三梯度字号、`CCNeoButton` / `CCAppleCard` / `PikaIcon`）。ChunUI iOS 铁律「禁 SwiftUI sheet、走 UIKit AppHelper」**不适用于 Mac**。窗口/菜单/Settings 用原生 SwiftUI Scene。

## 组件

见已批准清单：`AppTheme`、`AppSession`、`AppCommands`、`RootSplitView`/`SidebarView`、`OverviewPage`、`LibraryPage`、`SettingsRootView`（通用 + 外观 Tab）、`AboutView`、`Scripts/rename.sh`。

## 数据流

1. 启动：`AppTheme` 从 `UserDefaults` 读外观与品牌色 hex；非法值回退默认；`ChunUI.configure` 后进视图树。
2. 外观：`preferredColorScheme` 绑定 `AppearanceMode`（system/light/dark），不重建根视图。
3. 品牌色：写入 `UserDefaults` 后 `ChunUI.configure`，并增加 `theme.revision`，根视图 `.id(revision)` 重建（ChunUI 换肤必须重建）。
4. 导航：`AppSession.section` 是侧栏与「前往」菜单的单一来源。资料库列表为内存占位，搜索为纯函数过滤。
5. 无网络、无 SwiftData。设置键：`macTemplate.appearanceMode`、`macTemplate.brandColorHex`。

## 错误处理

- 未知 `appearanceMode` 原始值 → `.system`
- 未知品牌 hex → 霓虹粉 `ff00c8`
- 搜索无结果 → `CCEmptyState(kind: .knowledge)`
- `rename.sh` 参数非法（非 Swift 标识符 / 非法 bundle id）→ 非零退出并打印用法
- 不引入通用错误总线

## 测试

Swift Testing 单元测试 target：

- `AppSection` 分区数量与标题
- `LibraryItem.filtered`：空查询、标题命中、副标题命中、大小写
- `AppearanceMode.colorScheme` 映射
- `BrandColor.named` 已知/未知 hex
- `AppTheme` 使用独立 `UserDefaults` suite：非法值回退、品牌写入后 hex 更新

## 开新 App

```bash
./Scripts/rename.sh NewName com.you.newapp
xcodegen generate
open NewName.xcodeproj   # 或仍为生成后的工程名，以脚本改写的 project.yml 为准
```

SPM 路径保持 `../ChunUI`，拷到别处时改 `project.yml` 的 package path 或 git URL。
