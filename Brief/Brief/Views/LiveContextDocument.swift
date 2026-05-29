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
            // 1. PRIMARY GOAL
            h2("1. Primary goal — public launch", first: true)
            group {
                bullet("g-target", "Target: ship Highlight's public launch on Tuesday, June 9 — D-12.") {
                    label("Target:"); " ship Highlight's public launch on "; src(.gmail, "Tuesday, June 9"); " — D-12."
                }
                bullet("g-prop", "Value prop: the AI that already knows your work — brief, then act.") {
                    label("Value prop:"); " the AI that already knows your work — brief, then act, not just recall."
                }
                bullet("g-role", "Role: Head of Product, ex-Discord; recruited on the ambient-coordination vision.") {
                    label("Role:"); " Head of Product, ex-Discord — recruited on the ambient-coordination vision."
                }
            }

            // 2. TOP PRIORITIES
            h2("2. Top priorities")
            h3("Launch readiness")
            group {
                bullet("p1-status", "Status: on track — the Slack-Connection blocker (HL-1042) is cleared.") {
                    label("Status:"); " on track — the "; src(.linear, "Slack-Connection blocker (HL-1042)"); " is cleared."
                }
                bullet("p1-decision", "Decision: shipped the patch — 0 failures in 200 runs; the edge case now shows an honest reconnect prompt.") {
                    label("Decision:"); " shipped the patch — 0 failures in 200 runs; the edge case now shows an honest reconnect prompt."
                }
            }
            h3("External launch messaging")
            group {
                bullet("p2-line", "One-liner: locked — Highlight briefs you, then moves your work forward.") {
                    label("One-liner:"); " locked — "; src(.cursor, "Highlight briefs you, then moves your work forward"); "."
                }
                bullet("p2-wedge", "Wedge: lead with the proactive brief, not capture — rivals made capture table stakes.") {
                    label("Wedge:"); " lead with the proactive brief, not capture — rivals made capture table stakes."
                }
            }

            // 3. ACTIVE PIPELINE
            h2("3. Active pipeline")
            h3("Founding Product Marketer")
            group {
                bullet("pl-pmm", "Naomi Feldman: moving to an onsite — reframed our problem as category creation.") {
                    label("Naomi Feldman:"); " moving to an "; src(.voice, "onsite"); " — reframed our problem as category creation."
                }
                bullet("pl-next", "Next: confirm comp with Sergei after the onsite, not before.") {
                    label("Next:"); " confirm comp with Sergei after the onsite, not before."
                }
            }
            h3("Competitive analysis")
            group {
                bullet("pl-comp", "Littlebird: closest rival — ambient on-screen context. Stops at recall; we go to action.") {
                    label("Littlebird:"); " closest rival — ambient on-screen context. Stops at recall; we go to action."
                }
            }

            // 4. CONCLUDED (muted tail)
            h2("4. Concluded this week", muted: true)
            group {
                bullet("c-oauth", "OAuth ship call: made with real numbers — cleared for launch.") {
                    label("OAuth ship call:"); " made with real numbers — cleared for launch."
                }
                bullet("c-line", "Launch one-liner: locked after the positioning debate.") {
                    label("Launch one-liner:"); " locked after the positioning debate."
                }
            }

            // 5. USER CONTEXT (muted tail)
            h2("5. User context (permanent)", muted: true)
            group {
                bullet("u-bg", "Background: ex-Discord product lead on coordination & community.") {
                    label("Background:"); " ex-Discord product lead on coordination & community."
                }
                bullet("u-phil", "Philosophy: evidence over vibes; artifact over adjective; transparency as a feature.") {
                    label("Philosophy:"); " evidence over vibes; artifact over adjective; transparency as a feature."
                }
            }

            // Information map (muted tail)
            h2("Information map", muted: true)
            infoMap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Headings (driven by DocStyle)

    private func h2(_ text: String, first: Bool = false, muted: Bool = false) -> some View {
        styled(text, style.h2, color: muted ? .briefInkTertiary : style.h2.color)
            .padding(.top, first ? 0 : style.headingTop)
            .padding(.bottom, style.headingToBody)
    }

    private func h3(_ text: String) -> some View {
        styled(text, style.h3)
            .padding(.top, style.groupGap)
            .padding(.bottom, style.headingToBody)
    }

    private func styled(_ text: String, _ s: DocTextStyle, color: Color? = nil) -> some View {
        Text(text)
            .font(s.font)
            .tracking(s.tracking)
            .lineSpacing(s.extraLineSpacing)
            .foregroundStyle(color ?? s.color)
    }

    // MARK: Bullet group + bullet

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: style.bulletGap) {
            content()
        }
    }

    private func bullet(
        _ id: String, _ text: String,
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
            .frame(width: 10, alignment: .center)
    }

    // MARK: Information map

    private var infoMap: some View {
        VStack(alignment: .leading, spacing: style.bulletGap) {
            mapRow("Highlight leadership", "Sergei Sorokin (CEO)", "manager; ambient-coordination vision")
            mapRow("Product engineering", "Parris Khachi (Head of Product Eng)", "launch-blocker partner")
            mapRow("Design", "Sam Eckert (Head of Design)", "launch-surface partner")
            mapRow("Operations", "Sarah Wu (Ops)", "recruiting + launch logistics")
            mapRow("Founding PMM", "Naomi Feldman (candidate)", "moving to onsite")
            mapRow("Launch plan", "Notion · Public Launch Plan", "checklist + go/no-go")
            mapRow("Launch blockers", "Linear · Public Launch cycle", "P0/P1 gating Jun 9")
        }
        .padding(.top, style.headingToBody)
    }

    private func mapRow(_ category: String, _ contact: String, _ note: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text(category).font(style.label.font).foregroundStyle(style.label.color)
                .frame(width: 170, alignment: .leading)
            Text(contact).font(style.value.font).foregroundStyle(Color.briefInkPrimary)
            Text("· \(note)").font(style.value.font).foregroundStyle(Color.briefInkTertiary)
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
                    ProvenanceInline(source: src, phrase: phrase)
                case .stacked(let srcs, let phrase):
                    ProvenanceStacked(sources: srcs, phrase: phrase)
                }
            }
        }
    }
}
