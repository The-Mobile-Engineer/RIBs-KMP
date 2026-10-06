# RibsKmpRIBsiOSInterop

Attach a **KMP RIB** (built with ribs-kmp) as a real child of an **Uber-RIBs Swift** RIB — so it
rides the Swift parent's `attachChild`/`detachChild` lifecycle instead of a manual `mount`/`unmount`
that leaks when the parent tears down.

This package depends only on Uber RIBs. It never names your KMP framework; you bind your KMP types to
its abstraction with a small conformance (generated for you).

## Setup

1. Add this package and Uber RIBs to your app. (If your app uses a RIBs fork, repoint the `RIBs`
   dependency in this repo's `Package.swift` to the same fork, by the same URL — SPM resolves one
   checkout per URL, and the app and this package must link the *same* RIBs module.)

2. Supply your KMP RIB's view natively in Swift. A KMP view is toolkit-agnostic: implement the RIB's
   generated view interface with a Swift `UIViewController` and inject its factory through the RIB's
   dependency. Do not render UIKit from Kotlin — a Kotlin/Native class can't subclass `UIViewController`
   and implement a Kotlin interface in the same class.

   ```swift
   final class PaymentsViewController: UIViewController, PaymentsView { /* render(...), delegate */ }

   final class PaymentsViewFactoryImpl: NSObject, PaymentsViewFactory {
       func create() -> any View { PaymentsViewController() }   // create() erases to the base View
   }
   ```

3. Generate the conformance that binds your KMP core types to the abstraction:

   ```sh
   ribs ios-interop --module <YourKmpUmbrella>   # e.g. RibsApp
   ```

   Add the generated `RibsKmpInteropConformance.swift` to the target that links both your KMP umbrella
   and `RibsKmpRIBsiOSInterop`. It's a couple of small concrete wrapper boxes (not protocol extensions),
   so it compiles on Swift 5 and Swift 6.

## Use

In a Swift parent router, route to a KMP RIB the same way you route to a Swift one — the interactor
drives the routing, the router implements it:

```swift
func routeToPayments() {
    let kmp = paymentsBuilder.build(listener: interactor)              // your KMP builder
    let child = attachKmpChild(KmpInteropRoutingBox(kmp))              // wrap + attach as a real child
    viewController.uiviewController.present(child.viewControllable.uiviewController, animated: true)
    payments = child
}

func detachPayments() {
    guard let child = payments else { return }
    child.viewControllable.uiviewController.dismiss(animated: true)
    detachChild(child)
    payments = nil
}
```

If the parent is detached or deallocated without an explicit `detachChild`, the KMP subtree still tears
down: it lives in the parent's `children`, so Uber's `Router.deinit` → `detachAllChildren` releases the
wrapper, whose `deinit` runs the KMP `teardown()`. No leak.

`mount`/`unmount` remain only for embedding into a genuine non-RIB host.
