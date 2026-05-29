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
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
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
            Text("Dani locked the OAuth ship decision and the launch one-liner this morning. The Slack-Connection blocker is cleared for Jun 9, and the founding-PMM hire (Naomi) is moving to an onsite. Launch is on track at D-12.")
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BriefSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefHighlightWash.opacity(0.55))
        )
    }

    // MARK: The Live Context document — Dani's data as hierarchical prose

    private var document: some View {
        VStack(alignment: .leading, spacing: 0) {
            // (Title lives in the header now — body opens straight into sections.)

            // 1. PRIMARY GOAL
            BriefH2(text: "1. PRIMARY GOAL: PUBLIC LAUNCH (Top Priority)")
            bullets {
                bullet("g-target", "Target: Ship Highlight's public launch on Tuesday, June 9 (D-12).") {
                    label("Target:")
                    " ship Highlight's "
                    src(.gmail, "public launch")
                    " on Tuesday, June 9 (D-12)."
                }
                bullet("g-prop", "Core value prop: the AI that already knows your work — brief, then act.") {
                    label("Core value prop:")
                    " the AI that already "
                    src(.voice, "knows your work")
                    " — brief, then act, not just recall."
                }
                bullet("g-role", "Role: Head of Product, ex-Discord; recruited by Sergei on the ambient-coordination vision.") {
                    label("Role:")
                    " Head of Product, ex-Discord — recruited by "
                    src(.voice, "Sergei on the ambient-coordination vision")
                    "."
                }
            }

            // 2. TOP TIER PRIORITIES
            BriefH2(text: "2. TOP TIER PRIORITIES (Ranked)")

            BriefH3(text: "1. Launch readiness")
            bullets {
                bullet("p1-status", "Status: on track. The Slack-Connection OAuth blocker (HL-1042) is cleared.") {
                    label("Status:")
                    " on track. The "
                    stacked([.linear, .github], "Slack-Connection OAuth blocker (HL-1042)")
                    " is cleared after Adrian's patch."
                }
                bullet("p1-decision", "Decision: shipped the fix with a visible reconnect state; edge case noted in release notes.") {
                    label("Decision:")
                    " shipped the patch — "
                    src(.voice, "0 failures in 200 runs")
                    ", remaining edge case surfaces an honest reconnect prompt."
                }
            }

            BriefH3(text: "2. External launch messaging")
            bullets {
                bullet("p2-line", "One-liner: locked — Highlight briefs you, then moves your work forward.") {
                    label("One-liner:")
                    " locked — "
                    src(.cursor, "Highlight briefs you, then moves your work forward")
                    "."
                }
                bullet("p2-wedge", "Wedge: lead with the proactive brief, not capture — capture is table stakes now.") {
                    label("Wedge:")
                    " lead with the proactive brief, not "
                    src(.slack, "capture")
                    " — Littlebird/Granola made capture table stakes."
                }
            }

            BriefH3(text: "3. Recruiting")
            bullets {
                bullet("p3-pmm", "Founding PMM: Naomi Feldman moving to onsite; strong narrative instincts.") {
                    label("Founding PMM:")
                    " "
                    src(.voice, "Naomi Feldman")
                    " moving to an onsite — reframed our problem as category creation."
                }
                bullet("p3-next", "Next: confirm the band with Sergei after the onsite, not before.") {
                    label("Next:")
                    " confirm comp with Sergei "
                    src(.slack, "after the onsite, not before")
                    "."
                }
            }

            BriefH3(text: "4. Competitive analysis")
            bullets {
                bullet("p4-litt", "Littlebird is the closest rival — ambient on-screen context, $11M raised.") {
                    label("Littlebird:")
                    " closest rival — "
                    src(.slack, "ambient on-screen context, $11M")
                    ". Stops at recall; we go to action."
                }
            }

            // 3. PATTERNS — from the compressed history
            BriefH2(text: "3. HOW DANI WORKS (observed over ~9 weeks)")
            bullets {
                bullet("pat-1", "Decides with evidence, not vibes — defers binary calls until a number lands.") {
                    label("Evidence over vibes:")
                    " defers binary calls until there's a number or a landed artifact."
                }
                bullet("pat-2", "Leads with the artifact, not the adjective — distrusts abstract claims.") {
                    label("Artifact over adjective:")
                    " shows the concrete thing; resists overpromising verbs."
                }
                bullet("pat-3", "Treats transparency as a feature — prefers visible failure states.") {
                    label("Transparency as a feature:")
                    " prefers visible failure states over hidden polish."
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
