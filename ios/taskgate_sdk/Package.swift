// swift-tools-version: 5.9
// Swift Package Manager support for apps that don't use CocoaPods (Flutter
// picks this or the podspec). Keep the native SDK version in step with the
// podspec's TaskGateSDK dependency.

import PackageDescription

let package = Package(
    name: "taskgate_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "taskgate-sdk", targets: ["taskgate_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/task-gate/taskgate-sdk-ios.git", from: "1.0.7")
    ],
    targets: [
        .target(
            name: "taskgate_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TaskGateSDK", package: "taskgate-sdk-ios")
            ]
        )
    ]
)
