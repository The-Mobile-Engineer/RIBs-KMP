import UIKit

/// The navigation controller every RIB-driven push goes through. Two jobs:
///
/// 1. **Typed push.** Pushed screens *must* be `BaseViewController`s so a native pop (back button /
///    swipe / long-press menu) reports back to the RIB tree. `push(_:)` takes a `BaseViewController`,
///    and the raw `pushViewController(_:animated:)` is sealed off — so "must subclass BaseViewController
///    to be pushable" is a compile-time guarantee, not a convention.
/// 2. **Group pops.** A single back/swipe pop is caught by `BaseViewController.viewDidDisappear`; but
///    the long-press back menu (and a tab-bar double-tap) can pop several VCs at once and
///    `viewDidDisappear` isn't guaranteed for all of them — so we notify each popped one here.
public final class BaseUINavigationController: UINavigationController {

    /// The only sanctioned push. The `BaseViewController` type is what makes native-pop RIB sync safe.
    public func push(_ viewController: BaseViewController, animated: Bool = true) {
        super.pushViewController(viewController, animated: animated)
    }

    @available(*, unavailable, message: "Use push(_:animated:) — pushed VCs must be BaseViewController for RIB sync")
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }

    @discardableResult
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let popped = super.popToRootViewController(animated: animated)
        popped?.forEach { ($0 as? BaseViewController)?.viewDidClose() }
        return popped
    }

    @discardableResult
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // Order matters: the array is parent→child, so closing the topmost ancestor first cascades
        // the RIB detach through its children (route-away is idempotent, so extra calls are no-ops).
        let popped = super.popToViewController(viewController, animated: animated)
        popped?.forEach { ($0 as? BaseViewController)?.viewDidClose() }
        return popped
    }
}
