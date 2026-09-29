// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TemplateAPI",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "TemplateAPI", targets: ["TemplateAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types", exact: "1.8.0"),
    ],
    targets: [
        .target(
            name: "HTTPClient",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ],
        ),
        .target(name: "SafeDecoding"),
        .target(
            name: "TemplateAPI",
            dependencies: ["HTTPClient", "SafeDecoding"],
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: [
                "HTTPClient",
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
        ),
        .testTarget(name: "SafeDecodingTests", dependencies: ["SafeDecoding"]),
        .testTarget(name: "TemplateAPITests", dependencies: ["TemplateAPI"]),
    ],
    swiftLanguageModes: [.v6],
)
