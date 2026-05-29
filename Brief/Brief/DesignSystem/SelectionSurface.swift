import SwiftUI

// MARK: - SelectionSurface
// The container that owns the drag gesture and the floating ChatComposer.
// Wrap any group of SelectableLine views in this surface.
//
// Behavior:
//   - drag inside the surface (anywhere) → rubber-band selection across lines
//   - cursor passes over a line's frame → that line is added to selection
//   - drag release → selection is locked; ChatComposer appears at the
//     bottom-trailing edge of the union frame
//   - click on empty surface area or outside → clears selection

/// Shared coordinate-space name for SelectionSurface drag tracking.
enum SelectionCoordSpace {
    static let name = "SelectionSurface"
}

struct SelectionSurface<Content: View>: View {

    @EnvironmentObject private var selection: SelectionContext
    @State private var dragStart: CGPoint? = nil
    @State private var dragCurrent: CGPoint? = nil

    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Content + frame collection
            content()
                .onPreferenceChange(SelectableFramePreferenceKey.self) { frames in
                    Task { @MainActor in
                        // Refresh registry from the latest frames.
                        // Stale entries (lines that no longer report) are
                        // intentionally not cleaned here — re-runs are cheap.
                        for f in frames {
                            selection.register(id: f.id, text: f.text, kind: f.kind, frame: f.frame)
                        }
                    }
                }

            // Rubber-band rectangle while dragging — warm gray, tuned to
            // the paper foundation. Matches the selected-line fill so the
            // brand highlight color is reserved for AI-marked content.
            if let rect = dragRect {
                Rectangle()
                    .fill(Color.briefSelectionRest)
                    .overlay(
                        Rectangle()
                            .stroke(Color.briefSelectionHover, lineWidth: 1)
                    )
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                    .allowsHitTesting(false)
            }

            // Floating composer at bottom-trailing of selection
            if !selection.selectedIDs.isEmpty, let anchor = selection.anchorFrame {
                ChatComposer(seedText: selection.selectedText)
                    .offset(x: anchor.maxX + BriefSpacing.md,
                            y: anchor.minY)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .coordinateSpace(name: SelectionCoordSpace.name)
        .contentShape(Rectangle())
        // Tap on empty surface clears selection
        .onTapGesture {
            selection.clear()
        }
        // Drag — rubber-band selection
        .gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .named(SelectionCoordSpace.name))
                .onChanged { value in
                    if dragStart == nil { dragStart = value.startLocation }
                    dragCurrent = value.location
                    if let rect = dragRect {
                        selection.selectRect(rect)
                    }
                }
                .onEnded { _ in
                    dragStart = nil
                    dragCurrent = nil
                }
        )
        .animation(.briefHover, value: selection.selectedIDs)
    }

    private var dragRect: CGRect? {
        guard let s = dragStart, let c = dragCurrent else { return nil }
        let x = min(s.x, c.x)
        let y = min(s.y, c.y)
        let w = abs(c.x - s.x)
        let h = abs(c.y - s.y)
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
