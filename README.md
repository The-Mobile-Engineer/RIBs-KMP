# RIBs-KMP

An imperative RIBs-style ([RIBs](https://github.com/uber/RIBs) · [RIBs-iOS](https://github.com/uber/RIBs-iOS))
architecture framework for **Kotlin Multiplatform** — Router / Interactor / Builder / Presenter + View, with a coroutine-based `Workflow`
engine for deep-link and cross-tree navigation.

**Free**, and on Maven Central — one dependency gives you the framework on **Android, iOS, macOS,
desktop/JVM, and web**.

> ⚠️ **Beta (`0.x`).** The API is still stabilizing — expect breaking changes between releases until
> `1.0`. Pin an exact version and check the release notes before upgrading.

> Inspired by Uber's RIBs, independently reimplemented and substantially extended for Kotlin
> Multiplatform. Not affiliated with or endorsed by Uber. See [THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES.md).

## Install

### Kotlin / Android / KMP

`mavenCentral()` is already in most projects. Add the dependency to your shared module (`commonMain`):

```kotlin
commonMain.dependencies {
    implementation("io.mobileengineer:ribs:0.1.0")          // the framework
    implementation("io.mobileengineer:ribs-compose:0.1.0")  // only if you render with Compose
}
```

That one coordinate covers **Android (AAR), JVM/desktop, iOS, macOS, and JS** — Gradle picks the
right target automatically. Imports are `com.ribs.*`:

```kotlin
import com.ribs.Router
import com.ribs.Interactor
```

Browse the artifact: <https://central.sonatype.com/artifact/io.mobileengineer/ribs>

### iOS / macOS (native UIKit / SwiftUI / AppKit)

Two layers, as in any KMP + native app:

1. **Shared logic** — your shared Kotlin module depends on `ribs` from Maven Central (above); your
   Gradle build compiles it into the framework Xcode embeds. You do *not* add `ribs` to Xcode
   directly.
2. **Native view bridges** (`RibsUIKit` / `RibsSwiftUI`) — a Swift package. In Xcode: **File → Add
   Package Dependencies** → `https://github.com/The-Mobile-Engineer/RIBs-KMP` → pick `RibsUIKit`
   and/or `RibsSwiftUI`. Or in `Package.swift`:

   ```swift
   .package(url: "https://github.com/The-Mobile-Engineer/RIBs-KMP.git", from: "0.1.0")
   ```

   These are pure Swift (no Kotlin dependency); you implement the KMP-defined view interfaces against
   them via DI.

## Scaffolding CLI

`ribs` is a small native CLI (no JVM) that generates a RIB — Builder / Router / Interactor /
Presenter / View, one class per file, matching the framework conventions.

Install (macOS + Linux):

```sh
curl -fsSL https://raw.githubusercontent.com/The-Mobile-Engineer/RIBs-KMP/main/install.sh | sh
```

Then, from inside your source tree:

```sh
ribs new Foo
```

It infers the package from the current directory (override with `--package` / `--dir`) and writes a
`foo/` folder with the six files ready to fill in.

## Platforms

| Platform | How you consume it |
|---|---|
| Android | `io.mobileengineer:ribs` (AAR) from Maven Central |
| JVM / Desktop | `io.mobileengineer:ribs` (jar) from Maven Central |
| iOS / macOS (Kotlin) | `io.mobileengineer:ribs` (klib) from Maven Central |
| iOS / macOS (native views) | `RibsUIKit` / `RibsSwiftUI` Swift package (SPM, this repo) |
| Web (JS/TS) | `@mobileengineer/ribs-web` on npm *(planned)* |

## Docs

- [Consuming guide](docs/consuming.md) — which package for which target, and when.
- [Leaf embedding](docs/leaf-embedding.md) — adopt one screen at a time inside a non-RIBs host.

## License

Free to use — see [LICENSE](LICENSE). Includes components derived from Uber's RIBs (Apache-2.0); see
[THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES.md).
