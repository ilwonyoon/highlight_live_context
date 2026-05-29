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
            // 1. PRIMARY GOAL — section with bullets directly under it.
            h2("1. Primary goal — public launch", first: true)
            group(depth: 1) {
                bullet("g-target", 1, "Target: ship Highlight's public launch on Tuesday, June 9 — D-12.") {
                    label("Target:"); " ship Highlight's public launch on "; src(.gmail, "Tuesday, June 9"); " — D-12."
                }
                bullet("g-prop", 1, "Value prop: the AI that already knows your work — brief, then act.") {
                    label("Value prop:"); " the AI that already knows your work — brief, then act, not just recall."
                }
                bullet("g-role", 1, "Role: Head of Product, ex-Discord; recruited on the ambient-coordination vision.") {
                    label("Role:"); " Head of Product, ex-Discord — recruited on the ambient-coordination vision."
                }
            }

            // 2. TOP PRIORITIES — section with numbered sub-headings (1), 2)).
            h2("2. Top priorities")
            h3("1)", "Launch readiness")
            group(depth: 2) {
                bullet("p1-status", 2, "Status: on track — the Slack-Connection blocker (HL-1042) is cleared.") {
                    label("Status:"); " on track — the "; src(.linear, "Slack-Connection blocker (HL-1042)"); " is cleared."
                }
                bullet("p1-decision", 2, "Decision: shipped the patch — 0 failures in 200 runs; the edge case now shows an honest reconnect prompt.") {
                    label("Decision:"); " shipped the patch — 0 failures in 200 runs; the edge case now shows an honest reconnect prompt."
                }
            }
            h3("2)", "External launch messaging")
            group(depth: 2) {
                bullet("p2-line", 2, "One-liner: locked — Highlight briefs you, then moves your work forward.") {
                    label("One-liner:"); " locked — "; src(.cursor, "Highlight briefs you, then moves your work forward"); "."
                }
                bullet("p2-wedge", 2, "Wedge: lead with the proactive brief, not capture — rivals made capture table stakes.") {
                    label("Wedge:"); " lead with the proactive brief, not capture — rivals made capture table stakes."
                }
            }

            // 3. ACTIVE PIPELINE
            h2("3. Active pipeline")
            h3("1)", "Founding Product Marketer")
            group(depth: 2) {
                bullet("pl-pmm", 2, "Naomi Feldman: moving to an onsite — reframed our problem as category creation.") {
                    label("Naomi Feldman:"); " moving to an "; src(.voice, "onsite"); " — reframed our problem as category creation."
                }
                bullet("pl-next", 2, "Next: confirm comp with Sergei after the onsite, not before.") {
                    label("Next:"); " confirm comp with Sergei after the onsite, not before."
                }
            }
            h3("2)", "Competitive analysis")
            group(depth: 2) {
                bullet("pl-comp", 2, "Littlebird: closest rival — ambient on-screen context. Stops at recall; we go to action.") {
                    label("Littlebird:"); " closest rival — ambient on-screen context. Stops at recall; we go to action."
                }
            }

            // 4. CONCLUDED
            h2("4. Concluded this week")
            group(depth: 1) {
                bullet("c-oauth", 1, "OAuth ship call: made with real numbers — cleared for launch.") {
                    label("OAuth ship call:"); " made with real numbers — cleared for launch."
                }
                bullet("c-line", 1, "Launch one-liner: locked after the positioning debate.") {
                    label("Launch one-liner:"); " locked after the positioning debate."
                }
            }

            // 5. USER CONTEXT
            h2("5. User context (permanent)")
            group(depth: 1) {
                bullet("u-bg", 1, "Background: ex-Discord product lead on coordination & community.") {
                    label("Background:"); " ex-Discord product lead on coordination & community."
                }
                bullet("u-phil", 1, "Philosophy: evidence over vibes; artifact over adjective; transparency as a feature.") {
                    label("Philosophy:"); " evidence over vibes; artifact over adjective; transparency as a feature."
                }
            }

            // Information map
            h2("Information map")
            infoMap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Indent for a hierarchy depth (H2 = 0, H3 = 1, their bullets = depth+1).
    private func indent(_ depth: Int) -> CGFloat { CGFloat(depth) * style.indentStep }

    // MARK: Headings (driven by DocStyle)

    private func h2(_ text: String, first: Bool = false, muted: Bool = false) -> some View {
        styled(text, style.h2, color: muted ? .briefInkTertiary : style.h2.color)
            .padding(.top, first ? 0 : style.headingTop)
            .padding(.bottom, style.headingToBody)
    }

    /// Numbered sub-heading: "1) Launch readiness", indented one level under H2.
    private func h3(_ number: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text(number).font(style.h3.font).foregroundStyle(style.h3.color)
            Text(text).font(style.h3.font).tracking(style.h3.tracking).foregroundStyle(style.h3.color)
        }
        .lineSpacing(style.h3.extraLineSpacing)
        .padding(.leading, indent(1))
        .padding(.top, style.groupGapAbove)
        .padding(.bottom, style.groupGapBelow)
    }

    private func styled(_ text: String, _ s: DocTextStyle, color: Color? = nil) -> some View {
        Text(text)
            .font(s.font)
            .tracking(s.tracking)
            .lineSpacing(s.extraLineSpacing)
            .foregroundStyle(color ?? s.color)
    }

    // MARK: Bullet group + bullet

    private func group<Content: View>(depth: Int, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: style.bulletGap) {
            content()
        }
        .padding(.leading, indent(depth))
    }

    private func bullet(
        _ id: String, _ depth: Int, _ text: String,
        @ProvenanceLineBuilder _ segments: () -> [ProvenanceSegment]
    ) -> some View {
        let segs = segments()
        return SelectableLine(id: id, kind: .line, text: text, verticalPadding: 0) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                marker
                StyledProse(segments: segs, style: style)
            }
        }
    }

    private var marker: some View {
        // A glyph-based marker scales with the value font and baseline-aligns.
        Text("•")
            .font(style.value.font)
            .foregroundStyle(Color.briefInkTertiary)
            .frame(width: 6, alignment: .center)
    }

    // MARK: Information map

    private var infoMap: some View {
        VStack(alignment: .leading, spacing: style.bulletGap) {
            mapRow("im-lead", "Highlight leadership:", "Sergei Sorokin (CEO) — ambient-coordination vision")
            mapRow("im-eng", "Product engineering:", "Parris Khachi — launch-blocker partner")
            mapRow("im-design", "Design:", "Sam Eckert — launch-surface partner")
            mapRow("im-ops", "Operations:", "Sarah Wu — recruiting + launch logistics")
            mapRow("im-pmm", "Founding PMM:", "Naomi Feldman (candidate) — moving to onsite")
            mapRow("im-plan", "Launch plan:", "Notion · Public Launch Plan")
            mapRow("im-blockers", "Launch blockers:", "Linear · Public Launch cycle")
        }
        .padding(.leading, indent(1))
    }

    /// Info-map entry as a bullet — same look as the document's other bullets.
    private func mapRow(_ id: String, _ lead: String, _ rest: String) -> some View {
        SelectableLine(id: id, kind: .line, text: "\(lead) \(rest)", verticalPadding: 0) {
            HStack(alignment: .firstTextBaseline, spacing: style.markerInset) {
                marker
                StyledProse(segments: [.label(lead), .text(" " + rest)], style: style)
            }
        }
    }
}

// MARK: - StyledProse
// Renders provenance segments with per-type styling pulled from DocStyle
// (label vs value vs provenance), laid out by the width-aware BriefProseLayout.

struct StyledProse: View {
    let segments: [ProvenanceSegment]
    @ObservedObject var style: DocStyle

    var body: some View {
        BriefProseLayout(lineGap: style.value.extraLineSpacing) {
            ForEach(segments.indices, id: \.self) { i in
                switch segments[i] {
                case .text(let s):
                    Text(s).font(style.value.font).tracking(style.value.tracking)
                        .foregroundStyle(style.value.color)
                case .label(let s):
                    Text(s).font(style.label.font).tracking(style.label.tracking)
                        .foregroundStyle(style.label.color)
                case .source(let src, let phrase):
                    ProvenanceInline(source: src, phrase: phrase, fontOverride: style.provenance.font)
                case .stacked(let srcs, let phrase):
                    ProvenanceStacked(sources: srcs, phrase: phrase)
                }
            }
        }
    }
}
