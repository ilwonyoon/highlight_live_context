import SwiftUI

// MARK: - PrivacySettingsView — the manual privacy settings page
//
// A conventional settings surface: the user sees and hand-edits the filters that
// keep things out of their context. Two sections (PRIVACY_USER_CONTROL.md §5):
//   • YOUR FILTERS — editable; the boundaries the user declared
//   • AUTOMATIC — read-only; what Highlight screens without being asked (P2)
// Same FilterCard in both, edit affordances only when editable.
//
// This is Path B (manual). The chat panel is Path A (edit the SAME filters by
// talking). Both touch one underlying set.

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

    // MARK: Your filters (editable) — with an add affordance

    private var yourFiltersSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "YOUR FILTERS") {
                Button(action: {}) {
                    HStack(spacing: BriefSpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Add a filter")
                            .briefStyle(.bodySmall)
                    }
                    .foregroundStyle(Color.briefHighlightInk)
                }
                .buttonStyle(.plain)
                .help("Declare a new filter")
            }

            ForEach($userFilters) { $filter in
                FilterCard(
                    filter: filter,
                    onRemoveTag: { tag in
                        filter.tags.removeAll { $0.id == tag.id }
                    },
                    onAddTag: {},
                    onChangeDuration: {},
                    onOverflow: {}
                )
            }
        }
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
                FilterCard(filter: filter)
            }
        }
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
