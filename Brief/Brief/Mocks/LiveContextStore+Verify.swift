import Foundation

// MARK: - Debug verification
// Runtime self-check that the mock data decodes cleanly. Invoked only when
// the BRIEF_VERIFY_MOCKS env var is set (see BriefApp). Prints a summary to
// stderr and exits — used to confirm the loader maps JSON → models without
// launching the GUI. Safe to keep; never runs in normal use.

#if DEBUG
extension LiveContextStore {
    @MainActor
    static func verifyAndExit() {
        let store = LiveContextStore()
        func line(_ s: String) { FileHandle.standardError.write(Data((s + "\n").utf8)) }

        line("=== LiveContext mock verification ===")
        line("persona:   \(store.persona?.name ?? "nil") — \(store.persona?.role ?? "?")")
        line("goal:      \(store.persona?.currentGoal.headline ?? "nil") (\(store.persona?.currentGoal.countdownLabel ?? "?"))")
        line("cast:      \(store.cast?.byId.count ?? 0) people")
        line("notion:    \(store.notion?.docs.count ?? 0) docs")
        line("history:   \(store.history?.window.weeks ?? -1) weeks, \(store.history?.productThinkingEvolution.count ?? 0) phases, \(store.history?.recurringPatterns.count ?? 0) patterns")
        line("--- hot streams ---")
        line("meetings:    \(store.meetings.count)")
        line("transcripts: \(store.transcripts.count)")
        line("slack:       \(store.slack.count)")
        line("email:       \(store.email.count)")
        line("chrome:      \(store.chrome.count)")
        line("github:      \(store.github.count)")
        line("cursor:      \(store.cursor.count)")
        line("linear:      \(store.linear.count)")
        line("clipboard:   \(store.clipboard.count)")
        line("screenshots: \(store.screenshots.count)")
        line("chat:        \(store.chatSessions.count) sessions / \(store.chatMessages.count) turns")
        line("--- merged timeline ---")
        line("total items: \(store.timeline.count)")
        line("day1:        \(store.timeline(for: .day1).count)")
        line("day2:        \(store.timeline(for: .day2).count)")
        line("prior:       \(store.timeline(for: .prior).count)")
        let sorted = zip(store.timeline, store.timeline.dropFirst()).allSatisfy { $0.timestamp <= $1.timestamp }
        line("sorted asc:  \(sorted)")
        if let first = store.timeline.first, let last = store.timeline.last {
            let f = ISO8601DateFormatter()
            line("range:       \(f.string(from: first.timestamp)) → \(f.string(from: last.timestamp))")
        }
        line("meetings+transcripts assembled: \(store.meetingsWithTranscripts().count) meetings")
        line("chat sessions assembled: \(store.chatSessionsWithMessages().count)")
        line("linear issues: \(store.linearByIssue().keys.sorted().joined(separator: ", "))")
        let sensitive = store.sensitiveItems()
        line("sensitive items: \(sensitive.count)")
        for s in sensitive {
            line("  [\(s.sensitive?.type.rawValue ?? "?")] \(s.id) (\(s.source.rawValue)) → \(s.sensitive?.suggestedAction.rawValue ?? "?")")
        }
        // resolve a sample person ref through the cast
        if let firstMeeting = store.meetings.first, let p = store.person(firstMeeting.participants.first) {
            line("sample resolve: meeting '\(firstMeeting.title)' participant → \(p.name)")
        }
        line("--- load errors ---")
        if store.loadErrors.isEmpty {
            line("NONE ✓")
        } else {
            for e in store.loadErrors { line("  ✗ \(e)") }
        }
        line("=== done ===")
        exit(store.loadErrors.isEmpty ? 0 : 1)
    }
}
#endif
