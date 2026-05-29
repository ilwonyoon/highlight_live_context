import SwiftUI

// MARK: - Markdown-semantic spacing & type mapping
// The Brief surface reads like a document. To keep its visual hierarchy
// consistent across every page, every "header level" maps to one type
// token and one spacing-above value. Use these helpers instead of laying
// out section headers ad-hoc.

enum BriefMarkdown {

    // MARK: Type tokens per level

    /// H1 — the ONE Family-serif moment per screen. Each page's top title
    /// (e.g. "Color", "Today's Brief") is the single brand-typography hit;
    /// everything else is Söhne. (Family heroMedium = 28pt Medium.)
    static let h1Token: BriefTypeToken = .heroMedium
    /// H2 — top-level section ("1. PRIMARY GOAL"). Söhne Kräftig 17pt (medium)
    /// — lighter than Halbfett for a calmer page; size + tracking carry rank.
    static let h2Token: BriefTypeToken = .title3Medium
    /// H3 — sub-group ("Launch readiness"). Söhne Kräftig 14pt (medium).
    static let h3Token: BriefTypeToken = .headlineMedium
    /// H4 — bullet group lead-in ("Next Steps"). Söhne Kraftig 12pt label.
    static let h4Token: BriefTypeToken = .label
    /// Body bullet text. Söhne Buch 14pt.
    static let bodyToken: BriefTypeToken = .body

    // MARK: Spacing
    // Values are research-backed — see TYPOGRAPHY_READABILITY.md. The key
    // rules: header space-above > space-below (~2.5:1) so headers bond to the
    // section below; and within-group gaps are ~2.5× tighter than between-group
    // gaps (Gestalt proximity) so groups read as groups.

    /// H1 stands alone — caller decides spacing above.
    static let h1Top: CGFloat   = BriefSpacing.xxxl                    // 28pt

    /// H2 starts a new section — generous space above, tighter below.
    static let h2Top: CGFloat   = BriefSpacing.huge - BriefSpacing.md  // 32pt
    static let h2Below: CGFloat = BriefSpacing.lg                      // 12pt  (≈2.6:1)
    /// H3 sub-group — less than H2 (rank via space), still above > below.
    static let h3Top: CGFloat   = BriefSpacing.xxxl - BriefSpacing.xs  // 24pt
    static let h3Below: CGFloat = BriefSpacing.md                      // 8pt   (3:1)
    /// H4 group lead-in.
    static let h4Top: CGFloat   = BriefSpacing.lg                      // 12pt
    static let h4Below: CGFloat = BriefSpacing.xs                      // 4pt

    /// Bullet inside a group — tight, so items cohere.
    static let bulletTop: CGFloat = BriefSpacing.sm                    // 6pt
    /// Sub-bullet (one indent level deeper).
    static let subBulletTop: CGFloat = BriefSpacing.xs                 // 4pt
    /// Gap between separate groups (list↔paragraph, group↔group).
    /// ≈ paragraph gap, ~2.5× the within-group bullet gap.
    static let groupGap: CGFloat = BriefSpacing.xl                     // 16pt

    /// Left indent applied per nesting level (one step/level, max 3 levels).
    static let indentStep: CGFloat = BriefSpacing.xxxl - BriefSpacing.xs // 24pt
}

// MARK: - Convenience headers

extension View {
    /// Apply the standard "spacing-above" for a markdown level.
    func briefMarkdownSpacing(_ topPadding: CGFloat) -> some View {
        self.padding(.top, topPadding)
    }
}

/// H1 — workspace title row.
struct BriefH1: View {
    let text: String
    var body: some View {
        Text(text)
            .briefStyle(BriefMarkdown.h1Token)
            .foregroundStyle(Color.briefInkPrimary)
    }
}

/// H2 — top-level section header (e.g. "1. PRIMARY GOAL — EMPLOYMENT").
struct BriefH2: View {
    let text: String
    var body: some View {
        Text(text)
            .briefStyle(BriefMarkdown.h2Token)
            .foregroundStyle(Color.briefInkPrimary)
            .padding(.top, BriefMarkdown.h2Top)
            .padding(.bottom, BriefMarkdown.h2Below)
    }
}

/// H3 — sub-group header (e.g. "1. Highlight (Highlighter, Inc.)").
struct BriefH3: View {
    let text: String
    var body: some View {
        Text(text)
            .briefStyle(BriefMarkdown.h3Token)
            .foregroundStyle(Color.briefInkPrimary)
            .padding(.top, BriefMarkdown.h3Top)
            .padding(.bottom, BriefMarkdown.h3Below)
    }
}

/// H4 — bullet-group lead-in (e.g. "Next Steps").
struct BriefH4: View {
    let text: String
    var body: some View {
        Text(text)
            .briefStyle(BriefMarkdown.h4Token)
            .foregroundStyle(Color.briefInkSecondary)
            .briefMarkdownSpacing(BriefMarkdown.h4Top)
    }
}
