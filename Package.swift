// swift-tools-version: 6.0
import PackageDescription

let lexlightVersion = "1.0.0"

let package = Package(
    name: "Lexlight",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Lexlight",
            targets: ["Lexlight"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Lexlight",
            resources: [
                .process("Resources"),
                .process("Lexlight.docc"),
            ]
        ),
        .testTarget(
            name: "LexlightTests",
            dependencies: ["Lexlight"]
        ),
        .executableTarget(
            name: "LexlightDemo",
            dependencies: ["Lexlight"],
            path: "Examples/LexlightDemo/Sources/LexlightDemo"
        ),
    ],
    swiftLanguageModes: [.v6]
)
