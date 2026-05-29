import SwiftUI

// MARK: - Provenance system
// Six registers for showing where a fact came from. Each register is a
// different *narrative role*, not just a different visual style.
//
// 1. inline      [icon] [underlined phrase]                — citation in prose
// 2. mention     [icon] phrase                              — light reference, no underline
// 3. footnote    [icon] phrase  · MONO LABEL                — under-card metadata
// 4. badge       [ICON] LABEL (pill, uppercase)             — block-level attribution
// 5. headerTag   colored pill [icon] Source                 — section header
// 6. stacked     [icon icon icon] phrase                    — multi-source cross-confirmation

// MARK: - Color modes for icons within provenance

enum ProvenanceColorMode {
    case inkPrimary
    case inkSecondary
    case inkTertiary
    case brand           // full brand color
    case brandSubtle     // brand color at reduced saturation/opacity (for inline use)

    var iconRendering: BriefIconRendering {
        switch self {
        case .brand, .brandSubtle: return .original
        default:                   return .template
        }
    }

    var tint: Color? {
        switch self {
        case .inkPrimary:   return .briefInkPrimary
        case .inkSecondary: return .briefInkSecondary
        case .inkTertiary:  return .briefInkTertiary
        case .brand, .brandSubtle: return nil // use original
        }
    }

    var textColor: Color {
        switch self {
        case .inkPrimary, .brand:   return .briefInkPrimary
        case .inkSecondary:         return .briefInkSecondary
        case .inkTertiary:          return .briefInkTertiary
        case .brandSubtle:          return .briefInkPrimary
        }
    }
}

// MARK: - 1. Inline citation (Notion-style — thin underline + Kraftig weight)
// Rest: icon prefix + Kraftig-weight phrase + 0.5pt underline at low opacity.
// Hover: underline brightens, icon brightens. Constant padding — no shift.

struct ProvenanceInline: View {
    let source: BriefSource
    let phrase: String
    var color: ProvenanceColorMode = .inkPrimary
    var small: Bool = false
    /// When set, overrides the phrase font (so the editor's provenance type
    /// style drives weight/size). Falls back to the provenance token.
    var fontOverride: Font? = nil

    @State private var hovering = false
    @State private var phraseTriggered = false
    @State private var popoverHovering = false

    private var iconSize: CGFloat { small ? 11 : 12 }
    private var token: BriefTypeToken { small ? .provenanceSmall : .provenance }

    /// Popover is visible if the phrase triggered it OR the cursor is
    /// currently inside the popover itself (so moving from phrase → popover
    /// doesn't dismiss it).
    private var popoverBinding: Binding<Bool> {
        Binding(
            get: { phraseTriggered || popoverHovering },
            set: { newValue in
                if !newValue {
                    phraseTriggered = false
                    popoverHovering = false
                }
            }
        )
    }

    var body: some View {
        Button(action: openSource) {
            HStack(spacing: BriefSpacing.xs) {
                hoverAwareIcon(source: source, size: iconSize, restMode: color, hovering: hovering)
                    .offset(y: BriefLayout.InlineCitation.baselineNudge)
                // When an override font is supplied, set it directly (briefStyle
                // pins the font on the Text internally, so an outer .font() can't
                // win — the override must replace, not wrap, the style).
                Group {
                    if let f = fontOverride {
                        Text(phrase).font(f)
                    } else {
                        Text(phrase).briefStyle(token)
                    }
                }
                    .foregroundStyle(color.textColor)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(hovering
                                  ? Color.briefInkSecondary.opacity(BriefOpacity.lineStrong)
                                  : Color.briefInkTertiary.opacity(BriefOpacity.lineSoft))
                            .frame(height: BriefLayout.InlineCitation.underlineThickness)
                            .offset(y: BriefLayout.InlineCitation.underlineOffset)
                    }
            }
            .padding(.horizontal, BriefLayout.InlineCitation.paddingH)
            .padding(.vertical,   BriefLayout.InlineCitation.paddingV)
            // Hover signal is the underline alone — no background wash. One
            // signal, not two (the doubled bg+underline read as noisy).
            .contentShape(Rectangle())
        }
        .buttonStyle(ProvenancePressedStyle())
        .onHover { hovering = $0 }
        .delayedHover(triggered: $phraseTriggered)
        .popover(isPresented: popoverBinding, arrowEdge: .top) {
            ProvenancePopoverView(preview: .placeholder(for: source, phrase: phrase))
                .onHover { popoverHovering = $0 }
        }
    }

    private func openSource() {
        print("Open source: \(source.label) — \(phrase)")
    }
}

/// Pressed state: stronger highlight tint + slight scale-down for tactile feedback.
struct ProvenancePressedStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: BriefLayout.InlineCitation.cornerRadius, style: .continuous)
                    .fill(Color.briefHighlight.opacity(configuration.isPressed ? BriefOpacity.washMedium : 0))
                    .allowsHitTesting(false)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.briefInstant, value: configuration.isPressed)
    }
}

// MARK: - Highlighter swipe (the "marker stroke" background)
// Instant on / instant off — no animation. The hover state is a *signal*
// that there's a source here, not a motion event.

struct HighlighterSwipe: View {
    let visible: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: BriefLayout.InlineCitation.cornerRadius, style: .continuous)
            .fill(Color.briefHighlightWash)
            .opacity(visible ? 1 : 0)
    }
}

/// Icon rendering for inline provenance.
/// Voice icon: uses `briefHighlightDeep` (darker chromatic yellow-green
/// derived from E7FE0B) so the brand identity is carried into the icon
/// without being too bright on warm paper.
/// Connectors: rendered in their original brand color.
@ViewBuilder
private func hoverAwareIcon(source: BriefSource, size: CGFloat, restMode: ProvenanceColorMode, hovering: Bool) -> some View {
    switch source {
    case .voice:
        BriefIcon(source, size: size, rendering: .template)
            .foregroundStyle(Color.briefHighlightDeep)
    default:
        BriefIcon(source, size: size, rendering: .original)
            .opacity(hovering ? BriefOpacity.rest : BriefOpacity.active)
    }
}

// (source-specific hover tint removed — all sources share briefHighlightSoft background on hover)

// (Register 02 — Inline mention — removed.)

// MARK: - 11. Brand-tint citation
// Phrase text itself is tinted with the highlighter ink color (deep olive).
// Reads with chromatic difference from body — no underline, no chip.
// Hover: highlightSoft background pulses in.

struct ProvenanceBrandTint: View {
    let source: BriefSource
    let phrase: String
    var small: Bool = false

    @State private var hovering = false

    private var iconSize: CGFloat { small ? 11 : 12 }
    private var token: BriefTypeToken { small ? .provenanceSmall : .provenance }

    var body: some View {
        HStack(spacing: BriefSpacing.xs) {
            BriefIcon(source, size: iconSize, rendering: .template)
                .foregroundStyle(Color.briefHighlightInk)
                .opacity(hovering ? BriefOpacity.rest : BriefOpacity.inactive)
                .offset(y: BriefLayout.InlineCitation.baselineNudge)
            Text(phrase)
                .briefStyle(token)
                .foregroundStyle(Color.briefHighlightInk)
        }
        .padding(.horizontal, BriefLayout.InlineCitation.paddingH)
        .padding(.vertical,   BriefLayout.InlineCitation.paddingV)
        .background(
            RoundedRectangle(cornerRadius: BriefLayout.InlineCitation.cornerRadius, style: .continuous)
                .fill(hovering ? Color.briefHighlightSoft : Color.clear)
        )
        .animation(.briefHover, value: hovering)
        .onHover { hovering = $0 }
        .help(source.label)
    }
}

// (Register 12 — Contrast — removed.)
// (Register 13 — Chromatic — removed.)

// (Register 07 — Numbered superscript — removed.)
// (Register 08 — Hover-only magnifier — removed.)
// (Register 09 — Highlight + popover — removed.)

// MARK: - 10. Favicon-prefix superscript
// phrase ᴹ ᴺ — tiny source icons as superscript after a phrase.
// Like numbered but with brand identity instead of numbers.

struct ProvenanceFaviconSuperscript: View {
    let phrase: String
    let sources: [BriefSource]
    var small: Bool = false
    var brandColor: Bool = false

    private var token: BriefTypeToken { small ? .provenanceSmall : .provenance }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.xxs + 1) {
            Text(phrase)
                .briefStyle(token)
                .foregroundStyle(Color.briefInkPrimary)
            HStack(spacing: BriefSpacing.xxs) {
                ForEach(Array(sources.enumerated()), id: \.offset) { _, src in
                    FaviconBadge(source: src, brandColor: brandColor)
                }
            }
        }
    }
}

private struct FaviconBadge: View {
    let source: BriefSource
    let brandColor: Bool
    @State private var hovering = false

    var body: some View {
        Group {
            if brandColor {
                BriefIcon(source, size: 10, rendering: .original)
            } else {
                BriefIcon(source, size: 10, rendering: .template)
                    .foregroundStyle(Color.briefInkSecondary)
            }
        }
        .padding(BriefSpacing.xxs)
        .background(
            Circle()
                .fill(hovering ? Color.briefHighlightSoft : Color.briefPaperSunken)
        )
        .baselineOffset(BriefSpacing.xs)
        .animation(.briefHover, value: hovering)
        .onHover { hovering = $0 }
        .help(source.label)
    }
}

// MARK: - 3. Footnote chip
// Mono label + small icon for under-card metadata.
// Reads like: "[icon] gmail · paris · 2h ago"

struct ProvenanceFootnote: View {
    let source: BriefSource
    let pieces: [String]    // e.g. ["paris", "2h ago"]
    var color: ProvenanceColorMode = .inkTertiary

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            tintedIcon(source: source, size: BriefLayout.InlineIcon.small, mode: color)
            Text(([source.label.lowercased()] + pieces).joined(separator: " · "))
                .briefStyle(.monoMeta)
                .foregroundStyle(color.textColor)
        }
    }
}

// MARK: - 4. Attribution badge
// Pill-shaped, uppercase mono label. For block-level attribution
// (e.g., a quoted blockquote with "FROM GMAIL · 2H AGO" badge below).

struct ProvenanceBadge: View {
    let source: BriefSource
    let label: String
    var filled: Bool = false       // true = brand-color fill; false = outlined
    var color: ProvenanceColorMode = .inkPrimary

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            tintedIcon(source: source, size: 10, mode: filled ? .brand : color)
            Text("\(source.label) · \(label)".uppercased())
                .briefStyle(.monoMeta)
                .foregroundStyle(filled ? .briefInkPrimary : color.textColor)
                .tracking(0.6)
        }
        .padding(.horizontal, BriefSpacing.md)
        .padding(.vertical,   BriefSpacing.xs)
        .background(
            Capsule()
                .fill(filled ? Color.briefHighlightSoft : Color.briefPaperSunken)
                .overlay(
                    Capsule().stroke(Color.briefHairline, lineWidth: filled ? 0 : BriefLayout.Card.strokeWidth)
                )
        )
    }
}

// MARK: - 5. Header tag
// Larger pill for section headers — "this section is filtered to Notion".

struct ProvenanceHeaderTag: View {
    let source: BriefSource
    var rendering: BriefIconRendering = .original

    var body: some View {
        HStack(spacing: BriefSpacing.md) {
            BriefIcon(source, size: BriefLayout.InlineIcon.medium, rendering: rendering)
            Text(source.label)
                .briefStyle(.label)
                .foregroundStyle(Color.briefInkPrimary)
        }
        .padding(.horizontal, BriefSpacing.md + 2)
        .padding(.vertical,   BriefSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BriefSpacing.sm, style: .continuous)
                .fill(Color.briefPaperSunken)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefSpacing.sm, style: .continuous)
                        .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        )
    }
}

// MARK: - 6. Stacked sources (multi-source cross-confirmation)
// Multiple icons stacked / clustered before a phrase. Visually
// communicates "this is confirmed across N sources".

struct ProvenanceStacked: View {
    let sources: [BriefSource]
    let phrase: String
    var color: ProvenanceColorMode = .inkPrimary
    var small: Bool = false
    var brandIcons: Bool = false   // true = render icons in brand color

    private var iconSize: CGFloat { small ? 12 : 14 }
    private var token: BriefTypeToken { small ? .provenanceSmall : .provenance }

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            HStack(spacing: -BriefSpacing.xs) {
                ForEach(Array(sources.enumerated()), id: \.offset) { idx, src in
                    let mode: ProvenanceColorMode = brandIcons ? .brand : color
                    tintedIcon(source: src, size: iconSize, mode: mode)
                        .frame(width: iconSize + 2, height: iconSize + 2)
                        .background(
                            Circle().fill(Color.briefPaper)
                        )
                        .overlay(
                            Circle().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                        )
                        .zIndex(Double(sources.count - idx))
                }
            }
            Text(phrase)
                .briefStyle(token)
                .foregroundStyle(color.textColor)
                .underline(true, color: Color.briefInkSecondary.opacity(BriefOpacity.lineStandard - 0.1))
        }
        .help("Confirmed across: " + sources.map(\.label).joined(separator: ", "))
    }
}

// MARK: - Helper: tinted icon respecting color mode

@ViewBuilder
private func tintedIcon(source: BriefSource, size: CGFloat, mode: ProvenanceColorMode) -> some View {
    if let tint = mode.tint {
        BriefIcon(source, size: size, rendering: .template)
            .foregroundStyle(tint)
    } else {
        BriefIcon(source, size: size, rendering: .original)
            .opacity(mode == .brandSubtle ? BriefOpacity.inactive + 0.1 : BriefOpacity.rest)
    }
}

// MARK: - Legacy alias (keep older call sites working)

typealias ProvenanceTag = ProvenanceInline

// MARK: - Inline prose builder
// Lets a sentence flow with mixed text + provenance fragments.

struct ProvenanceLine: View {
    let segments: [ProvenanceSegment]
    let small: Bool
    /// Color for plain `.text` segments. Defaults to inkPrimary. Set to
    /// inkSecondary to recede the value behind a `.label` lead-in — color
    /// carries the hierarchy so the label stays medium-weight (not bold).
    var textColor: Color = .briefInkPrimary

    init(small: Bool = false, textColor: Color = .briefInkPrimary, @ProvenanceLineBuilder _ build: () -> [ProvenanceSegment]) {
        self.segments = build()
        self.small = small
        self.textColor = textColor
    }

    /// Direct-array init for callers that pre-compose segments (e.g. helper
    /// functions that need to forward a result-builder closure).
    init(segments: [ProvenanceSegment], small: Bool = false, textColor: Color = .briefInkPrimary) {
        self.segments = segments
        self.small = small
        self.textColor = textColor
    }

    var body: some View {
        // Body text segments use the body token (Söhne Buch).
        // Source segments use the heavier provenance token via their own view.
        let bodyToken = small ? BriefTypeToken.bodySmall : .body
        FlowLayout(spacing: 0, lineSpacing: 6) {
            ForEach(segments.indices, id: \.self) { i in
                switch segments[i] {
                case .text(let s):
                    Text(s)
                        .briefStyle(bodyToken)
                        .foregroundStyle(textColor)
                case .label(let s):
                    // Lead-in label (e.g. "Status:"). Medium (Kraftig 500) at
                    // body size — present but calm; doesn't shout like Halbfett.
                    Text(s)
                        .briefStyle(.bodyMedium)
                        .foregroundStyle(Color.briefInkPrimary)
                case .source(let src, let phrase):
                    ProvenanceInline(source: src, phrase: phrase, small: small)
                case .stacked(let srcs, let phrase):
                    ProvenanceStacked(sources: srcs, phrase: phrase, small: small)
                }
            }
        }
    }
}

// MARK: - ProvenanceProse — prose renderer (width-aware, wraps natively)
// Same segment model as ProvenanceLine, but laid out by BriefProseLayout
// instead of FlowLayout, so text runs wrap mid-segment and the line leading is
// the single token source. Use this for body prose; keep ProvenanceLine/
// FlowLayout for atomic chip rows. See MARKDOWN_RENDERING_ARCHITECTURE.md.

struct ProvenanceProse: View {
    let segments: [ProvenanceSegment]
    var small: Bool = false
    var textColor: Color = .briefInkPrimary
    /// Weight for `.label` lead-ins. Defaults to medium; pass `.body` to let
    /// color (not weight) carry the label hierarchy for a lighter page.
    var labelToken: BriefTypeToken = .bodyMedium

    init(small: Bool = false, textColor: Color = .briefInkPrimary, labelToken: BriefTypeToken = .bodyMedium, @ProvenanceLineBuilder _ build: () -> [ProvenanceSegment]) {
        self.segments = build()
        self.small = small
        self.textColor = textColor
        self.labelToken = labelToken
    }
    init(segments: [ProvenanceSegment], small: Bool = false, textColor: Color = .briefInkPrimary, labelToken: BriefTypeToken = .bodyMedium) {
        self.segments = segments
        self.small = small
        self.textColor = textColor
        self.labelToken = labelToken
    }

    var body: some View {
        let token: BriefTypeToken = small ? .bodySmall : .body
        let leading = (token.lineHeight - 1) * token.size   // single leading source
        BriefProseLayout(lineGap: leading) {
            ForEach(segments.indices, id: \.self) { i in
                switch segments[i] {
                case .text(let s):
                    Text(s).briefStyle(token).foregroundStyle(textColor)
                case .label(let s):
                    Text(s).briefStyle(labelToken).foregroundStyle(Color.briefInkPrimary)
                case .source(let src, let phrase):
                    ProvenanceInline(source: src, phrase: phrase, small: small)
                case .stacked(let srcs, let phrase):
                    ProvenanceStacked(sources: srcs, phrase: phrase, small: small)
                }
            }
        }
    }
}

enum ProvenanceSegment {
    case text(String)
    case label(String)   // bold lead-in label (e.g. "Status:")
    case source(BriefSource, String)
    case stacked([BriefSource], String)
}

@resultBuilder
enum ProvenanceLineBuilder {
    static func buildBlock(_ components: ProvenanceSegment...) -> [ProvenanceSegment] { components }
    static func buildExpression(_ s: String) -> ProvenanceSegment { .text(s) }
    static func buildExpression(_ s: ProvenanceSegment) -> ProvenanceSegment { s }
}

func label(_ text: String) -> ProvenanceSegment {
    .label(text)
}

func src(_ source: BriefSource, _ phrase: String) -> ProvenanceSegment {
    .source(source, phrase)
}

func stacked(_ sources: [BriefSource], _ phrase: String) -> ProvenanceSegment {
    .stacked(sources, phrase)
}

// MARK: - Flow layout (unchanged)

struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    var lineSpacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth, lineWidth > 0 {
                totalWidth = max(totalWidth, lineWidth)
                totalHeight += lineHeight + lineSpacing
                lineWidth = 0
                lineHeight = 0
            }
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalWidth = max(totalWidth, lineWidth)
        totalHeight += lineHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxX = bounds.maxX
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            sv.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
