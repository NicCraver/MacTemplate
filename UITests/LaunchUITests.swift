import XCTest

final class LaunchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testLaunchShowsMainWindow() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.windows.firstMatch.waitForExistence(timeout: 10),
            "main window should appear"
        )
    }

    func testCommandCommaOpensSettings() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 10))
        app.typeKey(",", modifierFlags: .command)
        let statusBarTitle = app.staticTexts["在菜单栏显示图标"]
        let groupTitle = app.staticTexts["菜单栏"]
        XCTAssertTrue(
            statusBarTitle.waitForExistence(timeout: 8) || groupTitle.waitForExistence(timeout: 4),
            "⌘, should open general settings"
        )
    }
}
