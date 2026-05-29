import SwiftUI

// MARK: - Selection context
// Holds the currently-selected line/block ID and its selected text.
// Only one selection exists at a time across the Brief surface. Drives:
//   - the selected line's visual state (highlighted background)
//   - the floating chat composer beside it
//
// Use an ObservableObject in the Brief root and pass it via EnvironmentObject.

@MainActor
final class SelectionContext: ObservableObject {
    @Published private(set) var selectedIDs: Set<String> = []
    @Published private(set) var registry: [String: SelectableInfo] = [:]

    enum SelectionKind {
        case line   // single sentence / bullet
        case block  // a meaningful section / card
    }

    struct SelectableInfo {
        var id: String
        var text: String
        var kind: SelectionKind
        var frame: CGRect      // in container-local coordinates
    }

    // MARK: - Registration (called by SelectableLine.onAppear / .preference)

    func register(id: String, text: String, kind: SelectionKind, frame: CGRect) {
        var info = registry[id] ?? SelectableInfo(id: id, text: text, kind: kind, frame: .zero)
        info.text = text
        info.kind = kind
        info.frame = frame
        registry[id] = info
    }

    func unregister(id: String) {
        registry[id] = nil
        selectedIDs.remove(id)
    }

    // MARK: - Selection mutation

    func toggle(_ id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    func setSelection(to ids: Set<String>) {
        selectedIDs = ids
    }

    func clear() {
        selectedIDs.removeAll()
    }

    // MARK: - Drag-based selection
    // Selects every registered line whose frame intersects the rect.

    func selectRect(_ rect: CGRect) {
        let ids = registry.values
            .filter { $0.frame.intersects(rect) }
            .map(\.id)
        selectedIDs = Set(ids)
    }

    // MARK: - Queries

    func isActive(_ id: String) -> Bool { selectedIDs.contains(id) }

    /// Concatenated text of all currently-selected lines, in document order
    /// (sorted by frame.minY).
    var selectedText: String {
        let infos = registry.values
            .filter { selectedIDs.contains($0.id) }
            .sorted { $0.frame.minY < $1.frame.minY }
        return infos.map(\.text).joined(separator: "\n")
    }

    /// The bottom-rightmost selected frame — used to position the floating
    /// ChatComposer beside the selection.
    var anchorFrame: CGRect? {
        let frames = registry.values
            .filter { selectedIDs.contains($0.id) }
            .map(\.frame)
        return frames.isEmpty ? nil : frames.reduce(frames[0]) { $0.union($1) }
    }
}
