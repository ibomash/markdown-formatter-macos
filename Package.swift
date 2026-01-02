// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownHeadingAdjuster",
    products: [
        .library(name: "HeadingCore", targets: ["HeadingCore"]),
        .executable(name: "heading-cli", targets: ["HeadingCLI"])
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
        .testTarget(
            name: "HeadingCoreTests",
            dependencies: ["HeadingCore"],
            path: "Tests/HeadingCoreTests"
        )
    ]
)
