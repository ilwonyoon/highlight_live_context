import SwiftUI

// MARK: - FilterCard — the atom of the privacy settings surface
//
// One component, both contexts (PRIVACY_USER_CONTROL.md §4, P7). Everything is
// hand-editable here (no chat needed): rename the statement, add/remove tags,
// change the duration, pause or delete. Automatic cards render identically minus
// those affordances (editable = false).
//
//   ┌──────────────────────────────────────────────────┐
//   │  Keep my family & personal life out  12 filtered  │  statement (editable) · count
//   │  [family 5 ✕] [health 4 ✕] [＋ type…]             │  tag chips
//   │  Never kept ▾                              ⋯       │  duration menu · pause/delete
//   └──────────────────────────────────────────────────┘

struct FilterCard: View {
    @Binding var filter: PrivacyFilter
    var onDelete: () -> Void = {}

    init(filter: Binding<PrivacyFilter>, onDelete: @escaping () -> Void = {}) {
        self._filter = filter
        self.onDelete = onDelete
    }
    /// Read-only convenience for automatic cards (no binding needed).
    init(readOnly filter: PrivacyFilter) {
        self._filter = .constant(filter)
        self.onDelete = {}
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            statementRow
            tagRow
            footerRow
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(filter.active ? 1 : 0.5)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        )
    }

    // MARK: Statement (editable inline) + count

    private var statementRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
            if filter.editable {
                TextField("Name this filter", text: $filter.statement)
                    .textFieldStyle(.plain)
                    .font(.briefBodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
            } else {
                Text(filter.statement)
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: BriefSpacing.sm)
            Text("\(filter.filteredCount) filtered")
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
                .layoutPriority(1)
        }
    }

    // MARK: Tag chips (✕ removes, ＋ adds — editable only)

    private var tagRow: some View {
        FlowLayout(spacing: BriefSpacing.xs) {
            ForEach(filter.tags) { tag in
                TagChip(tag: tag,
                        removable: filter.editable,
                        onRemove: { filter.tags.removeAll { $0.id == tag.id } })
            }
            if filter.editable {
                AddTagField { label in
                    let trimmed = label.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    filter.tags.append(FilterTag(label: trimmed, count: 0))
                }
            }
        }
    }

    // MARK: Duration menu + overflow (or read-only line)

    private var footerRow: some View {
        HStack(spacing: BriefSpacing.sm) {
            if filter.editable {
                durationMenu
                Spacer(minLength: 0)
                overflowMenu
            } else {
                Text("\(filter.duration.label) · managed by Highlight")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
                Spacer(minLength: 0)
            }
        }
    }

    private var durationMenu: some View {
        Menu {
            Button("Never kept") { filter.duration = .permanent }
            Divider()
            ForEach([7, 14, 30, 90], id: \.self) { n in
                Button("Forgets after \(n) days") { filter.duration = .days(n) }
            }
        } label: {
            HStack(spacing: BriefSpacing.xs) {
                Text(filter.duration.label)
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private var overflowMenu: some View {
        Menu {
            Button(filter.active ? "Pause" : "Resume") { filter.active.toggle() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: 24, height: 20)
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
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

// MARK: - Add-tag field (＋ → inline text entry)

private struct AddTagField: View {
    let onAdd: (String) -> Void
    @State private var editing = false
    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        if editing {
            TextField("tag", text: $draft)
                .textFieldStyle(.plain)
                .font(.briefMonoLabel)
                .foregroundStyle(Color.briefInkPrimary)
                .frame(width: 64)
                .focused($focused)
                .onSubmit(commit)
                .onExitCommand { editing = false; draft = "" }
                .padding(.horizontal, BriefSpacing.sm)
                .padding(.vertical, BriefSpacing.xs)
                .background(
                    Capsule().stroke(Color.briefHighlight.opacity(BriefOpacity.washHeavy),
                                     lineWidth: 1.5)
                )
                .onAppear { focused = true }
        } else {
            Button { editing = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.briefInkTertiary)
                    .padding(.horizontal, BriefSpacing.sm)
                    .padding(.vertical, BriefSpacing.xs)
                    .background(Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth))
            }
            .buttonStyle(.plain)
            .help("Add a tag")
        }
    }

    private func commit() {
        onAdd(draft)
        draft = ""
        editing = false
    }
}

#Preview("Filter cards") {
    @Previewable @State var user = PrivacyFilter.userMock[0]
    return VStack(spacing: BriefSpacing.lg) {
        FilterCard(filter: $user)
        FilterCard(readOnly: PrivacyFilter.automaticMock[0])
    }
    .padding(BriefSpacing.xxl)
    .frame(width: 640)
    .background(Color.briefPaper)
}
