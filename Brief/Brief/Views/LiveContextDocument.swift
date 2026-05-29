import SwiftUI

// MARK: - LiveContextDocument
// The full Live Context body (all sections + information map), rendered from a
// DocStyle so the editor can tune it live. This is the single source used by
// Variation A and by the editor's center preview — "what you tune is the real
// document." Provenance segments stay interactive (BriefProseLayout).

struct LiveContextDocument: View {
    @ObservedObject var style: DocStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // The whole document is generated from BriefContent (tracks), per
            // LIVE_CONTEXT_DESIGN.md: the goal organizes; tracks are classified by
            // the user's intent (needs-you / in-motion / done); each track is
            // did→next with a first-class, prominent NextStep.

            // Primary goal — what organizes everything.
            h2("1. Primary goal — \(BriefContent.goalTitle.lowercased())", first: true)
            group(depth: 1) {
                ForEach(BriefContent.goalUnits) { u in recapLine(u) }
            }

            // 2. NEEDS YOU — your decision/action pending. Ranked by the user.
            stateSection(.needsYou, number: "2",
                         titleSuffix: "ranked by you")

            // 3. IN MOTION — rolling; nothing needed from you right now.
            stateSection(.inMotion, number: "3")

            // 4. CONCLUDED — done; reference only.
            stateSection(.done, number: "4")

            // 5. ABOUT DANI — permanent context (sourced: things she's stated).
            h2("5. About Dani")
            group(depth: 1) {
                ForEach(BriefContent.aboutUnits) { u in recapLine(u) }
            }

            // Information map.
            h2("Information map")
            infoMap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Indent for a hierarchy depth (H2 = 0, tracks = 1, recap/next = deeper).
    private func indent(_ depth: Int) -> CGFloat { CGFloat(depth) * style.indentStep }

    // Selection-capsule geometry — promoted to BriefLayout.Selection tokens.
    private let linePad: CGFloat = BriefLayout.Selection.linePad
    private let lineGap: CGFloat = BriefLayout.Selection.lineGap

    // MARK: Model-driven rendering (BriefContent tracks → views)

    /// A state section (NEEDS YOU / IN MOTION / CONCLUDED): an H2 heading, then
    /// each track under it. Renders nothing if the state has no tracks.
    @ViewBuilder
    private func stateSection(_ state: TrackState, number: String, titleSuffix: String? = nil) -> some View {
        let tracks = BriefContent.tracks(in: state)
        if !tracks.isEmpty {
            sectionHeading(number: number, title: state.sectionTitle, suffix: titleSuffix)
            VStack(alignment: .leading, spacing: style.bulletGap * 2) {
                ForEach(Array(tracks.enumerated()), id: \.element.id) { i, t in
                    trackView(t, number: i + 1)
                }
            }
            .padding(.leading, indent(1))
        }
    }

    /// One track: a numbered sub-heading ("1) OAuth launch-blocker"), the recap
    /// lines (calm), then the next step (prominent). The did→next shape, visible.
    private func trackView(_ t: Track, number: Int) -> some View {
        VStack(alignment: .leading, spacing: lineGap) {
            // Numbered sub-heading — restores the "1) 2) 3)" track numbering.
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
                Text("\(number))")
                    .font(style.h3.font).foregroundStyle(style.h3.color)
                Text(t.title)
                    .font(style.h3.font).tracking(style.h3.tracking)
                    .foregroundStyle(style.h3.color)
            }
            .padding(.bottom, style.groupGapBelow * 0.5)

            // Recap — what happened (calm).
            ForEach(t.recap) { recapLine($0) }

            // Next — what to do (prominent).
            if let next = t.next { nextStepView(next, trackId: t.id) }
        }
    }

    /// A recap line (the *did* half): an optional label + clauses, flattened to
    /// prose segments. Multi-strand phrases render cross-confirmed; single inline.
    private func recapLine(_ u: MeaningUnit) -> some View {
        let segs = segments(for: u)
        return SelectableLine(id: u.id, kind: .line, text: u.plainText, verticalPadding: linePad) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                marker
                StyledProse(segments: segs, style: style)
            }
        }
    }

    /// The next step (the *next* half) — set apart from the recap by an explicit
    /// "Next step:" label so the action is unmistakable. The owner/when ride as a
    /// quiet meta after the label; the action text carries the meaning; the entry
    /// point (if any) is an inline citation — the door to the work.
    private func nextStepView(_ step: NextStep, trackId: String) -> some View {
        var segs: [ProvenanceSegment] = []
        segs.append(.label("Next step: "))
        // Owner · when as a quiet meta, e.g. "You, today — ".
        var meta = step.owner.plain.capitalizedFirst
        if let when = step.when { meta += ", \(when)" }
        if let chain = step.chainedTo { meta += " · with \(chain)" }
        segs.append(.text(meta + " — "))
        segs.append(.text(step.text))
        if let entry = step.entry {
            segs.append(.text(" "))
            segs.append(.source(entry.source, entry.evidence))
        }
        let captured = segs
        return SelectableLine(id: "\(trackId)-next", kind: .line, text: "Next step: \(step.plainText)", verticalPadding: linePad) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                // Same bullet family as the recap — the "Next step:" label, not a
                // different marker, is what sets the action apart.
                marker
                StyledProse(segments: captured, style: style)
            }
        }
        // Lift the action off the calm recap.
        .padding(.top, style.bulletGap * 0.25)
    }

    /// Flatten a recap unit's label + clauses into prose segments.
    private func segments(for u: MeaningUnit) -> [ProvenanceSegment] {
        var segs: [ProvenanceSegment] = []
        if let label = u.label { segs.append(.label(label)); segs.append(.text(" ")) }
        for c in u.clauses {
            if !c.lead.isEmpty { segs.append(.text(c.lead)) }
            if !c.phrase.isEmpty {
                if c.strands.count > 1 {
                    segs.append(.stacked(c.strands.map(\.source), c.phrase))
                } else if let s = c.strands.first {
                    segs.append(.source(s.source, c.phrase))
                } else {
                    segs.append(.text(c.phrase))
                }
            }
            if !c.trail.isEmpty { segs.append(.text(c.trail)) }
        }
        return segs
    }

    // MARK: Headings (driven by DocStyle)

    private func h2(_ text: String, first: Bool = false, muted: Bool = false) -> some View {
        styled(text, style.h2, color: muted ? .briefInkTertiary : style.h2.color)
            .padding(.top, first ? 0 : style.headingTop)
            .padding(.bottom, style.headingToBody)
    }

    /// A section heading with an optional quiet suffix ("ranked by you") that
    /// names the user as the author of the ordering (P3 — trust + edit right).
    private func sectionHeading(number: String, title: String, suffix: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            styled("\(number). \(title)", style.h2)
            if let suffix {
                Text("· \(suffix)")
                    .font(style.label.font)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .padding(.top, style.headingTop)
        .padding(.bottom, style.headingToBody)
    }

    private func styled(_ text: String, _ s: DocTextStyle, color: Color? = nil) -> some View {
        Text(text)
            .font(s.font)
            .tracking(s.tracking)
            .lineSpacing(s.extraLineSpacing)
            .foregroundStyle(color ?? s.color)
    }

    // MARK: Group + marker

    private func group<Content: View>(depth: Int, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: lineGap) {
            content()
        }
        .padding(.leading, indent(depth))
    }

    private var marker: some View {
        // A glyph-based marker scales with the value font and baseline-aligns.
        Text("•")
            .font(style.value.font)
            .foregroundStyle(Color.briefInkTertiary)
            .frame(width: 6, alignment: .center)
    }

    // MARK: Information map — people (captured) + resources (external links)

    private var infoMap: some View {
        VStack(alignment: .leading, spacing: style.bulletGap * 1.5) {
            // People — the relationship carries a captured (inline) source.
            VStack(alignment: .leading, spacing: lineGap) {
                ForEach(BriefContent.mapPeople) { mapPersonRow($0) }
            }
            // Resources — external links ("where to go look"), a different kind.
            VStack(alignment: .leading, spacing: lineGap) {
                ForEach(BriefContent.mapResources) { mapResourceRow($0) }
            }
            .padding(.top, style.bulletGap * 0.5)
        }
        .padding(.leading, indent(1))
    }

    /// A person row: "Role — Name: note" with the captured source inline.
    private func mapPersonRow(_ e: BriefContent.MapEntry) -> some View {
        var segs: [ProvenanceSegment] = [.label("\(e.role) — "), .text("\(e.name): ")]
        if let cap = e.captured {
            segs.append(.source(cap.source, e.note))
        } else {
            segs.append(.text(e.note))
        }
        let captured = segs
        return SelectableLine(id: e.id, kind: .line, text: "\(e.role) — \(e.name): \(e.note)", verticalPadding: linePad) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                marker
                StyledProse(segments: captured, style: style)
            }
        }
    }

    /// A resource row: an external link form, visibly a different kind than the
    /// body's captured citations — "Role — Name · Source ↗".
    private func mapResourceRow(_ e: BriefContent.MapEntry) -> some View {
        SelectableLine(id: e.id, kind: .line, text: "\(e.role): \(e.name)", verticalPadding: linePad) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                marker
                StyledProse(segments: [.label("\(e.role) — "), .text("\(e.name) · \(e.note)")], style: style)
                if let r = e.resource {
                    ResourceTag(source: r.source, label: r.label)
                }
            }
        }
    }
}

// MARK: - ResourceTag — external-resource link (a different kind than a citation)
// Captured facts use inline citations (an underline on a removable phrase). An
// external resource is "where to go look" — shown as a small bordered link chip
// with the connector icon and an outward arrow, so the two kinds never blur.

private struct ResourceTag: View {
    let source: BriefSource
    let label: String
    @State private var hovering = false

    var body: some View {
        HStack(spacing: BriefSpacing.xs) {
            BriefIcon(source, size: 11, rendering: .original)
            Text(label)
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkSecondary)
            Image(systemName: "arrow.up.right")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(Color.briefInkTertiary)
        }
        .padding(.horizontal, BriefSpacing.sm)
        .padding(.vertical, 1)
        .background(
            Capsule(style: .continuous)
                .fill(hovering ? Color.briefHighlightSoft : Color.briefPaperSunken)
                .overlay(Capsule(style: .continuous).stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth))
        )
        .onHover { hovering = $0 }
        .help("Open in \(source.label)")
    }
}

// MARK: - StyledProse
// Renders provenance segments with per-type styling pulled from DocStyle
// (label vs value vs provenance), laid out by the width-aware BriefProseLayout.
//
// Plain text/label segments are split into PER-WORD children so the line wraps
// word-by-word like real prose — a long run no longer jumps wholesale to the next
// line, which was producing stray short lines (e.g. "Next step: You, today —" then
// the action on its own line). Source/stacked citations stay atomic (one chip).

private enum ProseAtom: Identifiable {
    case word(String, isLabel: Bool)      // one whitespace-delimited token (+ trailing space)
    case source(BriefSource, String)
    case stacked([BriefSource], String)

    var id: String {
        switch self {
        case .word(let s, let l):    return "w\(l ? "L" : ""):\(s)"
        case .source(let s, let p):  return "s:\(s.rawValue):\(p)"
        case .stacked(let ss, let p):return "k:\(ss.map(\.rawValue).joined()):\(p)"
        }
    }
}

struct StyledProse: View {
    let segments: [ProvenanceSegment]
    @ObservedObject var style: DocStyle

    /// Flatten segments into atoms, splitting prose into words so wrapping is
    /// word-level. A trailing space is kept on each word to preserve spacing.
    private var atoms: [(Int, ProseAtom)] {
        var out: [ProseAtom] = []
        func addWords(_ s: String, isLabel: Bool) {
            // Split on spaces, keep each word with a trailing space (except none
            // for an empty tail). Leading/trailing single spaces in `s` become
            // a thin spacer word so segment joins read correctly.
            let parts = s.components(separatedBy: " ")
            for (i, p) in parts.enumerated() {
                let isLast = i == parts.count - 1
                if p.isEmpty {
                    // Preserve an explicit space between segments.
                    if !isLast || s.hasSuffix(" ") { out.append(.word(" ", isLabel: isLabel)) }
                    continue
                }
                out.append(.word(isLast ? p : p + " ", isLabel: isLabel))
            }
        }
        for seg in segments {
            switch seg {
            case .text(let s):           addWords(s, isLabel: false)
            case .label(let s):          addWords(s, isLabel: true)
            case .source(let src, let p):  out.append(.source(src, p))
            case .stacked(let ss, let p):  out.append(.stacked(ss, p))
            }
        }
        return Array(out.enumerated())
    }

    var body: some View {
        BriefProseLayout(lineGap: style.value.extraLineSpacing) {
            ForEach(atoms, id: \.0) { _, atom in
                switch atom {
                case .word(let s, let isLabel):
                    if isLabel {
                        Text(s).font(style.label.font).tracking(style.label.tracking)
                            .foregroundStyle(style.label.color)
                    } else {
                        Text(s).font(style.value.font).tracking(style.value.tracking)
                            .foregroundStyle(style.value.color)
                    }
                case .source(let src, let phrase):
                    ProvenanceInline(source: src, phrase: phrase, fontOverride: style.provenance.font)
                case .stacked(let srcs, let phrase):
                    ProvenanceStacked(sources: srcs, phrase: phrase, fontOverride: style.provenance.font)
                }
            }
        }
    }
}
