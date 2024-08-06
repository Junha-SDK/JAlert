// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JAlert",
    platforms: [
        .iOS(.v15) // Specifies that this package is intended to be used on iOS, with a minimum deployment target of iOS 15.
    ],
    products: [
        // Products define the executables and libraries produced by a package.
        .library(
            name: "JAlert",
            targets: ["JAlert"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // Here we're depending on three external packages.
        .package(url: "https://github.com/Junha-SDK/JUtile", from: "0.0.2"),
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. They can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "JAlert",
            dependencies: [
                "JUtile", // Assuming this is needed directly by JAlert
                "Then",   // Assuming this is needed directly by JAlert
                "SnapKit" // Assuming this is needed directly by JAlert
            ],
            path: "Sources/JAlert" // Specifies that the source files for the target `JAlert` are located in `Sources/JAlert`
        ),
        .testTarget(
            name: "JAlertTests",
            dependencies: ["JAlert"],
            path: "Tests/JAlertTests" // Specifies that the test source files are located in `Tests/JAlertTests`
        )
    ]
)
