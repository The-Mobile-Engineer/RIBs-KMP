# RibsKmpRIBsiOSInterop

Attach a **KMP RIB** (built with ribs-kmp) as a real child of an **Uber-RIBs Swift** RIB — so it
rides the Swift parent's `attachChild`/`detachChild` lifecycle instead of a manual `mount`/`unmount`
that leaks when the parent tears down.

This package depends only on Uber RIBs. It never names your KMP framework; you bind your KMP types to
its abstraction with a small conformance (generated for you).

## Setup

1. Add this package and Uber RIBs to your app. (If your app uses a RIBs fork, repoint the `RIBs`
   dependency in this repo's `Package.swift` to the same fork — SPM must resolve the *same* RIBs the
   app links.)

2. Generate the conformance that binds your KMP core types to the abstraction:

   ```sh
   ribs ios-interop --module <YourKmpUmbrella>   # e.g. RibsApp
   ```

   Add the generated `RibsKmpInteropConformance.swift` to the target that links both your KMP umbrella
   and `RibsKmpRIBsiOSInterop`. (It's ~10 lines; check the `viewController` cast matches your view
   bridge.)

## Use

In a Swift parent router, route to a KMP RIB the same way you route to a Swift one:

```swift
func routeToPayments() {
    let kmp = paymentsBuilder.build(withListener: interactor)   // your KMP builder, as today
    let child = attachKmpChild(kmp)                             // ← the only new line vs a Swift child
    viewController.present(child.viewControllable)
    payments = child
}

func detachPayments() {
    guard let child = payments else { return }
    detachChild(child)
    viewController.dismiss(child.viewControllable)
    payments = nil
}
```

If the parent is detached or deallocated without an explicit `detachChild`, the KMP subtree still tears
down: it lives in the parent's `children`, so Uber's `Router.deinit` → `detachAllChildren` releases the
wrapper, whose `deinit` runs the KMP `teardown()`. No leak.

`mount`/`unmount` remain only for embedding into a genuine non-RIB host.
