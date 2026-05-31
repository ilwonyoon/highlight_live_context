import Foundation
import Combine

// MARK: - PrivacyStore — single source of truth for all privacy state
//
// Both PrivacySettingsView (manual editing) and the chat panel (natural language
// editing) observe and mutate this store. The store enforces invariants so callers
// can't accidentally touch automatic (non-editable) filters.

final class PrivacyStore: ObservableObject {
    @Published var userFilters: [PrivacyFilter]
    @Published var capture: CaptureSettings
    @Published var newlyAddedID: UUID?
    let automaticFilters: [PrivacyFilter]   // transparency-only, never mutated

    init(
        userFilters: [PrivacyFilter] = PrivacyFilter.userMock,
        automaticFilters: [PrivacyFilter] = PrivacyFilter.automaticMock,
        capture: CaptureSettings = .dani
    ) {
        self.userFilters = userFilters
        self.automaticFilters = automaticFilters
        self.capture = capture
    }

    // MARK: - Add

    @discardableResult
    func addAppSite(statement: String = "Never capture these apps & sites") -> UUID {
        let f = PrivacyFilter(statement: statement, tags: [],
                              duration: .permanent, filteredCount: 0,
                              editable: true, layer: .appSite)
        userFilters.append(f)
        newlyAddedID = f.id
        return f.id
    }

    @discardableResult
    func addTopicFilter(statement: String = "") -> UUID {
        let f = PrivacyFilter(statement: statement, tags: [],
                              duration: .permanent, filteredCount: 0,
                              editable: true, layer: .topicKeyword)
        userFilters.insert(f, at: 0)
        newlyAddedID = f.id
        return f.id
    }

    func addTag(_ label: String, to filterID: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == filterID }),
              userFilters[idx].editable else { return }
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        userFilters[idx].tags.append(FilterTag(label: trimmed, count: 0))
    }

    // Convenience: find the first .appSite block and add a tag to it
    func addAppSiteTag(_ label: String) {
        if let existing = userFilters.first(where: { $0.layer == .appSite }) {
            addTag(label, to: existing.id)
        } else {
            let id = addAppSite()
            addTag(label, to: id)
        }
    }

    // MARK: - Remove

    func removeFilter(id: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == id }),
              userFilters[idx].editable else { return }
        userFilters.remove(at: idx)
    }

    func removeTag(_ tagID: UUID, from filterID: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == filterID }),
              userFilters[idx].editable else { return }
        userFilters[idx].tags.removeAll { $0.id == tagID }
    }

    // MARK: - Update

    func updateStatement(_ text: String, for filterID: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == filterID }),
              userFilters[idx].editable else { return }
        userFilters[idx].statement = text
    }

    func updateDuration(_ duration: FilterDuration, for filterID: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == filterID }),
              userFilters[idx].editable else { return }
        userFilters[idx].duration = duration
    }

    // MARK: - Pause / resume

    func pauseFilter(id: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == id }),
              userFilters[idx].editable else { return }
        userFilters[idx].active = false
    }

    func resumeFilter(id: UUID) {
        guard let idx = userFilters.firstIndex(where: { $0.id == id }) else { return }
        userFilters[idx].active = true
    }

    // MARK: - Capture toggles

    func setScreenContext(_ on: Bool)  { capture.screenContext = on }
    func setSecureCapture(_ on: Bool)  { capture.secureCapture = on }
    func setTelemetry(_ on: Bool)      { capture.telemetry = on }

    // MARK: - Lookup helpers (for parser name→id resolution)

    func filter(named name: String) -> PrivacyFilter? {
        let q = name.lowercased()
        return userFilters.first { $0.statement.lowercased().contains(q) }
    }

    func appSiteBlock() -> PrivacyFilter? {
        userFilters.first { $0.layer == .appSite }
    }

    // MARK: - Intent application

    @discardableResult
    func apply(_ intent: PrivacyIntent) -> PrivacyActionResult {
        switch intent {
        case .addAppSite(let name):
            addAppSiteTag(name)
            return PrivacyActionResult(summary: "Blocked \(name) from being captured.", affectedID: appSiteBlock()?.id, success: true)

        case .addTopicFilter(let statement):
            let id = addTopicFilter(statement: statement)
            return PrivacyActionResult(summary: "Added filter: \"\(statement)\".", affectedID: id, success: true)

        case .addTag(let label, let filterID):
            addTag(label, to: filterID)
            return PrivacyActionResult(summary: "Added \"\(label)\" to the filter.", affectedID: filterID, success: true)

        case .removeFilter(let id):
            let name = userFilters.first(where: { $0.id == id })?.statement ?? "filter"
            removeFilter(id: id)
            return PrivacyActionResult(summary: "Removed \"\(name)\".", affectedID: nil, success: true)

        case .pauseFilter(let id):
            let name = userFilters.first(where: { $0.id == id })?.statement ?? "filter"
            pauseFilter(id: id)
            return PrivacyActionResult(summary: "Paused \"\(name)\".", affectedID: id, success: true)

        case .resumeFilter(let id):
            let name = userFilters.first(where: { $0.id == id })?.statement ?? "filter"
            resumeFilter(id: id)
            return PrivacyActionResult(summary: "Resumed \"\(name)\".", affectedID: id, success: true)

        case .updateStatement(let id, let text):
            updateStatement(text, for: id)
            return PrivacyActionResult(summary: "Updated filter to: \"\(text)\".", affectedID: id, success: true)

        case .updateDuration(let id, let duration):
            updateDuration(duration, for: id)
            return PrivacyActionResult(summary: "Set retention to \(duration.label).", affectedID: id, success: true)

        case .setScreenContext(let on):
            setScreenContext(on)
            return PrivacyActionResult(summary: on ? "Screen capture enabled." : "Screen capture disabled.", affectedID: nil, success: true)

        case .setSecureCapture(let on):
            setSecureCapture(on)
            return PrivacyActionResult(summary: on ? "Secure Capture enabled." : "Secure Capture disabled.", affectedID: nil, success: true)

        case .setTelemetry(let on):
            setTelemetry(on)
            return PrivacyActionResult(summary: on ? "Telemetry sharing enabled." : "Telemetry sharing disabled.", affectedID: nil, success: true)

        case .unrecognized(let raw):
            return PrivacyActionResult(summary: "I wasn't sure what to do with: \"\(raw)\". Try \"Block Slack\" or \"Stop keeping anything about salary\".", affectedID: nil, success: false)
        }
    }
}

// MARK: - PrivacyActionResult — returned by apply() for chat confirmation

struct PrivacyActionResult {
    let summary: String
    let affectedID: UUID?
    let success: Bool
}
