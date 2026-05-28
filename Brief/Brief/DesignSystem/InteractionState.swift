import SwiftUI

// MARK: - Interaction state
// Single source of truth for the four states every interactive Brief element
// goes through. Use `InteractionState` to drive styling instead of bundling
// loose @State Bool flags in every view.

enum InteractionState: Equatable {
    case rest
    case hover
    case pressed
    case disabled

    var isHighlighted: Bool { self == .hover || self == .pressed }
}

// MARK: - DelayedHover modifier (with named tokens)
// Tracks hover and flips `triggered` after on/off delays. Off-delay lets the
// cursor cross into a popover without losing the trigger.

struct DelayedHover: ViewModifier {
    let onDelay: Double
    let offDelay: Double
    @Binding var triggered: Bool
    @State private var task: Task<Void, Never>? = nil

    func body(content: Content) -> some View {
        content.onHover { isHovering in
            task?.cancel()
            let delay = isHovering ? onDelay : offDelay
            let nanos = UInt64(delay * 1_000_000_000)
            task = Task {
                try? await Task.sleep(nanoseconds: nanos)
                if !Task.isCancelled {
                    await MainActor.run { triggered = isHovering }
                }
            }
        }
    }
}

extension View {
    /// Set `triggered` true after `on` seconds of continuous hover,
    /// false after `off` seconds when hover ends.
    /// Defaults match the Brief interaction system.
    func delayedHover(
        on: Double = BriefDelay.hoverOn,
        off: Double = BriefDelay.hoverOff,
        triggered: Binding<Bool>
    ) -> some View {
        modifier(DelayedHover(onDelay: on, offDelay: off, triggered: triggered))
    }
}

// MARK: - Pressable + Hoverable container
// Wraps content in a Button whose ButtonStyle exposes the live
// InteractionState. The closure receives `state` and renders accordingly.

struct InteractiveSurface<Content: View>: View {
    var onActivate: () -> Void = {}
    @State private var hovering = false
    @ViewBuilder var content: (InteractionState) -> Content

    var body: some View {
        // Empty Button label — the real content is rendered inside the
        // ButtonStyle so it can read the pressed state.
        Button(action: onActivate) { Color.clear }
            .buttonStyle(_StateForwardingStyle(hovering: hovering, content: content))
            .onHover { hovering = $0 }
    }
}

/// ButtonStyle that renders the supplied content with the current
/// (pressed-aware) InteractionState.
private struct _StateForwardingStyle<Content: View>: ButtonStyle {
    let hovering: Bool
    @ViewBuilder let content: (InteractionState) -> Content

    func makeBody(configuration: Configuration) -> some View {
        let state: InteractionState = {
            if configuration.isPressed { return .pressed }
            if hovering { return .hover }
            return .rest
        }()
        return content(state)
            .contentShape(Rectangle())
    }
}
