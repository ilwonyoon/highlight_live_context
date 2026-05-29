import SwiftUI

// MARK: - Live Context panel
// Recreates Highlight's "Live Context" screen in the Brief design system,
// rendered from Dani Reyes' mock data. Architecture: sidebar (context views)
// + a reading-first document body. The body is the hero — a single living
// document, not a feed of panes. Max-width is fixed (~700pt) so prose stays
// readable on any window width (Notion-style). Section separation is by
// spacing only — no background bands. Inline provenance marks which facts
// came from which Connection.
//
// Action model (line-select → chat) is intentionally deferred; lines are
// wrapped in SelectableLine so it can be layered on later.

struct LiveContextView: View {
    @State private var selectedView: ContextView = .liveContext

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 248, max: 300)
        } detail: {
            SelectionSurface {
                content
            }
            .background(Color.briefPaper)
        }
    }

    // MARK: Sidebar

    private var sidebar: some View {
        List(selection: $selectedView) {
            Section {
                ForEach(ContextView.allCases) { view in
                    Label(view.label, systemImage: view.icon)
                        .tag(view)
                }
            } header: {
                Text("Context")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: Content (the document)

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                latestUpdateCard
                    .padding(.top, BriefSpacing.xl)
                document
                    .padding(.top, BriefSpacing.xxxl)
                Spacer(minLength: BriefSpacing.mega)
            }
            // The readability lever: cap body width and center it.
            .frame(maxWidth: BriefLayout.readingWidth, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, BriefSpacing.huge)
            .padding(.top, BriefSpacing.xxl)
        }
        .scrollIndicators(.visible)
    }

    // MARK: Header — cleaned up + always-visible privacy chip

    private var header: some View {
        HStack(alignment: .center, spacing: BriefSpacing.lg) {
            // Workspace identity — H1 title, no icon chrome.
            VStack(alignment: .leading, spacing: 1) {
                BriefH1(text: "Live Context")
                Text("Dani Reyes · 24 highlights")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            Spacer()

            // Always-visible privacy/trust signal (P0 hero). Casual users
            // read it for peace of mind; power users tap into detail.
            privacyChip
        }
    }

    // The trust chip: a calm, recurring "here's what I protected" signal.
    // Aggregate counts only — never the content (the secret/medical detail).
    private var privacyChip: some View {
        HStack(spacing: BriefSpacing.sm) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.briefHighlightDeep)
            Text("2 secrets kept out · 4 personal · 2 rules")
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkSecondary)
        }
        .padding(.horizontal, BriefSpacing.lg)
        .padding(.vertical, BriefSpacing.sm)
        .background(
            Capsule(style: .continuous)
                .fill(Color.briefHighlightWash.opacity(0.5))
                .overlay(Capsule(style: .continuous).stroke(Color.briefHairline, lineWidth: 1))
        )
    }

    // MARK: Latest-update card

    private var latestUpdateCard: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            HStack(spacing: BriefSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.briefHighlightDeep)
                Text("Latest update")
                    .briefStyle(.label)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("5/28/2026, 9:42 AM")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            // TL;DR — bullets, not prose.
            VStack(alignment: .leading, spacing: BriefSpacing.xs) {
                tldrItem("Launch on track — D-12 (Tue Jun 9).")
                tldrItem("OAuth blocker cleared; ship decision made.")
                tldrItem("Founding PMM (Naomi) moving to an onsite.")
            }
        }
        .padding(BriefSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairline, lineWidth: 1)
                )
        )
    }

    private func tldrItem(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text("•")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: 8, alignment: .center)
            Text(text)
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: The Live Context document — Dani's data as hierarchical prose

    private var document: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title lives in the header; body opens at section 1.
            // Provenance is used sparingly — only the load-bearing fact in a
            // line carries a source. Plain facts stay plain so the eye rests.

            // ── 1. PRIMARY GOAL ───────────────────────────────
            BriefH2(text: "1. Primary goal — public launch")
            bullets {
                bullet("g-target", "Target: ship Highlight's public launch on Tuesday, June 9 — D-12.") {
                    label("Target:")
                    " ship Highlight's public launch on "
                    src(.gmail, "Tuesday, June 9")
                    " — D-12."
                }
                bullet("g-prop", "Value prop: the AI that already knows your work — brief, then act.") {
                    label("Value prop:")
                    " the AI that already knows your work — brief, then act, not just recall."
                }
                bullet("g-role", "Role: Head of Product, ex-Discord; recruited by Sergei on the ambient-coordination vision.") {
                    label("Role:")
                    " Head of Product, ex-Discord — recruited on the ambient-coordination vision."
                }
            }

            // ── 2. TOP TIER PRIORITIES ────────────────────────
            BriefH2(text: "2. Top priorities")

            BriefH3(text: "Launch readiness")
            bullets {
                bullet("p1-status", "Status: on track. The Slack-Connection OAuth blocker (HL-1042) is cleared after Adrian's patch.") {
                    label("Status:")
                    " on track — the "
                    src(.linear, "Slack-Connection blocker (HL-1042)")
                    " is cleared."
                }
                bullet("p1-decision", "Decision: shipped the patch (0 failures in 200 runs); the remaining edge case surfaces an honest reconnect prompt.") {
                    label("Decision:")
                    " shipped the patch — 0 failures in 200 runs; the edge case now shows an honest reconnect prompt."
                }
            }

            BriefH3(text: "External launch messaging")
            bullets {
                bullet("p2-line", "One-liner: locked — Highlight briefs you, then moves your work forward.") {
                    label("One-liner:")
                    " locked — "
                    src(.cursor, "Highlight briefs you, then moves your work forward")
                    "."
                }
                bullet("p2-wedge", "Wedge: lead with the proactive brief, not capture — Littlebird and Granola made capture table stakes.") {
                    label("Wedge:")
                    " lead with the proactive brief, not capture — rivals made capture table stakes."
                }
            }

            // ── 3. ACTIVE PIPELINE ────────────────────────────
            BriefH2(text: "3. Active pipeline")

            BriefH3(text: "Founding Product Marketer")
            bullets {
                bullet("pl-pmm", "Naomi Feldman moving to an onsite — reframed our problem as category creation.") {
                    label("Naomi Feldman:")
                    " moving to an "
                    src(.voice, "onsite")
                    " — reframed our problem as category creation."
                }
                bullet("pl-pmm-next", "Next: confirm the comp band with Sergei after the onsite, not before.") {
                    label("Next:")
                    " confirm comp with Sergei after the onsite, not before."
                }
            }

            BriefH3(text: "Competitive analysis")
            bullets {
                bullet("pl-comp", "Littlebird is the closest rival (ambient on-screen context, $11M) — stops at recall; we go to action.") {
                    label("Littlebird:")
                    " closest rival — ambient on-screen context. Stops at recall; we go to action."
                }
            }

            // ── 4. CONCLUDED ──────────────────────────────────
            BriefH2(text: "4. Concluded this week")
            bullets {
                bullet("c-oauth", "OAuth ship decision — made the call with real numbers; cleared for launch.") {
                    label("OAuth ship call:")
                    " made with real numbers — cleared for launch."
                }
                bullet("c-line", "Launch one-liner — locked after the wedge debate with Samantha.") {
                    label("Launch one-liner:")
                    " locked after the positioning debate."
                }
            }

            // ── 5. USER CONTEXT (permanent) ───────────────────
            BriefH2(text: "5. User context (permanent)")
            bullets {
                bullet("u-bg", "Background: ex-Discord product lead on coordination & community; years synchronizing many people's effort.") {
                    label("Background:")
                    " ex-Discord product lead on coordination & community."
                }
                bullet("u-phil", "Philosophy: decides with evidence not vibes; leads with the artifact, not the adjective; treats transparency as a feature.") {
                    label("Philosophy:")
                    " evidence over vibes; artifact over adjective; transparency as a feature."
                }
            }

            // ── Information map ────────────────────────────────
            BriefH2(text: "Information map")
            infoMap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Information map — people & resources index

    private var infoMap: some View {
        VStack(alignment: .leading, spacing: BriefMarkdown.bulletTop) {
            mapRow("Highlight leadership", "Sergei Sorokin (CEO)", "manager; ambient-coordination vision")
            mapRow("Product engineering", "Parris Khachi (Head of Product Eng)", "launch-blocker partner")
            mapRow("Design", "Sam Eckert (Head of Design)", "launch-surface partner")
            mapRow("Operations", "Sarah Wu (Ops)", "recruiting + launch logistics")
            mapRow("Founding PMM", "Naomi Feldman (candidate)", "moving to onsite")
            mapRow("Launch plan", "Notion · Public Launch Plan", "checklist + go/no-go")
            mapRow("Launch blockers", "Linear · Public Launch cycle", "P0/P1 gating Jun 9")
        }
        .padding(.top, BriefSpacing.sm)
    }

    private func mapRow(_ category: String, _ contact: String, _ note: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text(category)
                .briefStyle(.bodyMedium)
                .foregroundStyle(Color.briefInkPrimary)
                .frame(width: 170, alignment: .leading)
            Text(contact)
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkPrimary)
            Text("· \(note)")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }

    // MARK: Bullet helpers (scoped copies of the DS pattern)

    private func bullets<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BriefMarkdown.bulletTop) {
            content()
        }
        .padding(.top, BriefSpacing.sm)
    }

    private func bullet(
        _ id: String,
        _ text: String,
        @ProvenanceLineBuilder _ segments: () -> [ProvenanceSegment]
    ) -> some View {
        let segs = segments()
        return SelectableLine(id: id, kind: .line, text: text) {
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
                Text("•")
                    .briefStyle(.body)
                    .foregroundStyle(Color.briefInkTertiary)
                    .frame(width: 8, alignment: .center)
                ProvenanceLine(segments: segs)
            }
        }
    }
}

// MARK: - Sidebar model

private enum ContextView: String, CaseIterable, Identifiable, Hashable {
    case liveContext, screenInsights, groupedInsights, connections, privacy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .liveContext:     return "Live Context"
        case .screenInsights:  return "Screen Insights"
        case .groupedInsights: return "Grouped Insights"
        case .connections:     return "Connections"
        case .privacy:         return "Privacy"
        }
    }

    var icon: String {
        switch self {
        case .liveContext:     return "waveform.path.ecg"
        case .screenInsights:  return "display"
        case .groupedInsights: return "rectangle.3.group"
        case .connections:     return "link"
        case .privacy:         return "checkmark.shield"
        }
    }
}

#Preview {
    LiveContextView()
        .environmentObject(SelectionContext())
        .frame(width: 1100, height: 820)
}
