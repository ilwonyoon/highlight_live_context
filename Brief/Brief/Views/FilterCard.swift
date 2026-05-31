import SwiftUI

// MARK: - FilterCard — the atom of the privacy settings surface
//
// One component, both contexts (PRIVACY_USER_CONTROL.md §4, P7). Everything is
// hand-editable here (no chat needed): rename the statement, add/remove tags,
// change the duration, pause or delete. Automatic cards render identically minus
// those affordances (editable = false).
//
// Progressive disclosure (the list grows): a card starts COLLAPSED — a one-line
// summary with a few preview chips + the filtered count. Tap the header to expand
// the full editable surface. This keeps a long privacy list scannable; the user
// drills into a filter only to change it.
//
//   collapsed ┌────────────────────────────────────────────────┐
//             │  Keep family out  [family][health]+1  12 filtered ⌄│
//             └────────────────────────────────────────────────┘
//   expanded  ┌────────────────────────────────────────────────┐
//             │  Keep my family & personal life out  12 filtered ⌃│  statement · count
//             │  [family 5 ✕] [health 4 ✕] [＋ type…]            │  tag chips
//             │  Never kept ▾                              ⋯      │  duration · pause/delete
//             └────────────────────────────────────────────────┘

struct FilterCard: View {
    @Binding var filter: PrivacyFilter
    var onDelete: () -> Void = {}

    /// Pre-open the card (e.g. a brand-new filter the user just added — they want
    /// to type into it immediately, not tap to expand first).
    var startExpanded: Bool = false

    /// When true the card is inside a FilterList box — no card background painted;
    /// the list box provides the container.
    var inList: Bool = false

    @State private var expanded = false

    init(filter: Binding<PrivacyFilter>, startExpanded: Bool = false, inList: Bool = false, onDelete: @escaping () -> Void = {}) {
        self._filter = filter
        self.startExpanded = startExpanded
        self.inList = inList
        self.onDelete = onDelete
    }
    /// Read-only convenience for automatic cards (no binding needed).
    init(readOnly filter: PrivacyFilter, inList: Bool = false) {
        self._filter = .constant(filter)
        self.inList = inList
        self.onDelete = {}
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            headerRow
            if expanded {
                tagRow
                footerRow
            }
        }
        .padding(.horizontal, BriefSpacing.xl)
        .padding(.vertical, inList ? BriefSpacing.md : BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(filter.active ? 1 : 0.5)
        .background(cardBackground)
        .animation(.briefStandard, value: expanded)
        .onAppear { if startExpanded { expanded = true } }
    }

    @ViewBuilder
    private var cardBackground: some View {
        if !inList {
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        }
    }

    // MARK: Header — statement + (collapsed: chip preview) + count + chevron
    //
    // Collapsed, the entire header is one Button that expands the card — a plain
    // label, preview chips, the count, and a chevron. Expanded, the statement
    // becomes an inline TextField (so taps edit, not collapse) and only the
    // chevron — a separate Button — collapses it back. Splitting the two states
    // keeps the tap target unambiguous (a Button reliably captures the whole row,
    // where an .onTapGesture on an HStack of chips/labels does not).

    @ViewBuilder
    private var headerRow: some View {
        if expanded {
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                statementView
                Spacer(minLength: BriefSpacing.sm)
                countText
                if !filter.editable {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.briefInkTertiary)
                }
                chevron
                    .onTapGesture { expanded = false }
            }
        } else {
            Button { expanded = true } label: {
                HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                    statementView
                    chipPreview
                    Spacer(minLength: BriefSpacing.sm)
                    countText
                    if !filter.editable {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.briefInkTertiary)
                    }
                    chevron
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var statementView: some View {
        if filter.editable && expanded {
            TextField("Name this filter", text: $filter.statement)
                .textFieldStyle(.plain)
                .font(.briefBodySmall)
                .foregroundStyle(Color.briefInkPrimary)
        } else {
            Text(filter.statement)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var countText: some View {
        Text("\(filter.filteredCount) filtered")
            .briefStyle(.monoMeta)
            .foregroundStyle(Color.briefInkTertiary)
            .layoutPriority(1)
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.briefInkTertiary)
            .rotationEffect(.degrees(expanded ? 0 : -90))
            .layoutPriority(1)
    }

    // MARK: Collapsed chip preview — first 2 labels + overflow (no counts/✕)

    private var chipPreview: some View {
        let preview = filter.tags.prefix(2)
        let extra = filter.tags.count - preview.count
        return HStack(spacing: BriefSpacing.xs) {
            ForEach(preview) { tag in
                Text(tag.label)
                    .briefStyle(.monoLabel)
                    .foregroundStyle(Color.briefInkSecondary)
                    .padding(.horizontal, BriefSpacing.sm)
                    .padding(.vertical, 1)
                    .background(
                        Capsule()
                            .fill(Color.briefPaperSunken)
                            .overlay(Capsule().stroke(Color.briefHairline,
                                                      lineWidth: BriefLayout.Card.strokeWidth))
                    )
            }
            if extra > 0 {
                Text("+\(extra)")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
        }
        .layoutPriority(1)
    }

    // MARK: Tag / entry row — app-site layer shows macOS-list-style rows; keyword layer shows chips

    @ViewBuilder
    private var tagRow: some View {
        if filter.layer == .appSite {
            appSiteList
        } else {
            chipRow
        }
    }

    private var appSiteList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filter.tags) { tag in
                AppSiteRow(tag: tag,
                           removable: filter.editable,
                           onRemove: { filter.tags.removeAll { $0.id == tag.id } })
                if tag.id != filter.tags.last?.id || filter.editable {
                    Divider()
                        .padding(.leading, 36)   // indent past icon
                        .foregroundStyle(Color.briefHairlineSoft.opacity(0.5))
                }
            }
            if filter.editable {
                Button {
                    filter.tags.append(FilterTag(label: "", count: 0))
                } label: {
                    HStack(spacing: BriefSpacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.briefHighlightDeep)
                        Text("Add app or site")
                            .briefStyle(.bodySmall)
                            .foregroundStyle(Color.briefInkSecondary)
                    }
                    .padding(.vertical, BriefSpacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var chipRow: some View {
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

// MARK: - App/site row (macOS-settings style: icon + name + count + ✕)

private struct AppSiteRow: View {
    let tag: FilterTag
    let removable: Bool
    let onRemove: () -> Void

    private var isDomain: Bool { tag.label.contains(".") }

    private var icon: some View {
        Group {
            if isDomain {
                Image(systemName: "globe")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.briefInkTertiary)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.briefInkTertiary)
                    .frame(width: 20, height: 20)
            }
        }
    }

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            icon
            Text(tag.label)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkPrimary)
            if tag.count > 0 {
                Text("\(tag.count) filtered")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            Spacer(minLength: 0)
            if removable {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.briefInkTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, BriefSpacing.sm)
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
                    .frame(width: 22, height: 22)
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
