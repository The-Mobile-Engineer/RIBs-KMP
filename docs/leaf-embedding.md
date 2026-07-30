# Leaf embedding (incremental adoption)

You don't have to start at the root. A self-contained RIB subtree can be mounted inside a host that
isn't a RIB at all — a legacy `UIViewController`, an `Activity`/`Fragment`, a DOM element — so you can
adopt RIBs one screen at a time. And the reverse: a legacy view can serve as a RIB's view.

This works because a RIB's view is an opaque `ViewControllable`
(no UI-toolkit type), and the framework doesn't require a `LaunchRouter`/root entry point.

## RIBs as a guest (mount a subtree at a leaf)

```kotlin
// In the legacy host:
val feature = FeatureBuilder(dependency).build()   // 1. build, supplying the Dependency yourself
feature.mount()                                     // 2. framework start: activate + load
hostView.add(feature.viewControllable as ToolkitView) // 3. place the view in the host hierarchy
// …later…
feature.unmount()                                   // tear the subtree down
hostView.remove(...)
```

- **`mount()` / `unmount()`** live in `ribs` (Embedding.kt).
  `mount()` is exactly what `LaunchRouter.launch()` does for the root (activate the interactor, load
  the router); `unmount()` is `deinit()`. Both are idempotent.
- **The host provides the scope.** Instead of a parent RIB's component, *you* construct the feature's
  `Dependency` from the legacy app's world (its services/auth, or stubs) and hand it to the `Builder`.
- **Mounting the view is the host's job** (same philosophy as `launch()`): downcast `viewControllable`
  to the toolkit's view and add it — child-VC containment (UIKit), a `ComposeView` (Android),
  `appendChild` (web).

## Legacy views inside a RIB (mix-and-match)

A pre-existing legacy view can *be* a RIB's view: have it conform to the feature's `*ViewControllable`
(or wrap it), and the RIB hosts it as an opaque island the interactor doesn't drive through a
presenter. The framework only sees `ViewControllable`.

## Reference

`LeafEmbeddingTest` (ribs/src/commonTest)
is a runnable, end-to-end version of the above: a plain (non-RIB) host builds a feature RIB via its
`Builder` + an injected `Dependency`, `mount()`s it, uses a legacy view as the RIB's view, and
`unmount()`s — asserting the lifecycle and that the injected scope flows through.
