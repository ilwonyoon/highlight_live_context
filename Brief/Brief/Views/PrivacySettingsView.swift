import SwiftUI

// MARK: - PrivacySettingsView — the manual privacy settings page
//
// A conventional settings surface where the user hand-edits everything — no chat
// needed: rename a filter, add/remove tags, change its duration, pause or delete,
// and add brand-new filters. Two sections (PRIVACY_USER_CONTROL.md §5):
//   • YOUR FILTERS — editable
//   • AUTOMATIC — read-only (P2)
//
// This is Path B (manual, complete on its own). The chat panel is Path A — it
// drives this SAME state by talking.

struct PrivacySettingsView: View {
    @State private var userFilters = PrivacyFilter.userMock
    private let automaticFilters = PrivacyFilter.automaticMock

    var body: some View {
        SelectionSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
                    header
                    yourFiltersSection
                    automaticSection
                    Spacer(minLength: BriefSpacing.mega)
                }
                .frame(maxWidth: BriefLayout.readingWidth, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, BriefSpacing.huge)
                .padding(.top, BriefSpacing.xxl)
            }
            .scrollIndicators(.visible)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            BriefH1(text: "Privacy")
            Text("What Highlight keeps out of your work context. Edit it here, or just tell the assistant.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Your filters (editable) — add / edit / delete

    private var yourFiltersSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "YOUR FILTERS") {
                Button(action: addFilter) {
                    HStack(spacing: BriefSpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Add a filter")
                            .briefStyle(.bodySmall)
                    }
                    .foregroundStyle(Color.briefHighlightInk)
                }
                .buttonStyle(.plain)
                .help("Add a new filter")
            }

            if userFilters.isEmpty {
                Text("No filters yet — add one, or just tell the assistant what to keep out.")
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkTertiary)
                    .padding(.vertical, BriefSpacing.sm)
            }

            ForEach($userFilters) { $filter in
                FilterCard(filter: $filter, onDelete: { delete(filter) })
            }
        }
        .animation(.briefStandard, value: userFilters.count)
    }

    // MARK: Automatic (read-only)

    private var automaticSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "AUTOMATIC") {
                Text("managed by Highlight")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            ForEach(automaticFilters) { filter in
                FilterCard(readOnly: filter)
            }
        }
    }

    // MARK: Mutations

    private func addFilter() {
        let new = PrivacyFilter(statement: "",
                                tags: [],
                                duration: .permanent,
                                filteredCount: 0,
                                editable: true)
        userFilters.insert(new, at: 0)   // newest on top
    }

    private func delete(_ filter: PrivacyFilter) {
        userFilters.removeAll { $0.id == filter.id }
    }

    // MARK: Section header — label + trailing accessory

    private func sectionHeader<Accessory: View>(title: String,
                                                @ViewBuilder accessory: () -> Accessory) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkTertiary)
            Spacer(minLength: BriefSpacing.md)
            accessory()
        }
    }
}

#Preview {
    PrivacySettingsView()
        .frame(width: 900, height: 760)
        .background(Color.briefPaper)
}
