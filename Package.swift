// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FakeSwiftUI",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "FakeSwiftUI",
            targets: ["FakeSwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/dexterliu1214/RxBinding.git", .branch("master")),
        .package(url: "https://github.com/RxSwiftCommunity/RxAnimated.git", from: "0.8.1"),
		.package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", .exact("3.0.2")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "4.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FakeSwiftUI",
            dependencies: [
                "RxSwift",
				.product(name: "RxCocoa", package: "RxSwift"),
                "RxBinding",
                "RxAnimated",
                "RxGesture",
                "RxDataSources",
            ]),
		.testTarget(
			name: "FakeSwiftUITests",
			dependencies: ["FakeSwiftUI"]),
    ]
)
