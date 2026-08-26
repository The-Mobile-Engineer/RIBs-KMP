import UIKit
import RIBs

// MARK: - The abstraction the consumer binds their KMP RIB to
//
// This package depends ONLY on Uber RIBs. It never names your KMP framework/umbrella module — instead
// you conform your KMP router + interactable to the two protocols below (a ~10-line file; `ribs
// ios-interop` generates it). That keeps this package reusable across any app, with no dependency on
// your Kotlin core and no second Kotlin runtime.

/// What the adapter needs from a KMP interactable — its lifecycle verbs.
public protocol KmpInteropInteractable: AnyObject {
    func activate()
    func deactivate()
}

/// What the adapter needs from a KMP RIB's router.
public protocol KmpInteropRouting: AnyObject {
    /// The KMP RIB's interactable, bound to [KmpInteropInteractable].
    var interop: KmpInteropInteractable { get }
    /// The KMP RIB's view as a UIViewController (downcast from `RouterView` in your conformance).
    var viewController: UIViewController { get }
    /// The KMP router's `load()`.
    func load()
    /// Full KMP teardown — the KMP `unmount()` / `Routing.deinit()`.
    func teardown()
}

// MARK: - Bridges (internal)

/// Presents the KMP interactable as an Uber `Interactable` by subclassing Uber's `Interactor` — which
/// gives us `isActive` / `isActiveStream` for free — and forwarding the lifecycle to KMP.
final class KmpInteractorBridge: Interactor {
    private let kmp: KmpInteropInteractable
    init(_ kmp: KmpInteropInteractable) {
        self.kmp = kmp
        super.init()
    }
    override func didBecomeActive() {
        super.didBecomeActive()
        kmp.activate()
    }
    override func willResignActive() {
        kmp.deactivate()
        super.willResignActive()
    }
}

/// Wraps the KMP RIB's UIViewController as an Uber `ViewControllable`.
final class KmpViewControllable: ViewControllable {
    let uiviewController: UIViewController
    init(_ uiviewController: UIViewController) { self.uiviewController = uiviewController }
}

// MARK: - The adapter: a KMP RIB as a real Swift RIB child

/// Makes a KMP RIB look like an Uber `ViewableRouting`, so a Swift parent can `attachChild` /
/// `detachChild` it exactly like any Swift child. Subclasses Uber's `ViewableRouter`, so the tree
/// machinery (children, load, lifecycle, subtree active-state) is Uber's; we only bind the KMP RIB.
///
/// The leak fix: because the wrapper lives in the parent's `children`, the parent's `Router.deinit`
/// (`detachAllChildren`) releases it, and this `deinit` runs `teardown()` — the KMP subtree detaches,
/// scopes cancel, memory reclaims. No manual `mount`/`unmount` in app code.
public final class KmpRIBAdapter: ViewableRouter<Interactor, ViewControllable> {

    private let kmp: KmpInteropRouting

    public init(_ kmp: KmpInteropRouting) {
        self.kmp = kmp
        super.init(
            interactor: KmpInteractorBridge(kmp.interop),
            viewController: KmpViewControllable(kmp.viewController)
        )
    }

    // Uber's `attachChild` does `interactable.activate()` (→ KMP activate) then `load()`; hook `didLoad`
    // (Uber's `load()` is final) to load the KMP router.
    public override func didLoad() {
        super.didLoad()
        kmp.load()
    }

    deinit {
        kmp.teardown()
    }
}

// MARK: - Ergonomics

public extension Routing {
    /// Attach a KMP RIB as a child, exactly like a Swift child. Returns the wrapper so you can
    /// `detachChild(_:)` it and present its `viewControllable`.
    @discardableResult
    func attachKmpChild(_ kmp: KmpInteropRouting) -> ViewableRouting {
        let child = KmpRIBAdapter(kmp)
        attachChild(child)
        return child
    }
}
