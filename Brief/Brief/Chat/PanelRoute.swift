import Foundation

// MARK: - PanelRoute — the chat panel's navigation vocabulary
//
// The panel is a navigation STACK, not a single screen. A route enum drives
// which screen is shown; the header reflects the current route's title; the back
// chevron pops. Routes are panel-generic — detail titles come from the
// scenario's PanelDestination, never hardcoded.
//
// See PRIVACY_EXECUTION.md §3.1.

enum PanelRoute: Equatable {
    /// The root: the scenario's opening turns + the live thread + the composer.
    case conversation
    /// A scenario-supplied drill-in. The title/card are looked up from the
    /// scenario's `detailDestinations()` by this id.
    case detail(destinationID: UUID)
}

// MARK: Stack — push/pop over a route array
//
// Kept as a tiny value type so the panel host owns `@State private var nav` and
// the back affordance is simply "is the stack deeper than its root".

struct PanelNavStack: Equatable {
    private(set) var routes: [PanelRoute] = [.conversation]

    var current: PanelRoute { routes.last ?? .conversation }
    var canGoBack: Bool { routes.count > 1 }

    mutating func push(_ route: PanelRoute) { routes.append(route) }

    mutating func pop() {
        guard routes.count > 1 else { return }
        routes.removeLast()
    }

    /// Reset to the root — used when the panel is dismissed so it reopens fresh.
    mutating func reset() { routes = [.conversation] }
}
