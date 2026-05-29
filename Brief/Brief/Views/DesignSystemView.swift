import SwiftUI

// MARK: - DesignSystemView
// Root view of the Brief app while we're building the design system.
// Sidebar lists Foundations / Components / Patterns; selecting an item
// renders its detail page on the right.
//
// Pages are intentionally scaffolded as placeholders we fill in over time.

struct DesignSystemView: View {
    @State private var selection: DSPage? = .colors

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 248)
                .background(Color.briefPaperSunken)   // sidebar recedes
            Divider()
                .overlay(Color.briefHairline)
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.briefPaper)          // content comes forward
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.briefPaper)
    }

    // MARK: Sidebar (custom — design-system controlled, no native List chrome)

    private var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                sidebarSection("Foundations", pages: DSPage.foundations)
                sidebarSection("Components",  pages: DSPage.components)
                sidebarSection("Patterns",    pages: DSPage.patterns)
            }
            .padding(.horizontal, BriefSpacing.md)
            .padding(.vertical, BriefSpacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private func sidebarSection(_ title: String, pages: [DSPage]) -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xxs) {
            Text(title.uppercased())
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
                .tracking(0.8)
                .padding(.horizontal, BriefSpacing.md)
                .padding(.bottom, BriefSpacing.xs)
            ForEach(pages) { page in
                sidebarRow(page)
            }
        }
    }

    private func sidebarRow(_ page: DSPage) -> some View {
        let isSelected = selection == page
        return Button {
            selection = page
        } label: {
            HStack(spacing: BriefSpacing.md) {
                Image(systemName: page.symbol)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(isSelected ? Color.briefInkPrimary : Color.briefInkSecondary)
                    .frame(width: 16)
                // Fixed weight/size so selection never reflows the row.
                // Selection is communicated by background + ink color only.
                Text(page.title)
                    .briefStyle(.body)
                    .foregroundStyle(isSelected ? Color.briefInkPrimary : Color.briefInkSecondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BriefSpacing.md)
            .padding(.vertical, BriefSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(isSelected ? Color.briefSelectionActive : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Detail

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .colors:        DSColorsPage()
        case .typography:    DSTypographyPage()
        case .spacing:       DSSpacingPage()
        case .radius:        DSRadiusPage()
        case .motion:        DSMotionPage()
        case .provenance:    DSProvenancePage()
        case .popover:       DSPopoverPage()
        case .composer:      DSComposerPage()
        case .selection:     DSSelectionPage()
        case .briefSurface:  DSBriefSurfacePage()
        case .playground:    DSPlaygroundPage()
        case .none:          DSPlaceholderPage(title: "Pick a topic")
        }
    }
}

// MARK: - Page registry

enum DSPage: String, Hashable, Identifiable {
    case colors, typography, spacing, radius, motion
    case provenance, popover, composer, selection
    case briefSurface, playground

    var id: String { rawValue }

    var title: String {
        switch self {
        case .colors:       return "Color"
        case .typography:   return "Typography"
        case .spacing:      return "Spacing"
        case .radius:       return "Radius"
        case .motion:       return "Motion"
        case .provenance:   return "Provenance"
        case .popover:      return "Popover"
        case .composer:     return "Chat composer"
        case .selection:    return "Selection"
        case .briefSurface: return "Brief surface"
        case .playground:   return "Playground"
        }
    }

    var symbol: String {
        switch self {
        case .colors:       return "drop.fill"
        case .typography:   return "textformat"
        case .spacing:      return "rectangle.split.3x1"
        case .radius:       return "square.on.square.squareshape.controlhandles"
        case .motion:       return "waveform.path"
        case .provenance:   return "quote.opening"
        case .popover:      return "bubble.left.fill"
        case .composer:     return "text.bubble"
        case .selection:    return "cursorarrow.rays"
        case .briefSurface: return "doc.text"
        case .playground:   return "hammer"
        }
    }

    static let foundations: [DSPage] = [.colors, .typography, .spacing, .radius, .motion]
    static let components:  [DSPage] = [.provenance, .popover, .composer, .selection]
    static let patterns:    [DSPage] = [.briefSurface, .playground]
}

// MARK: - Detail page shells (filled in over time)

/// Generic placeholder until a page is built out.
struct DSPlaceholderPage: View {
    let title: String
    var body: some View {
        DSPageScaffold(title: title, subtitle: "Coming soon.") {
            EmptyView()
        }
    }
}

struct DSColorsPage: View {
    var body: some View {
        DSPageScaffold(title: "Color", subtitle: "Warm-paper foundation, warm-ink text, and a single highlight family. Brand color appears only where the AI marks meaning.") {
            DSGroup(title: "Paper", note: "Surfaces. Warm off-white, never pure white.") {
                DSSwatchGrid(swatches: [
                    DSSwatch(color: .briefPaper,       name: "paper",       detail: "F1ECEC", ringForLight: true),
                    DSSwatch(color: .briefPaperRaised, name: "paperRaised", detail: "raised",  ringForLight: true),
                    DSSwatch(color: .briefPaperSunken, name: "paperSunken", detail: "sunken",  ringForLight: true),
                ])
            }
            DSGroup(title: "Ink", note: "Text and lines. Warm-shifted neutrals, four steps.") {
                DSSwatchGrid(swatches: [
                    DSSwatch(color: .briefInkPrimary,   name: "inkPrimary",   detail: "near-black"),
                    DSSwatch(color: .briefInkSecondary, name: "inkSecondary", detail: "mid"),
                    DSSwatch(color: .briefInkTertiary,  name: "inkTertiary",  detail: "light"),
                    DSSwatch(color: .briefInkDisabled,  name: "inkDisabled",  detail: "disabled"),
                ])
            }
            DSGroup(title: "Highlight", note: "The brand color. Reserved for AI-marked-as-mattering and positive action.") {
                DSSwatchGrid(swatches: [
                    DSSwatch(color: .briefHighlight,     name: "highlight",     detail: "E7FE0B"),
                    DSSwatch(color: .briefHighlightWash, name: "highlightWash", detail: "FBFFCD", ringForLight: true),
                    DSSwatch(color: .briefHighlightSoft, name: "highlightSoft", detail: "45 percent"),
                    DSSwatch(color: .briefHighlightDeep, name: "highlightDeep", detail: "70DB04"),
                    DSSwatch(color: .briefHighlightInk,  name: "highlightInk",  detail: "deep olive"),
                ])
            }
            DSGroup(title: "Lines and selection", note: "Dividers, hairlines, and the warm-gray selection wash.") {
                DSSwatchGrid(swatches: [
                    DSSwatch(color: .briefDivider,        name: "divider",        detail: "divider",   ringForLight: true),
                    DSSwatch(color: .briefHairline,       name: "hairline",       detail: "hairline",  ringForLight: true),
                    DSSwatch(color: .briefSelectionRest,  name: "selectionRest",  detail: "ink 6pct",  ringForLight: true),
                    DSSwatch(color: .briefSelectionHover, name: "selectionHover", detail: "ink 10pct", ringForLight: true),
                ])
            }
        }
    }
}

struct DSTypographyPage: View {
    var body: some View {
        DSPageScaffold(title: "Typography", subtitle: "Family serif for hero moments, Söhne sans as the workhorse, Söhne Mono for metadata. Three registers, each doing one job.") {
            DSGroup(title: "Family — hero", note: "Brand moments only. At most once per screen.") {
                typeRow("Todays Brief", token: .heroMedium, spec: "heroMedium  28pt  Family Bold")
            }
            DSGroup(title: "Söhne — titles", note: "Section hierarchy.") {
                typeRow("Title 1",  token: .title1,   spec: "title1  28pt  Kraftig")
                typeRow("Title 2",  token: .title2,   spec: "title2  22pt  Kraftig")
                typeRow("Title 3",  token: .title3,   spec: "title3  17pt  Halbfett")
                typeRow("Headline", token: .headline, spec: "headline  14pt  Halbfett")
            }
            DSGroup(title: "Söhne — body", note: "Reading text. Buch 400, line-height 1.45.") {
                typeRow(bodySample, token: .body,      spec: "body  14pt  Buch  1.45")
                typeRow(bodySample, token: .bodySmall, spec: "bodySmall  13pt  Buch  1.40")
                typeRow("Form label",  token: .label,   spec: "label  12pt  Kraftig")
                typeRow("Metadata text", token: .meta,  spec: "meta  11pt  Buch")
                typeRow("Caption text",  token: .caption, spec: "caption  10pt  Buch")
            }
            DSGroup(title: "Söhne Mono — metadata", note: "Timestamps, source labels, system text. Sprinkled, never structural.") {
                typeRow("0928 AM   May 28", token: .monoLabel, spec: "monoLabel  11pt  Mono Buch")
                typeRow("meeting brief",    token: .monoMeta,  spec: "monoMeta  10pt  Mono Buch")
            }
            DSGroup(title: "Markdown semantic mapping", note: "How heading levels map to tokens in document surfaces.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        BriefH1(text: "H1 — workspace title")
                        BriefH2(text: "H2 — section header")
                        BriefH3(text: "H3 — sub-group")
                        BriefH4(text: "H4 — bullet lead-in")
                        Text("Body — bullet text reads at the body token.")
                            .briefStyle(.body)
                            .foregroundStyle(Color.briefInkPrimary)
                    }
                }
            }
        }
    }

    private func typeRow(_ text: String, token: BriefTypeToken, spec: String) -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xxs) {
            Text(text)
                .briefStyle(token)
                .foregroundStyle(Color.briefInkPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(spec)
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }

    private let bodySample = "The brief is yesterdays lived context, compressed into what you need to decide today."
}

struct DSSpacingPage: View {
    private let steps: [(String, CGFloat)] = [
        ("xxs",  BriefSpacing.xxs),  ("xs",  BriefSpacing.xs),
        ("sm",   BriefSpacing.sm),   ("md",  BriefSpacing.md),
        ("lg",   BriefSpacing.lg),   ("xl",  BriefSpacing.xl),
        ("xxl",  BriefSpacing.xxl),  ("xxxl", BriefSpacing.xxxl),
        ("huge", BriefSpacing.huge), ("mega", BriefSpacing.mega),
    ]
    var body: some View {
        DSPageScaffold(title: "Spacing", subtitle: "A 4-based scale. Every gap, pad, and inset comes from one of these tokens — no raw numbers in views.") {
            DSGroup(title: "Scale", note: "Bar width is proportional to the value.") {
                VStack(alignment: .leading, spacing: BriefSpacing.md) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                        DSSpecRow(token: step.0, value: "\(Int(step.1)) pt") {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(Color.briefHighlightDeep.opacity(0.55))
                                .frame(width: step.1 * 3, height: 12)
                        }
                    }
                }
            }
        }
    }
}

struct DSRadiusPage: View {
    private let radii: [(String, CGFloat, String)] = [
        ("inline", BriefRadius.inline, "marks that stay rectangular"),
        ("chip",   BriefRadius.chip,   "citation pills, chips, badges"),
        ("card",   BriefRadius.card,   "cards, register blocks, popovers"),
        ("panel",  BriefRadius.panel,  "windows, large modals"),
    ]
    var body: some View {
        DSPageScaffold(title: "Radius", subtitle: "Four named corner radii cover the whole app. Inline objects feel rectangular; surfaces get progressively softer.") {
            DSGroup(title: "Scale") {
                VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                    ForEach(Array(radii.enumerated()), id: \.offset) { _, r in
                        DSSpecRow(token: r.0, value: r.2) {
                            RoundedRectangle(cornerRadius: r.1, style: .continuous)
                                .fill(Color.briefPaperSunken)
                                .overlay(
                                    RoundedRectangle(cornerRadius: r.1, style: .continuous)
                                        .stroke(Color.briefHairline, lineWidth: 0.5)
                                )
                                .frame(width: 96, height: 40)
                        }
                    }
                }
            }
        }
    }
}

struct DSMotionPage: View {
    var body: some View {
        DSPageScaffold(title: "Motion", subtitle: "Named timing tokens keep motion consistent. Hover any row to preview the curve. Disappearance is usually instant; appearance is animated.") {
            DSGroup(title: "Duration presets", note: "Hover the track to run the animation.") {
                VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                    DSMotionRow(name: "briefInstant",  spec: "0.08s  press feedback",      animation: .briefInstant)
                    DSMotionRow(name: "briefHover",    spec: "0.12s  hover transitions",   animation: .briefHover)
                    DSMotionRow(name: "briefStandard", spec: "0.16s  standard UI",         animation: .briefStandard)
                    DSMotionRow(name: "briefSlow",     spec: "0.25s  reveal and dismiss",  animation: .briefSlow)
                    DSMotionRow(name: "briefSpring",   spec: "spring  tactile present",    animation: .briefSpring)
                }
            }
            DSGroup(title: "Interaction delays", note: "How long the system waits before committing to a hover action.") {
                DSSpecRow(token: "hoverOn",  value: "\(Int(BriefDelay.hoverOn * 1000)) ms") { delayBar(BriefDelay.hoverOn) }
                DSSpecRow(token: "hoverOff", value: "\(Int(BriefDelay.hoverOff * 1000)) ms") { delayBar(BriefDelay.hoverOff) }
                DSSpecRow(token: "longPress", value: "\(Int(BriefDelay.longPress * 1000)) ms") { delayBar(BriefDelay.longPress) }
            }
        }
    }

    private func delayBar(_ seconds: Double) -> some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color.briefInkTertiary.opacity(0.4))
            .frame(width: seconds * 400, height: 10)
    }
}

/// A row whose dot slides across a track on hover, demoing one animation.
private struct DSMotionRow: View {
    let name: String
    let spec: String
    let animation: Animation
    @State private var moved = false

    var body: some View {
        DSSpecRow(token: name, value: spec) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.briefPaperSunken)
                    .frame(height: 24)
                Circle()
                    .fill(Color.briefHighlightDeep)
                    .frame(width: 18, height: 18)
                    .padding(.horizontal, 3)
                    .offset(x: moved ? 200 : 0)
            }
            .frame(width: 240, alignment: .leading)
            .clipShape(Capsule())
            .onHover { hovering in
                withAnimation(animation) { moved = hovering }
            }
        }
    }
}

struct DSProvenancePage: View {
    var body: some View {
        DSPageScaffold(title: "Provenance", subtitle: "Every fact carries its source. Eight sources, seven registers — each register a different narrative role, not just a different look.") {

            DSGroup(title: "The eight sources", note: "One Highlight-native (Meeting) plus seven Connections. Monochrome inline; brand color on dedicated surfaces.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                        HStack(spacing: BriefSpacing.xl) {
                            ForEach(BriefSource.allCases, id: \.self) { s in
                                VStack(spacing: BriefSpacing.sm) {
                                    BriefIcon(s, size: 22, rendering: .original)
                                    Text(s.label)
                                        .briefStyle(.caption)
                                        .foregroundStyle(Color.briefInkTertiary)
                                }
                                .frame(width: 64)
                            }
                        }
                    }
                }
            }

            DSGroup(title: "01 — Inline citation", note: "In-sentence evidence. Söhne Kraftig plus 0.5pt hairline. Hover for source preview.") {
                DSSpecimenCard {
                    ProvenanceLine {
                        "Sergei confirmed a "
                        src(.voice, "Founding Design Lead role")
                        " in a flat org during yesterdays call."
                    }
                }
            }

            DSGroup(title: "02 — Footnote chip", note: "Under-card metadata. Mono register, recedes.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        ProvenanceFootnote(source: .gmail,  pieces: ["paris", "2h ago"])
                        ProvenanceFootnote(source: .voice,  pieces: ["1on1 sergei", "yesterday 4pm"])
                        ProvenanceFootnote(source: .linear, pieces: ["v2 sprint", "updated 12m ago"])
                    }
                }
            }

            DSGroup(title: "03 — Attribution badge", note: "Block-level. Outlined for neutral, brand-filled for pinned.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                        HStack(spacing: BriefSpacing.md) {
                            ProvenanceBadge(source: .gmail, label: "paris 2h ago", filled: false)
                            ProvenanceBadge(source: .voice, label: "1on1 sergei", filled: false)
                        }
                        HStack(spacing: BriefSpacing.md) {
                            ProvenanceBadge(source: .gmail, label: "paris 2h ago", filled: true)
                            ProvenanceBadge(source: .notion, label: "strategy doc", filled: true)
                        }
                    }
                }
            }

            DSGroup(title: "04 — Header tag", note: "Section filtered to one source. Brand color or monochrome.") {
                DSSpecimenCard {
                    HStack(spacing: BriefSpacing.md) {
                        ProvenanceHeaderTag(source: .notion)
                        ProvenanceHeaderTag(source: .slack)
                        ProvenanceHeaderTag(source: .voice, rendering: .template)
                    }
                }
            }

            DSGroup(title: "05 — Stacked", note: "Multi-source cross-confirmation. The trust mechanism — confirmed across N sources.") {
                DSSpecimenCard {
                    ProvenanceLine {
                        "You "
                        stacked([.voice, .gmail, .notion], "wont report to Sam")
                        " — confirmed in three places."
                    }
                }
            }

            DSGroup(title: "06 — Favicon superscript", note: "Compact, source-identifiable. Brand color optional.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        ProvenanceFaviconSuperscript(
                            phrase: "v2 onboarding cutover is locked for Thursday",
                            sources: [.linear, .github, .slack]
                        )
                        ProvenanceFaviconSuperscript(
                            phrase: "Brand-color variant",
                            sources: [.gmail, .docs, .slack],
                            brandColor: true
                        )
                    }
                }
            }

            DSGroup(title: "07 — Brand-tint citation", note: "Phrase tinted with highlight ink. Pulls double duty with the brand-color thesis.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        ProvenanceBrandTint(source: .voice, phrase: "Founding Design Lead role")
                        ProvenanceBrandTint(source: .gmail, phrase: "Paris will follow up by EOD Friday")
                    }
                }
            }
        }
    }
}

struct DSPopoverPage: View {
    var body: some View {
        DSPageScaffold(title: "Popover", subtitle: "The hover preview that appears beside a cited phrase. Header identity, title, excerpt, and a click-to-open affordance. Light paper, never vibrancy.") {

            DSGroup(title: "Anatomy", note: "Source identity, timestamp, title, ellipsis-bookended excerpt, open affordance.") {
                DSSpecimenCard {
                    HStack(alignment: .top, spacing: BriefSpacing.xxxl) {
                        ProvenancePopoverView(preview: .placeholder(for: .voice, phrase: "Founding Design Lead role"))
                        VStack(alignment: .leading, spacing: BriefSpacing.md) {
                            anatomyNote("Header", "icon + source + timestamp on one line")
                            anatomyNote("Open affordance", "arrow animates up-right on hover; whole card is clickable")
                            anatomyNote("Title", "Söhne bodySmall — what this source IS")
                            anatomyNote("Excerpt", "ellipsis bookends + top/bottom fade = mid-document quote")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            DSGroup(title: "Across sources", note: "Same layout, different identity. Mono brands stay mono; Gmail / Docs / Slack carry brand color.") {
                DSSpecimenCard {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320, maximum: 360), spacing: BriefSpacing.xl, alignment: .top)],
                              alignment: .leading, spacing: BriefSpacing.xl) {
                        ForEach([BriefSource.gmail, .linear, .slack, .notion], id: \.self) { s in
                            ProvenancePopoverView(preview: .placeholder(for: s, phrase: s.label))
                        }
                    }
                }
            }

            DSGroup(title: "Live behavior", note: "Hover a citation for 250ms; move into the popover to keep it open; click to open the source.") {
                DSSpecimenCard {
                    ProvenanceLine {
                        "Sergei confirmed a "
                        src(.voice, "Founding Design Lead role")
                        " — hover to preview the meeting."
                    }
                }
            }
        }
    }

    private func anatomyNote(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .briefStyle(.label)
                .foregroundStyle(Color.briefInkPrimary)
            Text(body)
                .briefStyle(.meta)
                .foregroundStyle(Color.briefInkTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DSComposerPage: View {
    var body: some View {
        DSPageScaffold(title: "Chat composer", subtitle: "Where selection turns into action. A quiet icon at rest; on hover it grows into a composer with a context chip, an input, and quick actions.") {

            DSGroup(title: "Two states", note: "Hover the icon to expand. Mirrors Highlight's chat pattern — context chip row, input row, action row.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
                        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                            Text("Collapsed — rest")
                                .briefStyle(.label)
                                .foregroundStyle(Color.briefInkSecondary)
                            Text("Hover the chat icon below.")
                                .briefStyle(.meta)
                                .foregroundStyle(Color.briefInkTertiary)
                            ChatComposer(seedText: "Sergei confirmed a Founding Design Lead role in a flat org during yesterdays call.")
                        }
                    }
                }
            }

            DSGroup(title: "Quick actions", note: "Four composable actions surface on expand: Make task, Summarize, Copy, Share. Plus voice and mention in the input row.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        actionNote("Ask Highlight", "free-form question, selection becomes context")
                        actionNote("Make task", "convert the selection into a Linear / Reminders task")
                        actionNote("Summarize", "compress or expand the selected context")
                        actionNote("Copy / Share", "lift the text out, or hand it to Slack / email")
                    }
                }
            }
        }
    }

    private func actionNote(_ title: String, _ body: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
            Text(title)
                .briefStyle(.label)
                .foregroundStyle(Color.briefInkPrimary)
                .frame(width: 130, alignment: .leading)
            Text(body)
                .briefStyle(.meta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }
}

struct DSSelectionPage: View {
    var body: some View {
        DSPageScaffold(title: "Selection", subtitle: "Drag across lines to select. A warm-gray rubber-band shows the active region; touched lines join the selection; release floats the composer beside them.") {

            DSGroup(title: "Drag to select", note: "Drag across the margin or between lines. Click empty space to clear. Brand yellow is never used for selection — only warm gray.") {
                SelectionSurface {
                    VStack(alignment: .leading, spacing: BriefSpacing.xs) {
                        selLine("sel-1", "Sergei confirmed a Founding Design Lead role in a flat org.") {
                            "Sergei confirmed a "
                            src(.voice, "Founding Design Lead role")
                            " in a flat org."
                        }
                        selLine("sel-2", "Paris sent a follow up note before the team strategy doc was updated.") {
                            "Paris sent a "
                            src(.gmail, "follow up note")
                            " before the "
                            src(.notion, "team strategy doc")
                            " was updated."
                        }
                        selLine("sel-3", "Reviewed Mayas PR for onboarding flow and dropped a note in eng.") {
                            "Reviewed Mayas "
                            src(.github, "PR for onboarding flow")
                            " and dropped a "
                            src(.slack, "note in eng")
                            "."
                        }
                    }
                    .padding(BriefSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                            .fill(Color.briefPaperRaised)
                            .overlay(
                                RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                                    .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                            )
                    )
                }
                .frame(height: 320, alignment: .topLeading)
            }

            DSGroup(title: "Selection states", note: "Three warm-gray steps — never the brand highlight.") {
                DSSpecimenCard {
                    VStack(alignment: .leading, spacing: BriefSpacing.md) {
                        selStateRow("selectionRest",  .briefSelectionRest,  "selected line / rubber-band fill")
                        selStateRow("selectionHover", .briefSelectionHover, "hover / rubber-band stroke")
                        selStateRow("selectionActive", .briefSelectionActive, "committed nav selection")
                    }
                }
            }
        }
    }

    private func selLine(
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
                ProvenanceLine(segments: segs)
            }
        }
    }

    private func selStateRow(_ name: String, _ color: Color, _ note: String) -> some View {
        HStack(spacing: BriefSpacing.lg) {
            RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                .fill(color)
                .frame(width: 120, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                        .stroke(Color.briefHairline, lineWidth: 0.5)
                )
            Text(name)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkSecondary)
                .frame(width: 140, alignment: .leading)
            Text(note)
                .briefStyle(.meta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }
}

struct DSBriefSurfacePage: View {
    var body: some View {
        DSPageScaffold(title: "Brief surface", subtitle: "Every component composed into one page. Markdown hierarchy, inline provenance, selectable lines, and the daily-update card — the Brief as the user reads it.") {
            SelectionSurface {
                briefDocument
            }
            .frame(minHeight: 760, alignment: .topLeading)
        }
    }

    // The composed Brief — header, latest update, prioritized sections.
    private var briefDocument: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                Image(systemName: "folder")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.briefInkSecondary)
                BriefH1(text: "Today")
                Text("Wednesday, May 28")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
                Spacer()
            }

            // Latest-update card (the proactive brief)
            VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                HStack(spacing: BriefSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.briefHighlightDeep)
                    Text("This morning")
                        .briefStyle(.label)
                        .foregroundStyle(Color.briefInkPrimary)
                }
                Text("You committed to ship v2 onboarding by Thursday, the SF visit is locked for Tuesday 3pm, and Cartesia is waiting on your assignment. Three things need you today.")
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BriefSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(Color.briefHighlightWash.opacity(0.6))
            )
            .padding(.top, BriefSpacing.xl)

            // Section 1
            BriefH2(text: "1. Decisions waiting on you")
            briefBullets {
                briefBullet("d1", "Approve the v2 onboarding cutover for Thursday morning.") {
                    "Approve the "
                    stacked([.linear, .github], "v2 onboarding cutover")
                    " for Thursday morning."
                }
                briefBullet("d2", "Confirm the SF office visit time with Sergei.") {
                    "Confirm the SF office visit time with "
                    src(.gmail, "Sergei")
                    "."
                }
            }

            // Section 2
            BriefH2(text: "2. What I handled")
            briefBullets {
                briefBullet("h1", "Drafted the follow-up to Paris after yesterdays sync.") {
                    "Drafted the "
                    src(.gmail, "follow-up to Paris")
                    " after yesterdays sync."
                }
                briefBullet("h2", "Updated the v2 sprint plan from the customer call notes.") {
                    "Updated the "
                    src(.linear, "v2 sprint plan")
                    " from the "
                    src(.docs, "customer call notes")
                    "."
                }
            }

            // Section 3
            BriefH2(text: "3. Worth a look")
            briefBullets {
                briefBullet("w1", "Maya flagged an open question on the migration in eng.") {
                    "Maya flagged an "
                    src(.slack, "open question on the migration")
                    " in eng."
                }
            }
        }
        .padding(BriefSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaper)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        )
    }

    private func briefBullets<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BriefMarkdown.bulletTop) {
            content()
        }
        .padding(.top, BriefSpacing.sm)
    }

    private func briefBullet(
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

/// Embeds the legacy TypeSpecimenView so we don't lose any visual checks while
/// migrating to the new design system pages.
struct DSPlaygroundPage: View {
    var body: some View {
        TypeSpecimenView()
    }
}

// MARK: - Page scaffold
// Standard layout for every detail page — title row + subtitle + content.

struct DSPageScaffold<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: () -> Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
                VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                    BriefH1(text: title)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .briefStyle(.body)
                            .foregroundStyle(Color.briefInkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                content()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BriefSpacing.huge)
            .padding(.vertical, BriefSpacing.xxxl)
            .frame(maxWidth: 920, alignment: .topLeading)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    DesignSystemView()
        .environmentObject(SelectionContext())
        .frame(width: 1100, height: 800)
}
