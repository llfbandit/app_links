// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "app_links",
    platforms: [
       .iOS("12.0")
    ],
    products: [
        // library and target names.
        // If the plugin name contains "_", replace with "-" for the library name.
        .library(name: "app-links", targets: ["app_links"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "app_links",
            dependencies: [],
            resources: [
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)