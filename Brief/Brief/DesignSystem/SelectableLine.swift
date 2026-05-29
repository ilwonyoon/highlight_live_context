import SwiftUI

// MARK: - SelectableLine
// Wraps a brief line / bullet / block in a registration shell.
//
// At runtime, each SelectableLine reports its frame (in container-local
// coordinates) to the SelectionContext via a PreferenceKey. The container
// (SelectionSurface) reads those frames and decides which lines a drag
// gesture has covered. SelectableLine itself does NOT handle gestures —
// gestures belong to the container so a single drag can span many lines.

struct SelectableLine<Content: View>: View {
    let id: String
    let kind: SelectionContext.SelectionKind
    let text: String
    @ViewBuilder var content: () -> Content

    @EnvironmentObject private var selection: SelectionContext

    private var isSelected: Bool { selection.isActive(id) }

    var body: some View {
        content()
            .padding(.horizontal, BriefSpacing.md)
            .padding(.vertical,   BriefSpacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(isSelected ? Color.briefSelectionRest : Color.clear)
            )
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: SelectableFramePreferenceKey.self,
                        value: [
                            SelectableFrame(
                                id: id,
                                text: text,
                                kind: kind,
                                frame: geo.frame(in: .named(SelectionCoordSpace.name))
                            )
                        ]
                    )
                }
            )
            .animation(.briefHover, value: isSelected)
    }
}

// MARK: - Frame collection via PreferenceKey

struct SelectableFrame: Equatable {
    let id: String
    let text: String
    let kind: SelectionContext.SelectionKind
    let frame: CGRect
}

struct SelectableFramePreferenceKey: PreferenceKey {
    static var defaultValue: [SelectableFrame] = []
    static func reduce(value: inout [SelectableFrame], nextValue: () -> [SelectableFrame]) {
        value.append(contentsOf: nextValue())
    }
}
