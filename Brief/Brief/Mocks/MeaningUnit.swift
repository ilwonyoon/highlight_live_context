import SwiftUI

// MARK: - MeaningUnit — the generation model behind the brief
//
// The mental model (Ilwon): raw data → [data fabric: weave] → meaning units →
// the user decides faster. A MeaningUnit is what the brief is *made of*: one
// thing the user should know, expressed so the MEANING is the subject. The
// sources it was woven from are backing, not the point — most of the time the
// user never opens them. Provenance earns its place by doing two quiet jobs:
//
//   1. Trust — "this was woven from real capture across N sources," felt by its
//      presence, not by being read. So it stays light and never drives the
//      sentence.
//   2. An entry point — opening a source means "I want to act on this thread."
//      Rare, but it's the door to the next action (later: block-select → chat).
//      The unit's `id` is that handle.
//
// Representation is deliberately separate from this model: a unit knows its
// meaning and its strands, NOT how a citation looks. Inline underline, a quiet
// trailing chip, hover-to-reveal — all are renderer choices we can swap without
// touching generation. (Ilwon: "inline이 최선인지는 의문" — so don't bake it in.)

// MARK: Strand — one thread of evidence woven into a unit

/// A single source thread behind a clause: where it came from, and the short
/// evidence phrase that source actually contributed. `eventId` points back at
/// the raw event in Mocks/*.jsonl so the weave is auditable, not invented.
struct Strand: Identifiable, Hashable {
    let source: BriefSource
    /// The exact phrase this source contributed (the span a citation marks).
    let evidence: String
    /// Raw event id this was woven from (e.g. "tr_d2_standup_02b"). Optional so
    /// profile-level facts — which have no single capture event — can omit it.
    var eventId: String? = nil

    var id: String { "\(source.rawValue):\(evidence)" }
}

// MARK: Clause — one fact within a unit, with the source(s) that confirm it

/// One sentence-fragment of meaning plus the strand(s) backing it. A clause
/// confirmed by one source carries one strand; a clause cross-confirmed by
/// several carries several (rendered as a stacked mark, since it's the *same*
/// fact seen from multiple sources). When two *different* facts come from two
/// *different* sources, that's two clauses — not one crammed clause. This is
/// how "multiple provenance → split by sentence" falls out of the model.
struct Clause: Identifiable, Hashable {
    /// Lead text before the sourced phrase (e.g. "shipped — failures dropped to ").
    var lead: String = ""
    /// The phrase the source backs (e.g. "0 of 200"). Empty = no sourced span.
    var phrase: String = ""
    /// Trailing text after the phrase (e.g. " instead of failing silently").
    var trail: String = ""
    /// Source(s) backing `phrase`. One = inline; several = cross-confirmed.
    var strands: [Strand] = []

    var id: String { lead + "¶" + phrase + "¶" + trail }

    /// Plain reading of the clause, for selection text / accessibility.
    var plainText: String { (lead + phrase + trail) }
}

// MARK: MeaningUnit — one line of meaning (a recap line)

/// One line within a track's recap: an optional lead-in label plus the clauses
/// that say what happened. (Labels are structure — "Status:", "Decision:" — and
/// are never sourced.) This is the *did* half; the *next* half is NextStep.
struct MeaningUnit: Identifiable, Hashable {
    /// Stable handle — also the block-select / action unit.
    let id: String
    /// Lead-in label (e.g. "Status:"). Structure, not a fact — never sourced.
    var label: String? = nil
    /// The meaning, as one or more clauses. Multiple clauses read as separate
    /// sentences, each with its own source.
    var clauses: [Clause]

    /// Distinct sources across all clauses — the "woven from N sources" signal.
    var sources: [BriefSource] {
        var seen: [BriefSource] = []
        for c in clauses {
            for s in c.strands where !seen.contains(s.source) { seen.append(s.source) }
        }
        return seen
    }

    /// Full plain reading (label + clauses), for selection text.
    var plainText: String {
        let body = clauses.map(\.plainText).joined(separator: " ")
        if let label { return "\(label) \(body)" }
        return body
    }
}

// MARK: NextStep — the *next* half (first-class action, per P2)
//
// What the user does next on this track. First-class — not a "Next:" bullet —
// so the document is structurally action-oriented: a live track without a
// NextStep doesn't belong in NEEDS YOU. owner says whose move it is; `when`/
// `entry`/`chainedTo` make it executable and let the system optimize the route.

/// Whose move the next step is.
enum NextOwner: Hashable {
    case you                 // the user acts
    case waitingOn(String)   // waiting on someone else (e.g. "Jacob")

    var plain: String {
        switch self {
        case .you:               return "you"
        case .waitingOn(let w):  return "waiting on \(w)"
        }
    }
}

struct NextStep: Hashable {
    /// The action, phrased as a move the user can make now.
    var text: String
    /// Whose move it is.
    var owner: NextOwner = .you
    /// When — "today", "Tue 3PM", or nil if undated.
    var when: String? = nil
    /// Entry point into the action (e.g. the Linear issue to open). This is
    /// provenance in its (b) role — the door to acting, not a "go verify".
    var entry: Strand? = nil
    /// Chains this action into another (route optimization), e.g. "the SF visit".
    var chainedTo: String? = nil

    var plainText: String {
        var s = text
        if let when { s += " (\(when))" }
        if let chainedTo { s += " — with \(chainedTo)" }
        return s
    }
}

// MARK: Track — one flow toward the goal (the unit of classification)
//
// A track is a company/work-thread that progresses toward the goal. Its `state`
// is the classification axis (P3): the user's intent, not a pipeline stage.

/// Where a track sits by the user's intent — the document's section axis.
enum TrackState: Hashable {
    case needsYou    // your decision/action is pending — top
    case inMotion    // rolling; nothing required from you right now — middle
    case done        // concluded; reference only — bottom

    var sectionTitle: String {
        switch self {
        case .needsYou: return "Priority"
        case .inMotion: return "In motion"
        case .done:     return "Concluded"
        }
    }
}

struct Track: Identifiable, Hashable {
    let id: String
    /// Track name (e.g. "OAuth launch-blocker", "Founding PMM — Naomi").
    var title: String
    /// Which goal this serves, for grouping ("launch" / "hiring"). Optional.
    var goal: String? = nil
    var state: TrackState
    /// What happened — calm, brief. The *did* half.
    var recap: [MeaningUnit] = []
    /// What to do next — the *next* half (prominent). nil for in-motion/done.
    var next: NextStep? = nil

    /// Distinct sources woven across the whole track.
    var sources: [BriefSource] {
        var seen: [BriefSource] = []
        for u in recap { for s in u.sources where !seen.contains(s) { seen.append(s) } }
        if let e = next?.entry, !seen.contains(e.source) { seen.append(e.source) }
        return seen
    }
}

// MARK: - Builders — keep definitions terse and close to prose
//
//   track("oauth", "OAuth launch-blocker", goal: "launch", state: .needsYou,
//     recap: [
//       unit("oauth-did", "Status:",
//            clause("shipped — failures dropped to ", strand(.voice, "0 of 200", "tr_d2_standup_01"),
//                   "; the edge case now shows a "),
//            clause("", strand(.github, "'reconnect' prompt", "slk_d2_002"), " instead of failing silently.")),
//     ],
//     next: next("drop the Slack-revoke edge case into the release notes",
//                when: "today", entry: strand(.linear, "HL-1033", "lin_hl1033_issue")))

/// A strand: source + the phrase it contributed + (optional) raw event id.
func strand(_ source: BriefSource, _ evidence: String, _ eventId: String? = nil) -> Strand {
    Strand(source: source, evidence: evidence, eventId: eventId)
}

/// A single-source clause: lead text, one sourced phrase, trailing text.
func clause(_ lead: String, _ s: Strand, _ trail: String = "") -> Clause {
    Clause(lead: lead, phrase: s.evidence, trail: trail, strands: [s])
}

/// A cross-confirmed clause: the same phrase backed by several sources.
func clause(_ lead: String, _ phrase: String, _ strands: [Strand], _ trail: String = "") -> Clause {
    Clause(lead: lead, phrase: phrase, trail: trail, strands: strands)
}

/// A clause with no sourced span — plain connective text only.
func clause(_ text: String) -> Clause {
    Clause(lead: text, phrase: "", trail: "", strands: [])
}

/// A recap line: id, optional label, and its clauses.
func unit(_ id: String, _ label: String?, _ clauses: Clause...) -> MeaningUnit {
    MeaningUnit(id: id, label: label, clauses: clauses)
}

/// A next step: action text plus optional owner/when/entry/chain.
func next(_ text: String,
          owner: NextOwner = .you,
          when: String? = nil,
          entry: Strand? = nil,
          chainedTo: String? = nil) -> NextStep {
    NextStep(text: text, owner: owner, when: when, entry: entry, chainedTo: chainedTo)
}

/// A track: id, title, goal, state, recap lines, and (optional) next step.
func track(_ id: String, _ title: String,
           goal: String? = nil,
           state: TrackState,
           recap: [MeaningUnit] = [],
           next: NextStep? = nil) -> Track {
    Track(id: id, title: title, goal: goal, state: state, recap: recap, next: next)
}

extension String {
    /// Capitalize only the first character (e.g. "you" → "You", "waiting on Sarah"
    /// → "Waiting on Sarah") without lowercasing the rest.
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
