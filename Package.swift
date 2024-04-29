// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SwiftCopyfile",
    platforms: [
        .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftCopyfile",
            targets: ["SwiftCopyfile", "CCopyfile"]),
    ],
    targets: [
        .target(
            name: "SwiftCopyfile",
            dependencies: ["CCopyfile"]),
        .target(
            name: "CCopyfile"),
        .testTarget(
            name: "SwiftCopyfileTests",
            dependencies: ["SwiftCopyfile"]),
    ]
)
