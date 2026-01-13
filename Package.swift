// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Gayish",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Gayish",
            targets: ["Gayish"]
        ),
    ],
    targets: [
        .target(
            name: "Gayish",
            path: "GayishApp"
        )
    ]
)
