import SwiftUI

/// Platform-side bridge: every SwiftUI view holder can vend its SwiftUI view. A parent renders a
/// child by downcasting the opaque child `ViewControllable` to this and calling `makeView()` — the
/// SwiftUI analog of UIKit's `child as? UIViewController`. No central dispatcher needed.
public protocol SwiftUIRenderable: AnyObject {
    func makeView() -> AnyView
}
