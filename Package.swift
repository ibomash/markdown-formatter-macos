// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownHeadingAdjuster",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "HeadingCore", targets: ["HeadingCore"]),
        .executable(name: "heading-cli", targets: ["HeadingCLI"]),
        .executable(name: "HeadingApp", targets: ["HeadingApp"])
    ],
    targets: [
        .target(
            name: "HeadingCore",
            path: "Sources/HeadingCore"
        ),
        .executableTarget(
            name: "HeadingCLI",
            dependencies: ["HeadingCore"],
            path: "Sources/HeadingCLI"
        ),
        .executableTarget(
            name: "HeadingApp",
            dependencies: ["HeadingCore"],
            path: "App/HeadingApp"
        ),
        .testTarget(
            name: "HeadingCoreTests",
            dependencies: ["HeadingCore"],
            path: "Tests/HeadingCoreTests",
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
