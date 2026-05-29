import SwiftUI

// MARK: - Markdown-semantic spacing & type mapping
// The Brief surface reads like a document. To keep its visual hierarchy
// consistent across every page, every "header level" maps to one type
// token and one spacing-above value. Use these helpers instead of laying
// out section headers ad-hoc.

enum BriefMarkdown {

    // MARK: Type tokens per level

    /// H1 — workspace title ("Default", "Today's Brief"). Söhne Kraftig 22pt.
    static let h1Token: BriefTypeToken = .title2
    /// H2 — top-level section ("1. PRIMARY GOAL"). Söhne Halbfett 17pt.
    static let h2Token: BriefTypeToken = .title3
    /// H3 — sub-group ("1. Highlight (Highlighter, Inc.)"). Söhne Halbfett 14pt.
    static let h3Token: BriefTypeToken = .headline
    /// H4 — bullet group lead-in ("Next Steps"). Söhne Kraftig 12pt label.
    static let h4Token: BriefTypeToken = .label
    /// Body bullet text. Söhne Buch 14pt.
    static let bodyToken: BriefTypeToken = .body

    // MARK: Spacing above each level

    /// H1 stands alone — caller decides spacing above.
    static let h1Top: CGFloat   = BriefSpacing.xxxl
    /// H2 starts a new section — generous breathing room.
    static let h2Top: CGFloat   = BriefSpacing.xxxl - BriefSpacing.sm   // 22pt
    /// H3 inside an H2 section.
    static let h3Top: CGFloat   = BriefSpacing.xl                       // 16pt
    /// H4 inside an H3 group.
    static let h4Top: CGFloat   = BriefSpacing.md                       // 8pt
    /// Bullet inside a group.
    static let bulletTop: CGFloat = BriefSpacing.sm                     // 6pt
    /// Sub-bullet (one indent level deeper).
    static let subBulletTop: CGFloat = BriefSpacing.xs                  // 4pt

    /// Left indent applied per nesting level.
    static let indentStep: CGFloat = BriefSpacing.xl                    // 16pt
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
            .briefMarkdownSpacing(BriefMarkdown.h2Top)
    }
}

/// H3 — sub-group header (e.g. "1. Highlight (Highlighter, Inc.)").
struct BriefH3: View {
    let text: String
    var body: some View {
        Text(text)
            .briefStyle(BriefMarkdown.h3Token)
            .foregroundStyle(Color.briefInkPrimary)
            .briefMarkdownSpacing(BriefMarkdown.h3Top)
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
