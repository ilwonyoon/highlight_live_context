import SwiftUI

struct TypeSpecimenView: View {
    @State private var page: SpecimenPage = .provenance
    @State private var register: Int = 1
    @State private var scrollAnchor: Int = 1  // 1 = top, 4 = jump to register 4

    enum SpecimenPage: String, CaseIterable {
        case provenance = "Provenance"
        case colorModes = "Color modes"
        case typography = "Typography"
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
                        }
                    }
                    .padding(.horizontal, 64)
                    .padding(.vertical, 40)
                    .frame(maxWidth: 880, alignment: .leading)
                }
                .onChange(of: scrollAnchor) { _, newVal in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo("reg\(newVal)", anchor: .top)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 4) {
                        ForEach(1...13, id: \.self) { i in
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
            register2
            register3
            register4
            register5
            register6
            register7
            register8
            register9
            register10
            register11
            register12
            register13
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
            register2.id("reg2")
            register3.id("reg3")
            register4.id("reg4")
            register5.id("reg5")
            register6.id("reg6")
            register7.id("reg7")
            register8.id("reg8")
            register9.id("reg9")
            register10.id("reg10")
            register11.id("reg11")
            register12.id("reg12")
            register13.id("reg13")
        }
    }

    private func registerName(_ n: Int) -> String {
        switch n {
        case 1: return "Inline"
        case 2: return "Mention"
        case 3: return "Footnote"
        case 4: return "Badge"
        case 5: return "Header tag"
        default: return "Stacked"
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

    private var register2: some View {
        registerBlock(
            number: 2,
            name: "Inline mention — hover promotes",
            purpose: "Rest: almost invisible — icon faint, text in secondary ink, reads as plain prose. Hover: promotes to inline citation appearance. For casual references that shouldnt disrupt reading."
        ) {
            ProvenanceLine {
                "Saw the update in "
                mention(.slack, "number leadership")
                " this morning."
            }
            ProvenanceLine {
                "Maya is heads down on the migration thread — last touched in "
                mention(.cursor, "her agent session")
                " yesterday."
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

    private var register7: some View {
        registerBlock(
            number: 7,
            name: "Numbered superscript — Perplexity style",
            purpose: "Small numbered badges after a claim. Best when many sources need to cite densely. Hover a badge to highlight its source card."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ProvenanceNumbered(
                    phrase: "Sergei confirmed the Founding Design Lead role in a flat org",
                    sources: [.voice, .gmail]
                )
                ProvenanceNumbered(
                    phrase: "v2 onboarding cutover is locked for Thursday",
                    sources: [.linear, .github, .slack],
                    startNumber: 3
                )
                Text("Numbers map to a source rail or sidebar (not shown). Hover any number to preview.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private var register8: some View {
        registerBlock(
            number: 8,
            name: "Hover-only magnifier — Granola style",
            purpose: "Rest: text is plain, zero decoration. Hover: a small source icon button fades in beside the text. Most aggressive at preserving reading flow."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ProvenanceMagnifier(
                    source: .voice,
                    phrase: "Sergei confirmed a Founding Design Lead role in a flat org"
                )
                ProvenanceMagnifier(
                    source: .gmail,
                    phrase: "Paris sent a follow up note before the strategy doc was updated"
                )
                ProvenanceMagnifier(
                    source: .linear,
                    phrase: "v2 sprint plan updated 12 minutes ago"
                )
                Text("Closest spirit to Highlights existing voice waveform icon. Hover over any line.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private var register9: some View {
        registerBlock(
            number: 9,
            name: "Highlight + popover — Sana / Adobe style",
            purpose: "Text has subtle highlight background using the brand yellow trace. Click would open popover with source excerpt. Honors the highlighter metaphor literally."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ProvenanceHighlight(
                    source: .voice,
                    phrase: "Founding Design Lead role in a flat org"
                )
                ProvenanceHighlight(
                    source: .gmail,
                    phrase: "Paris will follow up by EOD Friday"
                )
                ProvenanceHighlight(
                    source: .notion,
                    phrase: "team strategy doc, section 3, ownership matrix"
                )
                Text("Strongest visual presence. Pulls double duty with the brand-color thesis.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
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

    private var register12: some View {
        registerBlock(
            number: 12,
            name: "Contrast — source bold, body downshifted",
            purpose: "Provenance stays at full ink primary. Body text around it is rendered at ink secondary. Citations stand out by typographic *contrast* alone — no decoration, no color. The most minimal approach."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                FlowLayout(spacing: 0, lineSpacing: 6) {
                    Text("Sergei confirmed a ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkSecondary)
                    ProvenanceContrastBold(source: .voice, phrase: "Founding Design Lead role")
                    Text(" in a flat org during yesterdays call.")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkSecondary)
                }
                FlowLayout(spacing: 0, lineSpacing: 6) {
                    Text("Paris sent a ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkSecondary)
                    ProvenanceContrastBold(source: .gmail, phrase: "follow up note")
                    Text(" before the ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkSecondary)
                    ProvenanceContrastBold(source: .notion, phrase: "team strategy doc")
                    Text(" was updated.")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkSecondary)
                }
                Text("Body around provenance is intentionally one ink step down. Provenance reads as the load-bearing word.")
                    .briefStyle(.meta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
    }

    private var register13: some View {
        registerBlock(
            number: 13,
            name: "Chromatic — source-colored text",
            purpose: "Phrase text itself tinted with the sources brand color. Most visually rich — but watch for rainbow effect when many sources appear in one sentence."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                FlowLayout(spacing: 0, lineSpacing: 6) {
                    Text("Sergei confirmed a ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .voice, phrase: "Founding Design Lead role")
                    Text(" in a flat org. Paris sent a ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .gmail, phrase: "follow up note")
                    Text(" before the ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .notion, phrase: "team strategy doc")
                    Text(" was updated.")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                }
                FlowLayout(spacing: 0, lineSpacing: 6) {
                    Text("Mayas ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .github, phrase: "PR for onboarding")
                    Text(" was merged, and the ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .linear, phrase: "v2 sprint plan")
                    Text(" reflects the change. ")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                    ProvenanceChromatic(source: .slack, phrase: "Thread in eng-leads")
                    Text(" has the full discussion.")
                        .briefStyle(.provenance)
                        .foregroundStyle(Color.briefInkPrimary)
                }
                Text("Source palette: voice = olive, gmail = red, docs = blue, slack = pink, linear = indigo, others = ink primary.")
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
}

#Preview {
    TypeSpecimenView()
        .frame(width: 900, height: 1400)
}
