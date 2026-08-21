// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ChunUI",
    defaultLocalization: "en",
    platforms: [
        .macOS("15.0"),
    ],
    products: [
        .library(name: "ChunUI", targets: ["ChunUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EmergeTools/Pow", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChunUI",
            dependencies: [.product(name: "Pow", package: "Pow")],
            path: "Sources/ChunUI",
            resources: [
                .process("Icons/PikaIcons.xcassets"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
    ]
)
