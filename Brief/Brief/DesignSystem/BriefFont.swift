import SwiftUI

// MARK: - Font family names
// These match the PostScript names of the Klim test fonts after registration.
// Test fonts use the prefix "Test" — when licensed, swap to production names.

enum BriefFontFamily {
    static let soehne = "TestSohne"      // PostScript drops umlaut
    static let soehneMono = "TestSohneMn" // PostScript abbreviates Mono -> Mn
    static let family = "TestFamily"
}

enum SoehneWeight: String {
    case buch = "Buch"
    case kraftig = "Kraftig"   // PostScript drops umlaut
    case halbfett = "Halbfett"
}

enum FamilyWeight: String {
    case regular = "Regular"
    case medium = "Medium"
    case bold = "Bold"
    case heavy = "Heavy"
    case black = "Black"
}

// MARK: - Type tokens
// Three registers:
//   1. Söhne — UI + body workhorse (90%+ of all type)
//   2. Söhne Mono — metadata / timestamps / skill names
//   3. Family — hero only, at most 1× per screen

extension Font {

    // Register 1: Söhne workhorse
    static let briefDisplayXL = soehne(.buch, size: 48, relativeTo: .largeTitle)
    static let briefTitle1    = soehne(.kraftig, size: 28, relativeTo: .title)
    static let briefTitle2    = soehne(.kraftig, size: 22, relativeTo: .title2)
    static let briefTitle3    = soehne(.halbfett, size: 17, relativeTo: .title3)
    static let briefTitle3Medium   = soehne(.kraftig, size: 17, relativeTo: .title3) // 500 — lighter section heading
    static let briefHeadline       = soehne(.halbfett, size: 14, relativeTo: .headline)
    static let briefHeadlineMedium = soehne(.kraftig, size: 14, relativeTo: .headline) // 500 — lighter sub-heading
    static let briefBody           = soehne(.buch, size: 14, relativeTo: .body)
    static let briefBodyMedium     = soehne(.kraftig, size: 14, relativeTo: .body) // 500 — inline lead-in labels
    static let briefBodySmall      = soehne(.buch, size: 13, relativeTo: .body)
    // Provenance fonts — Buch 400, matching body weight. The citation reads as
    // part of the prose (the hairline underline carries the affordance, not a
    // heavier weight). This is the Live Context standard: source phrases sit in
    // the sentence, not above it. (Was Kraftig 500; reconciled to the doc.)
    static let briefProvenance      = soehne(.buch, size: 14, relativeTo: .body)
    static let briefProvenanceSmall = soehne(.buch, size: 13, relativeTo: .body)
    // Popover-specific snippet: smaller body for rich, dense excerpt.
    static let briefSnippet         = soehne(.buch, size: 12, relativeTo: .footnote)
    static let briefLabel     = soehne(.kraftig, size: 12, relativeTo: .callout)
    static let briefMeta      = soehne(.buch, size: 11, relativeTo: .footnote)
    static let briefCaption   = soehne(.buch, size: 10, relativeTo: .caption)

    // Register 2: Söhne Mono
    static let briefMonoLabel = soehneMono(.buch, size: 11, relativeTo: .footnote)
    static let briefMonoMeta  = soehneMono(.buch, size: 10, relativeTo: .caption)

    // Register 3: Family hero — use sparingly
    static let briefHeroDisplay  = family(.black, size: 56, relativeTo: .largeTitle)
    static let briefHeroHeadline = family(.heavy, size: 36, relativeTo: .largeTitle)
    static let briefHeroMedium   = family(.bold, size: 28, relativeTo: .title)
    /// The one Family (serif) title for a panel header — smaller than the 28pt
    /// document hero, sized to sit in a slide-over's top row.
    static let briefPanelTitle   = family(.bold, size: 20, relativeTo: .title2)

    // MARK: - Builders

    private static func soehne(_ weight: SoehneWeight, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        custom("\(BriefFontFamily.soehne)-\(weight.rawValue)", size: size, relativeTo: style)
    }

    private static func soehneMono(_ weight: SoehneWeight, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        custom("\(BriefFontFamily.soehneMono)-\(weight.rawValue)", size: size, relativeTo: style)
    }

    private static func family(_ weight: FamilyWeight, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        custom("\(BriefFontFamily.family)-\(weight.rawValue)", size: size, relativeTo: style)
    }
}

// MARK: - Line-height + tracking modifiers
// SwiftUI's Text doesn't expose line-height directly; we use lineSpacing
// which is the *additional* space beyond the font's natural leading.

struct BriefTypeStyle: ViewModifier {
    let font: Font
    let lineHeightMultiple: CGFloat
    let trackingPercent: CGFloat
    let fontSize: CGFloat

    func body(content: Content) -> some View {
        let extraLineSpacing = (lineHeightMultiple - 1.0) * fontSize
        let trackingPoints = trackingPercent / 100.0 * fontSize
        return content
            .font(font)
            .lineSpacing(max(0, extraLineSpacing))
            .tracking(trackingPoints)
    }
}

extension Text {
    func briefStyle(_ token: BriefTypeToken) -> some View {
        self.modifier(BriefTypeStyle(
            font: token.font,
            lineHeightMultiple: token.lineHeight,
            trackingPercent: token.tracking,
            fontSize: token.size
        ))
    }
}

// MARK: - Token table
// Single source of truth: every token's size, line-height, tracking, weight.
// Matches the spec in project_typography_research.md.

struct BriefTypeToken {
    let font: Font
    let size: CGFloat
    let lineHeight: CGFloat   // multiple, e.g. 1.45
    let tracking: CGFloat     // percent of font size, e.g. -1 means -1%

    // Söhne
    static let displayXL  = BriefTypeToken(font: .briefDisplayXL,  size: 48, lineHeight: 1.05, tracking: -2)
    static let title1     = BriefTypeToken(font: .briefTitle1,     size: 28, lineHeight: 1.15, tracking: -1)
    static let title2     = BriefTypeToken(font: .briefTitle2,     size: 22, lineHeight: 1.20, tracking: -1)
    static let title3     = BriefTypeToken(font: .briefTitle3,     size: 17, lineHeight: 1.25, tracking:  0)
    // Section heading (H2) — Live Context standard. tracking −1.2% == −0.2pt @17.
    static let title3Medium   = BriefTypeToken(font: .briefTitle3Medium,   size: 17, lineHeight: 1.25, tracking: -1.2)
    static let headline   = BriefTypeToken(font: .briefHeadline,   size: 14, lineHeight: 1.40, tracking:  0)
    // Sub-heading (H3) — Live Context standard. tracking +0.7% == +0.1pt @14.
    static let headlineMedium = BriefTypeToken(font: .briefHeadlineMedium, size: 14, lineHeight: 1.40, tracking:  0.7)
    // Body — Live Context standard line-height 1.20 (dense, scannable brief).
    // (Was 1.55; the doc's dialed-in rhythm is now the standard.)
    static let body       = BriefTypeToken(font: .briefBody,       size: 14, lineHeight: 1.20, tracking:  0)
    // Medium (Kraftig 500) at body size — for emphasis where weight (not color)
    // carries it. Lead-in labels in the doc use `body` (Buch) + ink color instead.
    static let bodyMedium = BriefTypeToken(font: .briefBodyMedium, size: 14, lineHeight: 1.20, tracking:  0)
    static let bodySmall  = BriefTypeToken(font: .briefBodySmall,  size: 13, lineHeight: 1.40, tracking:  0)
    static let label      = BriefTypeToken(font: .briefLabel,      size: 12, lineHeight: 1.30, tracking:  1)
    static let meta       = BriefTypeToken(font: .briefMeta,       size: 11, lineHeight: 1.30, tracking:  2)
    static let caption    = BriefTypeToken(font: .briefCaption,    size: 10, lineHeight: 1.30, tracking:  3)

    // Söhne Mono
    static let monoLabel  = BriefTypeToken(font: .briefMonoLabel,  size: 11, lineHeight: 1.30, tracking:  1)
    static let monoMeta   = BriefTypeToken(font: .briefMonoMeta,   size: 10, lineHeight: 1.30, tracking:  2)

    // Popover snippet — compact, no extra tracking, very tight leading
    static let snippet    = BriefTypeToken(font: .briefSnippet,    size: 12, lineHeight: 1.15, tracking:  0)

    // Provenance — inline source citation. Live Context standard: Buch 400,
    // same weight and line-height as body, so the cited phrase sits in the
    // sentence (the hairline underline is the only affordance). Notion-style.
    static let provenance      = BriefTypeToken(font: .briefProvenance,      size: 14, lineHeight: 1.20, tracking: 0)
    static let provenanceSmall = BriefTypeToken(font: .briefProvenanceSmall, size: 13, lineHeight: 1.20, tracking: 0)

    // Family hero
    static let heroDisplay  = BriefTypeToken(font: .briefHeroDisplay,  size: 56, lineHeight: 1.00, tracking: -3)
    static let heroHeadline = BriefTypeToken(font: .briefHeroHeadline, size: 36, lineHeight: 1.10, tracking: -2)
    static let heroMedium   = BriefTypeToken(font: .briefHeroMedium,   size: 28, lineHeight: 1.15, tracking: -2)
    static let panelTitle   = BriefTypeToken(font: .briefPanelTitle,   size: 20, lineHeight: 1.15, tracking: -1)
}
