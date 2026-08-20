import AppKit
import SwiftUI

enum AppWindows {
    static func showMain(openWindow: OpenWindowAction) {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: isMainWindow) {
            window.makeKeyAndOrderFront(nil)
            return
        }
        openWindow(id: "main")
    }

    static func isMainWindow(_ window: NSWindow) -> Bool {
        isMainWindow(identifier: window.identifier?.rawValue)
    }

    static func isMainWindow(identifier: String?) -> Bool {
        guard let identifier, !identifier.isEmpty else { return false }
        return identifier == "main" || identifier.hasPrefix("main-")
    }
}
