import SwiftUI

// MARK: - FilterCard — the atom of the privacy settings surface
//
// One component, both contexts (PRIVACY_USER_CONTROL.md §4, P7). Edit affordances
// (chip ✕, ＋, duration menu, ⋯) appear only when the filter is `editable`; an
// automatic filter renders identically minus those.
//
//   ┌──────────────────────────────────────────────────┐
//   │  Keep my family & personal life out  12 filtered  │  statement · count
//   │  [family 5 ✕] [health 4 ✕] [home 3 ✕] [＋]         │  tag chips
//   │  Never kept ▾                              ⋯       │  duration · overflow
//   └──────────────────────────────────────────────────┘

struct FilterCard: View {
    let filter: PrivacyFilter
    /// Edit callbacks — only invoked for editable cards.
    var onRemoveTag: (FilterTag) -> Void = { _ in }
    var onAddTag: () -> Void = {}
    var onChangeDuration: () -> Void = {}
    var onOverflow: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            statementRow
            tagRow
            footerRow
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(filter.active ? 1 : 0.55)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        )
    }

    // MARK: Statement + count

    private var statementRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
            Text(filter.statement)
                .briefStyle(.bodyMedium)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: BriefSpacing.sm)
            Text("\(filter.filteredCount) filtered")
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
                .layoutPriority(1)
        }
    }

    // MARK: Tag chips (✕ + ＋ only when editable)

    private var tagRow: some View {
        FlowLayout(spacing: BriefSpacing.xs) {
            ForEach(filter.tags) { tag in
                TagChip(tag: tag,
                        removable: filter.editable,
                        onRemove: { onRemoveTag(tag) })
            }
            if filter.editable {
                AddTagChip(action: onAddTag)
            }
        }
    }

    // MARK: Duration + overflow (or "managed by Highlight" when read-only)

    private var footerRow: some View {
        HStack(spacing: BriefSpacing.sm) {
            if filter.editable {
                Button(action: onChangeDuration) {
                    HStack(spacing: BriefSpacing.xs) {
                        Text(filter.duration.label)
                            .briefStyle(.monoMeta)
                            .foregroundStyle(Color.briefInkSecondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(Color.briefInkTertiary)
                    }
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
                OverflowButton(action: onOverflow)
            } else {
                Text("\(filter.duration.label) · managed by Highlight")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Tag chip (label + count, ✕ when removable)

private struct TagChip: View {
    let tag: FilterTag
    let removable: Bool
    let onRemove: () -> Void
    @State private var hovering = false

    var body: some View {
        HStack(spacing: BriefSpacing.xs) {
            Text(tag.label)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkPrimary)
            if tag.count > 0 {
                Text("\(tag.count)")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            if removable {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                }
                .buttonStyle(.plain)
                .onHover { hovering = $0 }
            }
        }
        .padding(.horizontal, BriefSpacing.sm)
        .padding(.vertical, BriefSpacing.xs)
        .background(
            Capsule()
                .fill(Color.briefPaperSunken)
                .overlay(Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth))
        )
    }
}

// MARK: - Add-tag chip (＋)

private struct AddTagChip: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                .padding(.horizontal, BriefSpacing.sm)
                .padding(.vertical, BriefSpacing.xs)
                .background(
                    Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help("Add a tag")
    }
}

// MARK: - Overflow (⋯) — pause / delete

private struct OverflowButton: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                .frame(width: 24, height: 20)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help("Pause or delete")
    }
}

// (FlowLayout — the chip-wrapping layout — already lives in ProvenanceTag.swift.)

#Preview("Filter cards") {
    VStack(spacing: BriefSpacing.lg) {
        FilterCard(filter: PrivacyFilter.userMock[0])
        FilterCard(filter: PrivacyFilter.automaticMock[0])
    }
    .padding(BriefSpacing.xxl)
    .frame(width: 640)
    .background(Color.briefPaper)
}
