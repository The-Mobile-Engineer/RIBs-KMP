import UIKit

/// Bridges **native** UIKit navigation (back button, edge-swipe, long-press back menu, modal
/// dismiss) back into the RIB tree. We don't fight the system: it pops/dismisses the VC as usual,
/// then `viewDidClose()` fires so the owning RIB can "catch up" and route away. The router's
/// reciprocal UI pop is nil-safe — a popped VC's `navigationController` is already `nil` — so nothing
/// double-pops. Subclasses (pushed screens) override `viewDidClose()` to notify their presenter.
open class BaseViewController: UIViewController {

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let navBeingDismissed = navigationController?.isBeingDismissed ?? false
        // True only when this VC actually left the stack (a completed pop / dismissal) — not when it
        // was merely covered by a push, and not on a cancelled swipe-back.
        if isMovingFromParent || isBeingDismissed || navBeingDismissed {
            viewDidClose()
        }
    }

    /// No-op; pushed screens override to tell their presenter the view was closed by the system.
    open func viewDidClose() {}
}
