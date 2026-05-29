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
    // Provenance fonts — slightly heavier than body (Kraftig 500 vs Buch 400)
    // for referenceable presence. Combined with hairline underline for citation
    // affordance. Söhne has no variable axis, so this is the one available step up.
    static let briefProvenance      = soehne(.kraftig, size: 14, relativeTo: .body)
    static let briefProvenanceSmall = soehne(.kraftig, size: 13, relativeTo: .body)
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
    static let title3Medium   = BriefTypeToken(font: .briefTitle3Medium,   size: 17, lineHeight: 1.25, tracking: -0.2)
    static let headline   = BriefTypeToken(font: .briefHeadline,   size: 14, lineHeight: 1.40, tracking:  0)
    static let headlineMedium = BriefTypeToken(font: .briefHeadlineMedium, size: 14, lineHeight: 1.40, tracking:  0)
    // Line-height 1.55: WCAG 1.4.12 floor (1.5) bumped for a wide reading
    // measure. See TYPOGRAPHY_READABILITY.md.
    static let body       = BriefTypeToken(font: .briefBody,       size: 14, lineHeight: 1.55, tracking:  0)
    // Medium (Kraftig 500) at body size — for inline lead-in labels ("Status:")
    // and light emphasis. Calmer than headline (Halbfett 600).
    static let bodyMedium = BriefTypeToken(font: .briefBodyMedium, size: 14, lineHeight: 1.55, tracking:  0)
    static let bodySmall  = BriefTypeToken(font: .briefBodySmall,  size: 13, lineHeight: 1.40, tracking:  0)
    static let label      = BriefTypeToken(font: .briefLabel,      size: 12, lineHeight: 1.30, tracking:  1)
    static let meta       = BriefTypeToken(font: .briefMeta,       size: 11, lineHeight: 1.30, tracking:  2)
    static let caption    = BriefTypeToken(font: .briefCaption,    size: 10, lineHeight: 1.30, tracking:  3)

    // Söhne Mono
    static let monoLabel  = BriefTypeToken(font: .briefMonoLabel,  size: 11, lineHeight: 1.30, tracking:  1)
    static let monoMeta   = BriefTypeToken(font: .briefMonoMeta,   size: 10, lineHeight: 1.30, tracking:  2)

    // Popover snippet — compact, no extra tracking, very tight leading
    static let snippet    = BriefTypeToken(font: .briefSnippet,    size: 12, lineHeight: 1.15, tracking:  0)

    // Provenance — inline source citation. Slightly heavier than body
    // (Kraftig 500 vs body Buch 400) so it reads as a referenceable object
    // without changing the line rhythm. Notion-style.
    static let provenance      = BriefTypeToken(font: .briefProvenance,      size: 14, lineHeight: 1.45, tracking: 0)
    static let provenanceSmall = BriefTypeToken(font: .briefProvenanceSmall, size: 13, lineHeight: 1.40, tracking: 0)

    // Family hero
    static let heroDisplay  = BriefTypeToken(font: .briefHeroDisplay,  size: 56, lineHeight: 1.00, tracking: -3)
    static let heroHeadline = BriefTypeToken(font: .briefHeroHeadline, size: 36, lineHeight: 1.10, tracking: -2)
    static let heroMedium   = BriefTypeToken(font: .briefHeroMedium,   size: 28, lineHeight: 1.15, tracking: -2)
}
