/*
 ╔═══════════════════════════════════════════════════════════════════════════╗
 ║                         Color+Mix.swift                                   ║
 ║                       颜色混合工具扩展                                      ║
 ╚═══════════════════════════════════════════════════════════════════════════╝

 [INPUT]: SwiftUI Color；RGB 取样走 Color.toRGB（macOS 会先转 sRGB）
 [OUTPUT]: 混合后的 Color
 [POS]: DesignSystem/Utils - 颜色运算工具，服务于微拟物效果

 [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
*/

import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Color 混合扩展
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension Color {

    /// 混合两个颜色（线性插值）
    ///
    /// 用于微拟物效果中的渐变、高光、阴影计算
    ///
    /// ```swift
    /// // 创建 15% 黑色混合（暗边效果）
    /// baseColor.mix(with: .black, amount: 0.15)
    ///
    /// // 创建 20% 白色混合（高光效果）
    /// baseColor.mix(with: .white, amount: 0.20)
    /// ```
    ///
    /// - Parameters:
    ///   - color: 要混入的颜色
    ///   - amount: 混合比例 (0.0 = 纯 self, 1.0 = 纯 color)
    /// - Returns: 混合后的颜色
    public func mix(with color: Color, amount: Double) -> Color {
        // 走 toRGB：macOS 自适应 Catalog 色必须先转 sRGB，
        // 直接 NSColor.getRed 会抛 NSInvalidArgumentException。
        let t = min(max(amount, 0), 1)
        let a = toRGB()
        let b = color.toRGB()
        return Color(
            red: Double(a.x) + (Double(b.x) - Double(a.x)) * t,
            green: Double(a.y) + (Double(b.y) - Double(a.y)) * t,
            blue: Double(a.z) + (Double(b.z) - Double(a.z)) * t
        )
    }
}
