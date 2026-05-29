import SwiftUI

// MARK: - BriefContent — Dani's Live Context, as action-oriented tracks
//
// This file IS the generation logic, made explicit (see LIVE_CONTEXT_DESIGN.md).
// The goal organizes everything: launch is #1, hiring is #2. Each track earns its
// place because there's an action taken or needed on it. Tracks are classified by
// the user's intent — NEEDS YOU / IN MOTION / CONCLUDED — not by pipeline stage.
//
// Each track is *did → next*: a brief recap (what happened, calm) and a first-class
// NextStep (what to do, prominent). Every sourced phrase is woven from a named raw
// event in Mocks/*.jsonl (eventId) — auditable, not invented. Delete every citation
// and the prose still reads (the source-removal test).

enum BriefContent {

    // The single goal that organizes the document.
    static let goalTitle = "Public launch"
    static let goalLine  = "Ship the public launch on Tuesday, June 9 — 12 days out."

    // One-line framing shown under the goal.
    static let goalUnits: [MeaningUnit] = [
        unit("g-target", "Target:",
             clause("ship the public launch on ",
                    strand(.gmail, "Tuesday, June 9", "gml_d1_001"),
                    " — 12 days out.")),
        unit("g-prop", "The bet:",
             clause("not another tool to prompt — ",
                    strand(.cursor, "it briefs you, then acts", "cur_d1_002"),
                    ".")),
    ]

    // MARK: Tracks (classified by state; ranked within NEEDS YOU by the user)

    static let tracks: [Track] = [

        // ── NEEDS YOU ────────────────────────────────────────────────────

        // 1 — Launch blocker. Decision's made; the live move is the release note.
        track("t-oauth", "OAuth launch-blocker", goal: "launch", state: .needsYou,
            recap: [
                unit("oauth-r1", "Cleared:",
                     clause("the ",
                            "Slack-Connection blocker",
                            [strand(.linear, "Slack-Connection blocker", "lin_hl1042_s2"),
                             strand(.slack,  "decision: ship the patch", "slk_d2_003")],
                            " is gone — failures dropped to "),
                     clause("", strand(.voice, "0 of 200 overnight", "tr_d2_standup_01"),
                            ", and the rare edge case now shows a "),
                     clause("", strand(.github, "'reconnect' prompt", "gh_d2_002"),
                            " instead of failing silently.")),
            ],
            next: next("Add the Slack-revoke edge case to the release notes — the last loose end before the page is launch-safe.",
                       owner: .you, when: "today",
                       entry: strand(.linear, "release-notes issue", "lin_hl1033_issue"))),

        // 2 — Launch messaging. One-liner locked; a fresh proof point just landed.
        track("t-messaging", "Launch messaging", goal: "launch", state: .needsYou,
            recap: [
                unit("msg-r1", "Locked:",
                     clause("the one-liner — ",
                            "Highlight briefs you, then moves your work forward",
                            [strand(.cursor, "chosen: option 2", "cur_d2_001"),
                             strand(.linear, "launch-copy decision", "lin_hl0998_c2")],
                            ".")),
                unit("msg-r2", "New proof point:",
                     clause("Daily Summaries quality is up ",
                            strand(.slack, "+18% on the eval set", "slk_d2_005"),
                            " — exactly the kind of evidence Naomi said to lead with.")),
            ],
            next: next("Hand the +18% proof point to Samantha for the launch-day narrative.",
                       owner: .you, when: "today",
                       entry: strand(.slack, "forwarding to Samantha", "slk_d2_006"))),

        // 3 — Hiring #1. Strong candidate; waiting on ops, then a comp gate.
        track("t-naomi", "Founding PMM — Naomi Feldman", goal: "hiring", state: .needsYou,
            recap: [
                unit("naomi-r1", "Why her:",
                     clause("reframed our problem as ",
                            strand(.voice, "category creation", "tr_d1_coffee_naomi_02"),
                            " in minutes — top of the list to own launch messaging.")),
                unit("naomi-r2", "Moving to onsite:",
                     clause("a tight 4-person loop ",
                            strand(.slack, "you, Sergei, Sam, Sarah", "slk_d1_008"),
                            ".")),
            ],
            next: next("Sarah is sending Tue/Wed onsite slots; then confirm comp with Sergei after the onsite, not before.",
                       owner: .waitingOn("Sarah"),
                       entry: strand(.slack, "comp gate: after the onsite", "slk_d1_008c"),
                       chainedTo: "your SF launch week")),

        // ── IN MOTION ────────────────────────────────────────────────────

        // Rolling; informs the launch but needs nothing from Dani right now.
        track("t-positioning", "Competitive positioning", goal: "launch", state: .inMotion,
            recap: [
                unit("pos-r1", "Wedge holds:",
                     clause("Littlebird ",
                            strand(.slack, "stops at recall; we go to brief + act", "slk_d1_005"),
                            " — capture is table stakes now, so we don't lead with it.")),
            ]),

        // Head of AI candidate — conversation literally in progress.
        track("t-wei", "Head of AI — Wei Zhang", goal: "hiring", state: .inMotion,
            recap: [
                unit("wei-r1", "Coffee chat now:",
                     clause("focus is ",
                            strand(.voice, "eval harnesses on the brief's claims", "tr_d2_coffee_wei_02"),
                            " — reliability for proactive actions, not a bigger model.")),
            ]),

        // ── CONCLUDED ────────────────────────────────────────────────────

        // Done and shipped; lives here for reference (and feeds messaging above).
        track("t-summaries", "Daily Summaries quality pass", goal: "launch", state: .done,
            recap: [
                unit("sum-r1", "Shipped:",
                     clause("the prompt pass ",
                            "landed",
                            [strand(.linear, "summary-quality issue → Done", "lin_hl1051_s1"),
                             strand(.slack,  "+18% eval", "slk_d2_005")],
                            " — now a launch-day proof point.")),
            ]),
    ]

    // MARK: Permanent context (sourced — these are things Dani has stated)

    static let aboutUnits: [MeaningUnit] = [
        unit("about-bg", "Background:",
             clause("ex-Discord product lead on ",
                    strand(.voice, "coordination and community", "tr_d1_messaging_02"),
                    " — joined Highlight two months ago.")),
        unit("about-phil", "How she works:",
             clause("",
                    strand(.voice, "lead with the artifact, not the adjective", "tr_d1_coffee_naomi_04"),
                    "; defend calls with "),
             clause("", strand(.voice, "real numbers", "tr_d2_standup_02b"), ".")),
    ]

    // MARK: Information map — people & resources
    //
    // People carry an inline (captured) source for the relationship; resources are
    // external links ("where to go look") — a different kind than body citations.

    struct MapEntry: Identifiable {
        let id: String
        let role: String          // "Leadership", "Engineering", …
        let name: String          // "Sergei Sorokin (CEO)"
        let note: String          // what they're to Dani right now
        var captured: Strand? = nil      // captured-fact source (a person)
        var resource: ResourceLink? = nil  // external resource (a doc/view)
    }

    struct ResourceLink: Hashable {
        let source: BriefSource   // .notion / .linear
        let label: String         // "Public Launch cycle"
    }

    static let mapPeople: [MapEntry] = [
        MapEntry(id: "m-sergei", role: "Leadership", name: "Sergei Sorokin (CEO)",
                 note: "sets the vision; the comp call on Naomi runs through him",
                 captured: strand(.slack, "AI you don't have to ask", "slk_d1_012")),
        MapEntry(id: "m-parris", role: "Engineering", name: "Parris Khachi",
                 note: "your launch-blocker partner; merged the OAuth fix",
                 captured: strand(.slack, "merging #318 after CI", "slk_d2_004")),
        MapEntry(id: "m-sam", role: "Design", name: "Sam Eckert",
                 note: "laying out the hero now that the one-liner's locked",
                 captured: strand(.github, "launch-page copy", "gh_d1_001")),
        MapEntry(id: "m-sarah", role: "Operations", name: "Sarah Wu",
                 note: "running recruiting + launch logistics; sending Naomi's slots",
                 captured: strand(.slack, "onsite slots Tue/Wed", "slk_d1_007")),
        MapEntry(id: "m-samantha", role: "Brand (fractional)", name: "Samantha Taube",
                 note: "carries messaging until the founding PMM lands",
                 captured: strand(.slack, "founding-marketer job", "slk_d1_011")),
    ]

    static let mapResources: [MapEntry] = [
        MapEntry(id: "m-plan", role: "Launch plan", name: "Public Launch Plan",
                 note: "the live launch tracker",
                 resource: ResourceLink(source: .notion, label: "Notion")),
        MapEntry(id: "m-blockers", role: "Launch blockers", name: "Public Launch cycle",
                 note: "every open launch issue",
                 resource: ResourceLink(source: .linear, label: "Linear")),
    ]

    /// Tracks grouped by state, in document order.
    static func tracks(in state: TrackState) -> [Track] {
        tracks.filter { $0.state == state }
    }
}
