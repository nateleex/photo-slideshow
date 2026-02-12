// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PhotoSlideshow",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "PhotoSlideshow",
            path: "Sources/PhotoSlideshow",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("Photos"),
            ]
        )
    ]
)
