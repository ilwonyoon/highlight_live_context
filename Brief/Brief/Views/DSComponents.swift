import SwiftUI

// MARK: - Shared building blocks for design-system detail pages
// Small, reusable presentational pieces: section headers, swatches, spec
// rows, and a "specimen card" container. Kept separate so the page files
// stay declarative.

/// A labeled group within a page (e.g. "Paper", "Ink", "Highlight").
struct DSGroup<Content: View>: View {
    let title: String
    var note: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.lg) {
            VStack(alignment: .leading, spacing: BriefSpacing.xxs) {
                Text(title)
                    .briefStyle(.title3)
                    .foregroundStyle(Color.briefInkPrimary)
                if let note {
                    Text(note)
                        .briefStyle(.meta)
                        .foregroundStyle(Color.briefInkTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            content()
        }
    }
}

/// A single color swatch with name + hex/opacity caption.
struct DSSwatch: View {
    let color: Color
    let name: String
    let detail: String
    var ringForLight: Bool = false   // draw a hairline for near-white swatches

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                .fill(color)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                        .stroke(Color.briefHairline, lineWidth: ringForLight ? 0.5 : 0)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .briefStyle(.label)
                    .foregroundStyle(Color.briefInkPrimary)
                Text(detail)
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .frame(width: 132, alignment: .leading)
    }
}

/// A flowing grid of swatches.
struct DSSwatchGrid: View {
    let swatches: [DSSwatch]
    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 132, maximum: 160), spacing: BriefSpacing.xl, alignment: .leading)],
            alignment: .leading,
            spacing: BriefSpacing.xl
        ) {
            ForEach(Array(swatches.enumerated()), id: \.offset) { _, sw in
                sw
            }
        }
    }
}

/// A two-column spec row: token name (mono) on the left, sample/value right.
struct DSSpecRow<Trailing: View>: View {
    let token: String
    let value: String
    @ViewBuilder var trailing: () -> Trailing

    init(token: String, value: String = "", @ViewBuilder trailing: @escaping () -> Trailing) {
        self.token = token
        self.value = value
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: BriefSpacing.xl) {
            Text(token)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkSecondary)
                .frame(width: 150, alignment: .leading)
            trailing()
                .frame(maxWidth: .infinity, alignment: .leading)
            if !value.isEmpty {
                Text(value)
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .padding(.vertical, BriefSpacing.xs)
    }
}

/// A bordered container for live component demos.
struct DSSpecimenCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(BriefSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                    .fill(Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                            .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                    )
            )
    }
}
