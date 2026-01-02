// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownHeadingAdjuster",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "HeadingCore", targets: ["HeadingCore"]),
        .library(name: "HeadingCLIKit", targets: ["HeadingCLIKit"]),
        .executable(name: "heading-cli", targets: ["HeadingCLI"]),
        .executable(name: "HeadingApp", targets: ["HeadingApp"])
    ],
    targets: [
        .target(
            name: "HeadingCore",
            path: "Sources/HeadingCore"
        ),
        .target(
            name: "HeadingCLIKit",
            dependencies: ["HeadingCore"],
            path: "Sources/HeadingCLIKit"
        ),
        .executableTarget(
            name: "HeadingCLI",
            dependencies: ["HeadingCLIKit"],
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
        ),
        .testTarget(
            name: "HeadingCLIKitTests",
            dependencies: ["HeadingCLIKit"],
            path: "Tests/HeadingCLIKitTests"
        )
    ]
)
