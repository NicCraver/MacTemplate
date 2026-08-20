# MacTemplate

macOS 15 SwiftUI 模板。视觉用 ChunUI，窗口用原生 Scene。

## 硬规则

- 颜色只走 `Color.cc.*`，品牌色是页面上唯一彩色。
- 字号只走 `Font.cc.sm / base / lg`（含 Bold），文字用 `.ccText(font:color:)`。
- 业务图标用 `AppIconName` / `PikaIcon.Name.*`，不要散用 SF Symbols。手写图标名必须能对上 Pika 资产（`settings01` 不是 `settings-01`）。
- **不要**把 ChunUI iOS 那套 `AppHelper.presentSheet` / 禁 `.sheet` 搬到 Mac。Mac 用 `WindowGroup`、`Window(id:)`、`.commands`。
- 设置钉在侧栏最底部（`AppSection.settings`），不要用窗口底栏。业务分区走 `AppSection.primary`。
- 换肤必须 `ChunUI.configure` 后增加 `AppTheme.revision`，根视图和关于窗口用 `.id(theme.revision)`。测试里注入 `BrandPaletteApplying`，不要在 TEST_HOST 里直接 configure。
- 新页面：加 `AppSection` case、写入 `primary`、在 `destination` 里接线、放 `Sources/Features/<Name>/`。菜单 / 快捷键 / 菜单栏跟 `menuOrder` 走，不要再手写一份。
- **每次改完代码都 `pnpm run start`**（生成工程、编译、打开 App），不要只编译不打开。

## 启动

`pnpm run start`（生成工程、编译、打开 App）。`pnpm run xcode` 打开 Xcode。`pnpm test` 跑单元测试。菜单栏图标默认开启。

## 开新 App

`./Scripts/rename.sh NewName com.you.newapp`

## 参考

- ChunUI 组件：`skills/chunui/SKILL.md`
- Mac 模板：`skills/mac-template/SKILL.md`
