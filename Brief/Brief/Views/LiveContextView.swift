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
    // Sidebar selection unifies the Context views and the Variations.
    @State private var selection: SidebarItem = .variation(.brief)
    // Privacy is a slide-OVER, not a detail destination — tapping the shield
    // presents it on top of the window (see PrivacyPanel / privacySlideOver).
    @State private var showPrivacy = false
    // Shared live design tokens — the editor tunes this; the document reads it.
    @StateObject private var docStyle = DocStyle()
    // Day-switcher: which day's context is shown + popover visibility.
    @State private var selectedDay: BriefDayOption = .today
    @State private var showDayPicker = false

    private var selectedVariation: Variation? {
        if case let .variation(v) = selection { return v }
        return nil
    }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 248, max: 300)
        } detail: {
            detail
                .background(Color.briefPaper)
        }
        // Privacy panel slides in over the whole window from the right edge.
        .privacySlideOver(isPresented: $showPrivacy)
        // Esc closes the slide-over when it's open.
        .background(
            Button("") { showPrivacy = false }
                .keyboardShortcut(.escape, modifiers: [])
                .opacity(0)
                .disabled(!showPrivacy)
        )
    }

    // MARK: Sidebar

    private var sidebar: some View {
        // No `selection:` binding — we handle selection ourselves via tap, so
        // the system never paints its accent highlight over our custom row
        // background. (With a selection binding, macOS overlays the global
        // accent on the focused window regardless of .listRowBackground/.tint.)
        List {
            Section {
                ForEach(ContextView.allCases) { view in
                    SidebarRow(label: view.label, icon: view.icon,
                               isSelected: view == .privacy
                                   ? showPrivacy
                                   : selection == .context(view)) {
                        // Privacy is a slide-over, not a detail destination —
                        // present it over the current view; leave selection put.
                        if view == .privacy {
                            showPrivacy = true
                        } else {
                            selection = .context(view)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            } header: {
                Text("Context")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            Section {
                ForEach(Variation.allCases) { v in
                    SidebarRow(label: v.label, icon: v.icon,
                               isSelected: selection == .variation(v)) {
                        selection = .variation(v)
                    }
                    .listRowBackground(Color.clear)
                }
            } header: {
                Text("Variations")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: Detail — switches by selection

    @ViewBuilder
    private var detail: some View {
        switch selectedVariation {
        case .brief, .none:
            briefVariation            // A
        case .readAct:
            VariationReadAct(privacyChip: AnyView(PrivacyChip()))   // C
        case .conversational:
            VariationConversational(privacyChip: AnyView(PrivacyChip())) // D
        case .spacingLab:
            TypeEditorView(style: docStyle)
        }
    }

    // MARK: Variation A — the reading document (default)

    private var briefVariation: some View {
        SelectionSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    latestUpdateCard
                        .padding(.top, BriefSpacing.xl)
                    LiveContextDocument(style: docStyle)
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
    }

    // MARK: Header — title + day, day-switcher, privacy chip

    private var header: some View {
        // H1 title sits on a baseline row with the day it covers + a dropdown to
        // jump to another day's context. Below: the data-governance summary —
        // connected apps (where data came from) + protection (control over it).
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                BriefH1(text: "Live Context")
                daySwitcher
            }
            // Data-governance: Connected (sources) + Privacy (protection), as
            // Notion-style property rows.
            ContextSummaryBar()
                .padding(.top, BriefSpacing.xs)
        }
    }

    /// The day this brief covers, with a dropdown to switch days.
    private var daySwitcher: some View {
        Button { showDayPicker.toggle() } label: {
            HStack(spacing: BriefSpacing.xs) {
                Text(selectedDay.label)
                    .briefStyle(.body)
                    .foregroundStyle(Color.briefInkSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.briefInkTertiary)
            }
            .padding(.horizontal, BriefSpacing.sm)
            .padding(.vertical, BriefSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(showDayPicker ? Color.briefSelectionRest : Color.clear)
            )
            .contentShape(Rectangle())
            // The Family serif H1 and Söhne report baselines that don't line up
            // visually (the date floats above the title). Nudge the switcher's
            // reported baseline up so the view drops to sit on the H1 baseline.
            .alignmentGuide(.firstTextBaseline) { d in
                d[.firstTextBaseline] + 3
            }
        }
        .buttonStyle(.plain)
        .help("Switch day")
        .popover(isPresented: $showDayPicker, arrowEdge: .bottom) {
            dayPickerPopover
        }
    }

    /// Popover listing the available days of context. Scrolls — real Live Context
    /// accrues many days, so the list is capped in height and scrollable.
    private var dayPickerPopover: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(BriefDayOption.all) { day in
                    // A hairline above the cold rollup separates "days" from "summary".
                    if day == .earlier {
                        Divider()
                            .background(Color.briefHairlineSoft)
                            .padding(.horizontal, BriefSpacing.sm)
                            .padding(.vertical, BriefSpacing.xs)
                    }
                    Button { selectedDay = day; showDayPicker = false } label: {
                        HStack(spacing: BriefSpacing.md) {
                            VStack(alignment: .leading, spacing: 1) {
                                // The date is the title; the relative name (Today /
                                // Yesterday / weekday) is the quiet subtitle.
                                Text(day.label)
                                    .briefStyle(.body)
                                    .foregroundStyle(Color.briefInkPrimary)
                                Text(day.title)
                                    .briefStyle(.monoMeta)
                                    .foregroundStyle(Color.briefInkTertiary)
                            }
                            Spacer(minLength: BriefSpacing.xxl)
                            if day == selectedDay {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.briefHighlightInk)
                            }
                        }
                        .padding(.horizontal, BriefSpacing.lg)
                        .padding(.vertical, BriefSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(DayRowButtonStyle())
                }
            }
            .padding(BriefSpacing.sm)
        }
        .scrollIndicators(.hidden)   // scrolls, but no visible scrollbar
        .frame(width: 256)
        .frame(maxHeight: 320)       // cap height → scrolls when days pile up
    }

    // MARK: Latest-update card

    private var latestUpdateCard: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            HStack(spacing: BriefSpacing.sm) {
                Text("Latest update")
                    .briefStyle(.label)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("5/28/2026, 9:42 AM")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            // TL;DR — bullets, no oversized lede line.
            VStack(alignment: .leading, spacing: BriefSpacing.xs) {
                tldrItem("Launch on track for Jun 9 — nothing needs you right now.")
                tldrItem("OAuth blocker cleared; ship decision made this morning.")
                tldrItem("Launch one-liner locked.")
                tldrItem("Founding PMM (Naomi) moving to an onsite.")
            }
            .padding(.top, BriefSpacing.xs)
        }
        // Card inset, Notion-style: generous, with vertical > horizontal.
        .padding(.horizontal, BriefSpacing.xxl)   // 20
        .padding(.vertical, 24)                     // tightened from 28
        .frame(maxWidth: .infinity, alignment: .leading)
        // White/raised surface with a whisper border (Ilwon: this card is
        // white). Border is near-paper so it reads as a soft edge, not a box.
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
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

}

// MARK: - Brief day (day-switcher model)
// The days of context available to switch between. Dates track the mock
// timeline (Dani's Live Context runs day1 5/27 → day2 5/28, plus a cold
// 2-month rollup). "Today" is the latest day the brief covers.

struct BriefDayOption: Identifiable, Hashable {
    let id: String
    let title: String   // "Today", "Yesterday", weekday, or "Earlier"
    let label: String   // "Thursday, May 28" / "2-month summary"

    static let today     = BriefDayOption(id: "d2", title: "Today",     label: "Thursday, May 28")
    static let yesterday = BriefDayOption(id: "d1", title: "Yesterday", label: "Wednesday, May 27")
    static let earlier   = BriefDayOption(id: "cold", title: "Earlier", label: "2-month summary")

    /// A fuller history — real Live Context accrues a day per active day, so the
    /// switcher scrolls. Today/Yesterday are named; older days show their weekday;
    /// the cold rollup sits at the bottom.
    static let all: [BriefDayOption] = [
        today,
        yesterday,
        BriefDayOption(id: "d-0526", title: "Monday",   label: "Monday, May 26"),
        BriefDayOption(id: "d-0523", title: "Friday",   label: "Friday, May 23"),
        BriefDayOption(id: "d-0522", title: "Thursday", label: "Thursday, May 22"),
        BriefDayOption(id: "d-0521", title: "Wednesday", label: "Wednesday, May 21"),
        BriefDayOption(id: "d-0520", title: "Tuesday",  label: "Tuesday, May 20"),
        BriefDayOption(id: "d-0519", title: "Monday",   label: "Monday, May 19"),
        BriefDayOption(id: "d-0516", title: "Friday",   label: "Friday, May 16"),
        earlier,
    ]
}

// MARK: - Day-picker row button style

private struct DayRowButtonStyle: ButtonStyle {
    @State private var hovering = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(hovering ? Color.briefSelectionRest : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { hovering = $0 }
            .animation(.briefHover, value: hovering)
    }
}

// MARK: - Sidebar row
// Draws its own warm-gray selection capsule (NOT the brand accent — yellow is
// reserved for positive action). `.listRowBackground(.clear)` on the caller
// suppresses the system's accent highlight, since SwiftUI sidebar selection
// otherwise follows the global AccentColor and ignores `.tint()`.

private struct SidebarRow: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    @State private var hovering = false

    var body: some View {
        let emphasized = isSelected || hovering
        HStack(spacing: BriefSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(emphasized ? Color.briefInkPrimary : Color.briefInkSecondary)
                .frame(width: 18)
            Text(label)
                .briefStyle(.body)
                .foregroundStyle(emphasized ? Color.briefInkPrimary : Color.briefInkSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, BriefSpacing.sm)
        .padding(.vertical, BriefSpacing.xs + 1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                .fill(isSelected ? Color.briefSelectionActive
                      : hovering ? Color.briefSelectionRest : .clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
        .onTapGesture(perform: onTap)
        .animation(.briefHover, value: hovering)
    }
}

// MARK: - Sidebar model

/// One selectable thing in the sidebar — either a Context view or a Variation.
enum SidebarItem: Hashable {
    case context(ContextView)
    case variation(Variation)
}

/// The priority-presentation variations being compared (see research:
/// PRIORITIES / read-vs-act methodology).
enum Variation: String, CaseIterable, Identifiable, Hashable {
    case brief          // A — BLUF reading document
    case readAct        // C — read | act split
    case conversational // D — doc + AI chat rail
    case spacingLab     // tuning surface for document rhythm

    var id: String { rawValue }

    var label: String {
        switch self {
        case .brief:          return "A · The Brief"
        case .readAct:        return "C · Read | Act"
        case .conversational: return "D · Conversational"
        case .spacingLab:     return "⚙ Type Editor"
        }
    }

    var icon: String {
        switch self {
        case .brief:          return "doc.text"
        case .readAct:        return "rectangle.split.2x1"
        case .conversational: return "bubble.left.and.text.bubble.right"
        case .spacingLab:     return "slider.horizontal.3"
        }
    }
}

enum ContextView: String, CaseIterable, Identifiable, Hashable {
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
