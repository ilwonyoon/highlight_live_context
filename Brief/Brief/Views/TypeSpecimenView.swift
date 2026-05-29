import SwiftUI

struct TypeSpecimenView: View {
    @State private var page: SpecimenPage = .provenance
    @State private var register: Int = 1
    @State private var scrollAnchor: Int = 1  // 1 = top, 4 = jump to register 4

    enum SpecimenPage: String, CaseIterable {
        case provenance = "Provenance"
        case colorModes = "Color modes"
        case typography = "Typography"
        case selection  = "Selection"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 18) {
                header
                Picker("", selection: $page) {
                    ForEach(SpecimenPage.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 420)
            }
            .padding(.horizontal, 64)
            .padding(.top, 56)
            .padding(.bottom, 24)

            Divider().background(Color.briefDivider)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        switch page {
                        case .provenance:
                            provenanceShowcaseWithAnchors
                        case .colorModes:
                            colorModesShowcase
                        case .typography:
                            typographyTokens
                        case .selection:
                            selectionShowcase
                        }
                    }
                    .padding(.horizontal, 64)
                    .padding(.vertical, 40)
                    .frame(maxWidth: 880, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .onChange(of: scrollAnchor) { _, newVal in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo("reg\(newVal)", anchor: .top)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 4) {
                        ForEach(1...7, id: \.self) { i in
                            Button("\(i)") { scrollAnchor = i }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                        }
                    }
                    .padding(8)
                    .background(Color.briefPaperRaised.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.briefPaper)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief — Type Specimen")
                .briefStyle(.heroMedium)
                .foregroundStyle(Color.briefInkPrimary)
            Text("Sohne workhorse, Sohne Mono metadata, eight sources of provenance. Warm paper background.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
        }
    }

    // MARK: - Provenance — six registers

    private var provenanceShowcase: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Provenance — six registers")
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Same eight sources, six narrative roles. Pick the ones that fit Brief.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            register1
            register3
            register4
            register5
            register6
            register10
            register11
        }
    }

    private var provenanceShowcaseWithAnchors: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Provenance — six registers")
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Same eight sources, six narrative roles. Pick the ones that fit Brief.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            register1.id("reg1")
            register3.id("reg2")
            register4.id("reg3")
            register5.id("reg4")
            register6.id("reg5")
            register10.id("reg6")
            register11.id("reg7")
        }
    }

    private func registerName(_ n: Int) -> String {
        switch n {
        case 1: return "Inline"
        case 2: return "Footnote"
        case 3: return "Badge"
        case 4: return "Header tag"
        case 5: return "Stacked"
        case 6: return "Favicon"
        default: return "Brand tint"
        }
    }

    private var register1: some View {
        registerBlock(
            number: 1,
            name: "Inline citation — Notion style",
            purpose: "Söhne Kraftig + 0.5pt hairline underline. Rest: icons in their brand color (Voice = E7FE0B). Hover: single unified background tint (briefHighlightSoft, 45% E7FE0B), voice icon inverts to ink for contrast on the yellow background."
        ) {
            ProvenanceLine {
                "Sergei confirmed a "
                src(.voice, "Founding Design Lead role")
                " in a flat org during yesterdays call."
            }
            ProvenanceLine {
                "Paris sent a "
                src(.gmail, "follow up note")
                " before the "
                src(.notion, "team strategy doc")
                " was updated."
            }
            ProvenanceLine {
                "Reviewed Mayas "
                src(.github, "PR for onboarding flow")
                " and dropped a "
                src(.slack, "note in number eng")
                " about the open question."
            }
        }
    }

    private var register3: some View {
        registerBlock(
            number: 3,
            name: "Footnote chip",
            purpose: "Under-card metadata. Mono label register. Compact, recedes from the eye. For card footers / list-item annotations."
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ProvenanceFootnote(source: .gmail,  pieces: ["paris", "2h ago"])
                ProvenanceFootnote(source: .voice,  pieces: ["1:1 with sergei", "yesterday 4pm"])
                ProvenanceFootnote(source: .linear, pieces: ["v2 sprint", "updated 12m ago"])
                ProvenanceFootnote(source: .notion, pieces: ["strategy doc", "1d ago"])
            }
        }
    }

    private var register4: some View {
        registerBlock(
            number: 4,
            name: "Attribution badge",
            purpose: "Block-level. Pill, uppercase mono. For when an entire quote or summary belongs to one source. Two variants — outlined and brand-filled."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ProvenanceBadge(source: .gmail,  label: "paris · 2h ago", filled: false)
                    ProvenanceBadge(source: .voice,  label: "1:1 sergei · y day", filled: false)
                    ProvenanceBadge(source: .notion, label: "strategy doc · 1d", filled: false)
                }
                HStack(spacing: 12) {
                    ProvenanceBadge(source: .gmail,  label: "paris · 2h ago", filled: true)
                    ProvenanceBadge(source: .voice,  label: "1:1 sergei · y day", filled: true)
                }
                Text("Outlined for neutral attribution. Brand-filled for highlighted or pinned context.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private var register5: some View {
        registerBlock(
            number: 5,
            name: "Header tag",
            purpose: "Section header. Larger pill, brand-colored icon. For surfaces filtered to a single source — all Slack threads, Notion-only view, etc."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ProvenanceHeaderTag(source: .notion)
                    ProvenanceHeaderTag(source: .gmail)
                    ProvenanceHeaderTag(source: .linear)
                    ProvenanceHeaderTag(source: .slack)
                }
                HStack(spacing: 12) {
                    ProvenanceHeaderTag(source: .voice, rendering: .template)
                    ProvenanceHeaderTag(source: .github, rendering: .template)
                    ProvenanceHeaderTag(source: .docs, rendering: .template)
                    ProvenanceHeaderTag(source: .cursor, rendering: .template)
                }
                Text("Top row: brand color. Bottom row: monochrome variant when the surface itself is already source-aware.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private var register6: some View {
        registerBlock(
            number: 6,
            name: "Stacked — multi-source confirmation",
            purpose: "Multiple icons clustered before a phrase. Says this is confirmed across N sources — Highlights real trust mechanism. Strong candidate for AI-marked-as-mattering moments."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ProvenanceLine {
                    "You "
                    stacked([.voice, .gmail, .notion], "wont report to Sam")
                    " — confirmed in three places."
                }
                ProvenanceLine {
                    "The "
                    stacked([.linear, .github], "v2 onboarding cutover")
                    " is locked for Thursday."
                }
                ProvenanceLine {
                    "Heidi Health is "
                    stacked([.voice, .gmail, .docs, .slack], "all about trust")
                    " across every conversation this week."
                }
                HStack(spacing: 12) {
                    Text("Brand-color variant:")
                        .briefStyle(.meta)
                        .foregroundStyle(Color.briefInkTertiary)
                    ProvenanceStacked(
                        sources: [.voice, .gmail, .notion],
                        phrase: "wont report to Sam",
                        brandIcons: true
                    )
                }
            }
        }
    }

    private var register10: some View {
        registerBlock(
            number: 10,
            name: "Favicon superscript",
            purpose: "Like numbered (07) but with brand identity instead of numbers — tiny source icons trail the phrase. Compact, source-identifiable at a glance."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ProvenanceFaviconSuperscript(
                    phrase: "Sergei confirmed the Founding Design Lead role in a flat org",
                    sources: [.voice, .gmail]
                )
                ProvenanceFaviconSuperscript(
                    phrase: "v2 onboarding cutover is locked for Thursday",
                    sources: [.linear, .github, .slack]
                )
                ProvenanceFaviconSuperscript(
                    phrase: "Brand-color variant — Gmail / Docs / Slack pop, others stay monochrome",
                    sources: [.gmail, .docs, .slack],
                    brandColor: true
                )
            }
        }
    }

    private var register11: some View {
        registerBlock(
            number: 11,
            name: "Brand-tint citation",
            purpose: "Phrase text is tinted with the highlighter ink color (deep olive of E7FE0B). No underline, no chip. Pulls double duty with the brand-color thesis. Hover adds soft highlight pulse."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ProvenanceLine {
                    "Sergei confirmed a "
                    src(.voice, "Founding Design Lead role")
                    " in a flat org during yesterdays call."
                }
                ProvenanceBrandTint(source: .voice, phrase: "Founding Design Lead role")
                ProvenanceBrandTint(source: .gmail, phrase: "Paris will follow up by EOD Friday")
                ProvenanceBrandTint(source: .notion, phrase: "team strategy doc, section 3, ownership matrix")
                Text("Note: line 1 is reg 01 for comparison. The three lines below are the brand-tint variant.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private func registerBlock<Content: View>(
        number: Int,
        name: String,
        purpose: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("0\(number)")
                    .briefStyle(.monoLabel)
                    .foregroundStyle(Color.briefInkTertiary)
                Text(name)
                    .briefStyle(.headline)
                    .foregroundStyle(Color.briefInkPrimary)
            }
            Text(purpose)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkSecondary)
                .frame(maxWidth: 620, alignment: .leading)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.briefHairline, lineWidth: 0.5)
                    )
            )
        }
    }

    // MARK: - Color modes catalog

    private var colorModesShowcase: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Color modes")
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Same icon, different intent. Brand color is opt-in per call site.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            VStack(alignment: .leading, spacing: 14) {
                colorModeRow(label: "Ink primary",   mode: .inkPrimary)
                colorModeRow(label: "Ink secondary", mode: .inkSecondary)
                colorModeRow(label: "Ink tertiary",  mode: .inkTertiary)
                colorModeRow(label: "Brand",         mode: .brand)
                colorModeRow(label: "Brand subtle",  mode: .brandSubtle)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.briefHairline, lineWidth: 0.5)
                    )
            )
        }
    }

    private func colorModeRow(label: String, mode: ProvenanceColorMode) -> some View {
        HStack(spacing: 16) {
            Text(label)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: 130, alignment: .leading)
            HStack(spacing: 18) {
                ForEach(BriefSource.allCases, id: \.self) { src in
                    ProvenanceInline(source: src, phrase: src.label, color: mode)
                }
            }
        }
    }

    // MARK: - Typography tokens (kept compact)

    private var typographyTokens: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Typography reference")
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Family hero (specimen title above) + Sohne workhorse + Sohne Mono metadata.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            VStack(alignment: .leading, spacing: 14) {
                sample("This is title 1",     token: .title1,    caption: "title1     28pt  Sohne Kraftig")
                sample("This is title 2",     token: .title2,    caption: "title2     22pt  Sohne Kraftig")
                sample("This is title 3",     token: .title3,    caption: "title3     17pt  Sohne Halbfett")
                sample("This is headline",    token: .headline,  caption: "headline   14pt  Sohne Halbfett")
                sample(bodyParagraph,         token: .body,      caption: "body       14pt  Sohne Buch    line 1.45")
                sample("Form label",          token: .label,     caption: "label      12pt  Sohne Kraftig")
                sample("Metadata 11pt",       token: .meta,      caption: "meta       11pt  Sohne Buch")
                sample("0928 AM   May 28",    token: .monoLabel, caption: "monoLabel  11pt  Mono Buch")
            }
        }
    }

    private func sample(_ text: String, token: BriefTypeToken, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .briefStyle(token)
                .foregroundStyle(Color.briefInkPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(caption)
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }

    private let bodyParagraph = "The brief is yesterdays lived context, compressed into what you need to decide today. Selective deepening where action requires more than memory."

    // MARK: - Selection + ChatComposer showcase

    private var selectionShowcase: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Selection + ChatComposer")
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Drag across one or more lines to select. A rubber-band rectangle shows the active region; every line whose frame is touched joins the selection. Release to lock; the chat composer floats beside the selection.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            SelectionSurface {
                liveContextFakeContent
            }
            .frame(height: 920, alignment: .topLeading)

            Text("Try: drag across the margin or between lines to multi-select. Click empty space to clear.")
                .briefStyle(.meta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }

    // MARK: - Fake Live Context content
    // Hierarchy follows BriefMarkdown semantic mapping:
    //   H1  workspace title
    //   H2  numbered sections (1. PRIMARY GOAL, 2. TOP TIER PRIORITIES, ...)
    //   H3  sub-groups (1. Highlight (Highlighter, Inc.), 2. Cartesia, ...)
    //   H4  bullet-group lead-in (Next Steps)
    //   •   bullet (SelectableLine)

    private var liveContextFakeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header strip: workspace title + count
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                Image(systemName: "folder")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.briefInkSecondary)
                BriefH1(text: "Default")
                Text("20 highlights")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
                Spacer()
            }

            // Latest update card
            VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                HStack(spacing: BriefSpacing.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.briefHighlightDeep)
                    Text("Latest update")
                        .briefStyle(.label)
                        .foregroundStyle(Color.briefInkPrimary)
                    Text("5/28/2026, 1:56 PM")
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                }
                Text("Ilwon has officially designated Highlight as his number one priority and Cartesia as number two, while dropping the Bondi Studio track to focus his efforts. He has completed a meeting with Highlights Head of Engineering and is preparing a take-home assignment and an in-person San Francisco visit for next Tuesday June 2nd.")
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BriefSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(Color.briefHighlightWash.opacity(0.6))
            )
            .padding(.top, BriefSpacing.xl)

            // Live Context sub-title
            Text("Live Context — Ilwon Yoon")
                .briefStyle(.headline)
                .foregroundStyle(Color.briefInkSecondary)
                .padding(.top, BriefSpacing.xxl)

            // 1. PRIMARY GOAL
            BriefH2(text: "1. PRIMARY GOAL — EMPLOYMENT (Top Priority)")

            bullets {
                bullet("primary-target", text: "Target Role — Founding Design Lead / Product Design Lead at an early-stage AI-native startup.") {
                    bulletText("Target Role — ")
                    src(.voice, "Founding Design Lead / Product Design Lead")
                    " at an early-stage AI-native startup."
                }
                bullet("primary-value", text: "Core Value Prop — Expert in AI-augmented product design and reducing coordination tax via agentic workflows.") {
                    bulletText("Core Value Prop — Expert in ")
                    src(.voice, "AI-augmented product design")
                    " and reducing coordination tax via agentic workflows."
                }
                bullet("primary-location", text: "Location — San Jose CA willing to commute to SF.") {
                    bulletText("Location — San Jose, CA (willing to ")
                    src(.voice, "commute to SF")
                    ")."
                }
            }

            // 2. TOP TIER PRIORITIES
            BriefH2(text: "2. TOP TIER PRIORITIES (Ranked by User)")

            BriefH3(text: "1. Highlight (Highlighter, Inc.)")
            bullets {
                bullet("hl-status", text: "Status — Number one priority opportunity with strong vision alignment.") {
                    bulletText("Status — ")
                    src(.voice, "Number one priority opportunity")
                    " with strong vision alignment."
                }
                bullet("hl-role", text: "Role Alignment — Sergei CEO confirmed a Founding Design Lead role in a flat org. Ilwon wont report to Sam.") {
                    bulletText("Role Alignment — Sergei (CEO) confirmed a ")
                    src(.voice, "Founding Design Lead role")
                    " in a flat org. Ilwon "
                    src(.voice, "wont report to Sam")
                    "."
                }
                bullet("hl-progress", text: "Progress — Completed meeting with Paris Head of Engineering; conversation was technically detailed and went well.") {
                    bulletText("Progress — Completed meeting with ")
                    src(.voice, "Paris (Head of Engineering)")
                    "; conversation was technically detailed and went well."
                }
            }

            BriefH4(text: "Next Steps")
            bullets {
                bullet("hl-next-1", text: "Submitting the take-home assignment next Tuesday June 2nd.", indent: 1) {
                    bulletText("Submitting the ")
                    src(.gmail, "take-home assignment")
                    " next Tuesday (June 2nd)."
                }
                bullet("hl-next-2", text: "Visiting the SF office to meet Sergei in person on Tuesday afternoon 3 PM.", indent: 1) {
                    bulletText("Visiting the SF office to ")
                    src(.gmail, "meet Sergei in person")
                    " on Tuesday afternoon (3:00 PM)."
                }
                bullet("hl-next-3", text: "Jacob to coordinate extending the visit to potentially present the assignment results the same day.", indent: 1) {
                    bulletText("Jacob to coordinate ")
                    src(.gmail, "extending the visit")
                    " to potentially present the assignment results the same day."
                }
            }

            BriefH3(text: "2. Cartesia")
            bullets {
                bullet("cart-status", text: "Status — Top two choice alongside Highlight.") {
                    bulletText("Status — ")
                    src(.voice, "Top two choice")
                    " alongside Highlight."
                }
                bullet("cart-next", text: "Next Step — Plans to focus on the Cartesia assignment later this week after completing Highlights tasks.") {
                    bulletText("Next Step — Plans to focus on the ")
                    src(.gmail, "Cartesia assignment")
                    " later this week after completing Highlights tasks."
                }
            }

            // 3. ACTIVE PIPELINE
            BriefH2(text: "3. ACTIVE PIPELINE")

            BriefH3(text: "Fabrion")
            bullets {
                bullet("fab-status", text: "Status — Founding Designer evaluation.") {
                    bulletText("Status — ")
                    src(.voice, "Founding Designer evaluation")
                    "."
                }
                bullet("fab-assess", text: "Assessment — Ilwon considers it the most promising product seen recently due to its full-stack enterprise AI approach.") {
                    bulletText("Assessment — Ilwon considers it the ")
                    src(.voice, "most promising product")
                    " seen recently due to its "
                    src(.voice, "full-stack enterprise AI approach")
                    "."
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

    /// Wraps a sequence of bullets in a VStack with consistent bullet spacing.
    private func bullets<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BriefMarkdown.bulletTop) {
            content()
        }
        .padding(.top, BriefSpacing.sm)
    }

    /// A single bullet row with provenance content; wrapped in SelectableLine.
    private func bullet(
        _ id: String,
        text: String,
        indent: Int = 0,
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
            .padding(.leading, CGFloat(indent) * BriefMarkdown.indentStep)
        }
    }

    /// Helper to make body text segment with the same styling defaults
    /// when composed inside ProvenanceLine.
    private func bulletText(_ s: String) -> ProvenanceSegment { .text(s) }
}

#Preview {
    TypeSpecimenView()
        .frame(width: 900, height: 1400)
}
