// swift-tools-version:5.9
import PackageDescription

/// Root SPM manifest for the ribs-kmp framework's Swift-side bridges. A single entry point so a
/// consumer adds the repo's Git URL once and picks the product they need. Sources stay grouped under
/// swift/<Pkg>/Sources/<Pkg> (the repo is polyglot — Kotlin/Gradle + Swift + web — so Swift lives
/// under swift/). Coexists with the Gradle build.
///
/// - RibsUIKit / RibsSwiftUI: framework-agnostic view helpers (no KMP, no RIBs dependency).
/// - RibsKmpRIBsiOSInterop: attach KMP RIBs as children of Uber-RIBs Swift RIBs. Depends on Uber RIBs;
///   binds to your KMP types via a small conformance you write (or `ribs ios-interop` generates).
let package = Package(
    name: "RIBs-KMP",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "RibsUIKit", targets: ["RibsUIKit"]),
        .library(name: "RibsSwiftUI", targets: ["RibsSwiftUI"]),
        .library(name: "RibsKmpRIBsiOSInterop", targets: ["RibsKmpRIBsiOSInterop"]),
    ],
    dependencies: [
        // Uber RIBs (Swift). Repoint to your fork's URL/branch if the app uses one — SPM identifies a
        // package by URL, so it must be the SAME RIBs the app links (otherwise two RIBs modules clash).
        .package(url: "https://github.com/uber/RIBs-iOS.git", branch: "main"),
    ],
    targets: [
        .target(name: "RibsUIKit", path: "swift/RibsUIKit/Sources/RibsUIKit"),
        .target(name: "RibsSwiftUI", path: "swift/RibsSwiftUI/Sources/RibsSwiftUI"),
        .target(
            name: "RibsKmpRIBsiOSInterop",
            dependencies: [.product(name: "RIBs", package: "RIBs-iOS")],
            path: "swift/RibsKmpRIBsiOSInterop/Sources/RibsKmpRIBsiOSInterop"
        ),
    ]
)
