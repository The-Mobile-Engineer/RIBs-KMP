# Consuming RIBs-KMP

RIBs-KMP is one repo that ships as several packages across three package managers. This is the map of
which package a dev wires up, for which platform, and when.

## The one rule

Two kinds of code travel through two kinds of package manager, and a single app often uses both:

- **Anything written in Kotlin** — `ribs`, `ribs-compose`, *and your own shared logic / RIBs
  tree* — is consumed via **Maven**, inside the Gradle build. It is never added to Xcode or npm
  directly.
- **Native-language view bridges** are consumed via *that language's* manager, inside *that
  platform's* native project:
  - Swift bridges (`RibsUIKit`, `RibsSwiftUI`) → **SPM**, in Xcode.
  - Web glue (`ribs-web`) → **npm**, in the JS/TS frontend.

The shared Kotlin is then *delivered* to each platform as that platform's native artifact,
automatically by Gradle: **Android → AAR**, **iOS/macOS → an `.xcframework`** built from your shared
module, **web → a JS bundle**, **desktop/server → a jar**.

The part that trips people up: **on iOS you never add `ribs` to Xcode.** Your own shared Kotlin
module depends on `ribs` (via Maven); Gradle compiles that whole module — `ribs` baked in —
into a framework, and Xcode embeds *that*. Only the pure-Swift bridges come in through SPM. So an iOS
app uses Maven **and** SPM, for two different layers.

## Package → channel → coordinate

| Package | Language | Channel | Coordinate |
|---|---|---|---|
| `ribs` | Kotlin (all targets: JVM, Android, iOS/macOS, mingw, JS) | Maven | `io.mobileengineer:ribs` |
| `ribs-compose` | Kotlin (JVM, Android, iOS) | Maven | `io.mobileengineer:ribs-compose` |
| `RibsUIKit` | Swift (pure) | SPM | `github.com/The-Mobile-Engineer/RIBs-KMP` → product `RibsUIKit` |
| `RibsSwiftUI` | Swift (pure) | SPM | `github.com/The-Mobile-Engineer/RIBs-KMP` → product `RibsSwiftUI` |
| `ribs-web` | TS | npm | `@mobileengineer/ribs-web` |

Note the Maven publication of `ribs` already includes the **Android AAR** and the **Kotlin/JS
klib** — Android and JS are not separate channels, they ride inside the one Maven push.

## By app shape

### KMP app with Compose UI (Android / Desktop / iOS-via-Compose)

Pure Gradle — only Maven.

`settings.gradle.kts`:
```kotlin
dependencyResolutionManagement {
    repositories { mavenCentral(); google() }   // + the private repo below while pre-release
}
```
Shared module `build.gradle.kts`:
```kotlin
commonMain.dependencies {
    implementation("io.mobileengineer:ribs:0.1.0")     // the framework + your RIBs tree
    implementation("io.mobileengineer:ribs-compose:0.1.0")  // only because the UI is Compose
}
```
`ribs` for the architecture; `ribs-compose` because the UI renders with Compose. The Android AAR
and desktop jar are selected per target automatically.

### KMP app with native iOS UI (UIKit / SwiftUI)

Two managers, two layers.

1. The shared Kotlin module (your business logic + RIBs tree) — Maven, `ribs` in `commonMain`,
   exactly as above. Gradle builds it into an `.xcframework`.
2. In Xcode, the Swift app adds the Swift bridges via SPM:
```swift
dependencies: [
    .package(url: "https://github.com/The-Mobile-Engineer/RIBs-KMP.git", from: "0.1.0")
],
targets: [.target(name: "MyApp", dependencies: [
    .product(name: "RibsUIKit", package: "RIBs-KMP"),
    .product(name: "RibsSwiftUI", package: "RIBs-KMP"),
])]
```

Swift now has `BaseViewController` / `SwiftUIRenderable` to implement the view interfaces the Kotlin
side defines via DI. `ribs` rode in through the framework; SPM only brought the native bridges.
The bridges have **no Kotlin dependency**, so a pure-UIKit/SwiftUI project can add them on their own.

How the `.xcframework` itself reaches Xcode is a separate choice about *your* shared module (direct
embed, CocoaPods, or KMMBridge to make it an SPM dependency too) — it is not about `ribs`.

### Web frontend (TS / React)

npm only:
```
npm install @mobileengineer/ribs-web
```
Your shared Kotlin (if any) compiles to a JS bundle via Kotlin/JS; `ribs-web` is the TS interop glue
over those exports.

## Order a consumer wires it up

1. Create the shared Kotlin module → add `ribs` (Maven). Build the RIBs tree.
2. For each UI shipped, add the matching package:
   - Compose UI → `ribs-compose` (Maven).
   - Native iOS → `RibsUIKit` / `RibsSwiftUI` (SPM, in Xcode).
   - Web → `ribs-web` (npm).
3. Embed the shared framework into each native app shell (AAR is automatic; iOS `.xcframework`; JS
   bundle).

For adopting one screen at a time inside a non-RIBs host, see [`leaf-embedding.md`](leaf-embedding.md).

## No auth required

RIBs-KMP is public and free — no account, token, or repo access:

- **Maven Central** → `io.mobileengineer:ribs` / `ribs-compose`, resolved anonymously via
  `mavenCentral()`.
- **SPM** (`RibsUIKit` / `RibsSwiftUI`) → a binary Swift package from this repo (public), no
  credentials. *(Public XCFramework release in progress.)*
- **npm** (`@mobileengineer/ribs-web`) → public npm. *(Planned.)*

The framework source stays private; you consume compiled, binary artifacts.
