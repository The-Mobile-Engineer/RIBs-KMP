// swift-tools-version:5.9
import PackageDescription

/// Root SPM manifest for the ribs-kmp framework's Swift-side bridges. A single entry point so a
/// consumer adds the repo's Git URL once and picks the product they need (RibsUIKit and/or
/// RibsSwiftUI). Sources stay grouped under swift/<Pkg>/Sources/<Pkg> (the repo is polyglot —
/// Kotlin/Gradle + Swift + web — so Swift lives under swift/). Coexists with the Gradle build.
let package = Package(
    name: "RIBs-KMP",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "RibsUIKit", targets: ["RibsUIKit"]),
        .library(name: "RibsSwiftUI", targets: ["RibsSwiftUI"]),
    ],
    targets: [
        .target(name: "RibsUIKit", path: "swift/RibsUIKit/Sources/RibsUIKit"),
        .target(name: "RibsSwiftUI", path: "swift/RibsSwiftUI/Sources/RibsSwiftUI"),
    ]
)
