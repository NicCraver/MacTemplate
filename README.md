# MacTemplate

macOS 15 SwiftUI 日常开发骨架。依赖旁边的 [ChunUI](../ChunUI)：双栏窗口、菜单命令、系统设置、关于窗口、品牌色换肤。

## 运行

```bash
pnpm run start
```

会生成工程、编译并直接打开 App。打开 Xcode：`pnpm run xcode`。跑单元测试：`pnpm test`。跑 UI 测试：`pnpm run test:ui`。

工程默认 ad-hoc 签名，方便本机直接跑。要分发时在 Signing 里换成你的 Team。

## 开新 App

```bash
cp -R MacTemplate MyApp && cd MyApp
./Scripts/rename.sh MyApp com.you.myapp
pnpm run start
```

`rename.sh` 会把类型名、bundle id 和 UserDefaults 前缀 `macTemplate` 一起换成新名字。然后改 `AppSection`（`primary` + `destination`）和 `Features/` 里的页面。菜单、「前往」快捷键、菜单栏会跟 `AppSection.menuOrder` 走。

ChunUI 默认走 `../ChunUI`；仓库搬走后改 `project.yml` 的 package path，或换成：

```yaml
packages:
  ChunUI:
    url: https://github.com/liseami/ChunUI
    branch: main
```

## 已经预埋的

| 能力 | 入口 |
|---|---|
| App 图标 | `Resources/Assets.xcassets/AppIcon.appiconset` |
| 侧栏：概览 / 资料库，设置钉在最底部 | `Sources/Navigation/` |
| 前往菜单 ⌘1 / ⌘2 / ⌘3 | `AppSection.menuOrder` → `AppCommands` |
| 设置页 | 侧栏「设置」 |
| 关于窗口 | 菜单「关于」 |
| 换肤 | `AppTheme` + `ChunUI.configure` |

重做图标：把新的 1024 PNG 放到 Cursor assets 后跑 `python3 Scripts/make-icons.py`。

设置、公证、Sparkle 不在本模板里。

## Agent

项目约定见 `AGENTS.md`。ChunUI 组件用法见 `skills/chunui/`；Mac 窗口/菜单规则见 `skills/mac-template/`。
