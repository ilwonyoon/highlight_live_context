import SwiftUI

// MARK: - PrivacySettingsView — the manual privacy settings page
//
// Ordered by the defense-in-depth pipeline: Capture → Blocked Apps → Filters → Data Sharing.
// State lives in PrivacyStore, shared with the chat panel — both paths edit the same data.

struct PrivacySettingsView: View {
    @ObservedObject var store: PrivacyStore

    var body: some View {
        SelectionSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
                    header
                    SecureCaptureBanner()
                    captureSection
                    filtersSection
                    dataSharingSection
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
            BriefH1(text: "Data & Privacy")
            Text("What Highlight captures, and what it keeps out of your work context. Edit it here, or just tell the assistant.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Capture

    private var captureSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "CAPTURE") { EmptyView() }
            CaptureToggleRow(
                title: "Observe my screen",
                description: "Let Highlight watch your screen to enrich your Live Context. Turn this off and nothing new is captured.",
                isOn: $store.capture.screenContext)
        }
    }

    // MARK: Filters — two containers

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
            blockedAppsBox
            filtersBox
        }
        .animation(.briefStandard, value: store.userFilters.count)
    }

    // Container 1 — BLOCKED APPS & SITES
    private var blockedAppsBox: some View {
        let appSiteFilters = store.userFilters.filter { $0.layer == .appSite }
        return VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "BLOCKED APPS & SITES") { EmptyView() }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(appSiteFilters.enumerated()), id: \.element.id) { i, filter in
                    if i > 0 { listDivider }
                    if let idx = store.userFilters.firstIndex(where: { $0.id == filter.id }) {
                        FilterCard(filter: $store.userFilters[idx],
                                   startExpanded: filter.id == store.newlyAddedID,
                                   inList: true,
                                   onDelete: { store.removeFilter(id: filter.id) })
                    }
                }
                listDivider
                addRowButton(label: "Add app or site", icon: "plus.circle.fill") {
                    PrivacyWindowController.shared.present(entry: .addAppSite)
                }
            }
            .listBox
        }
    }

    // Container 2 — FILTERS (automatic pinned top, user editable below)
    private var filtersBox: some View {
        let topicFilters = store.userFilters.filter { $0.layer == .topicKeyword }
        let autoFilters = store.automaticFilters
        return VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "FILTERS") { EmptyView() }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(autoFilters.enumerated()), id: \.element.id) { i, filter in
                    if i > 0 { listDivider }
                    FilterCard(readOnly: filter, inList: true)
                }
                ForEach(topicFilters) { filter in
                    listDivider
                    if let idx = store.userFilters.firstIndex(where: { $0.id == filter.id }) {
                        FilterCard(filter: $store.userFilters[idx],
                                   startExpanded: filter.id == store.newlyAddedID,
                                   inList: true,
                                   onDelete: { store.removeFilter(id: filter.id) })
                    }
                }
                listDivider
                addRowButton(label: "Add a filter", icon: "plus.circle.fill") {
                    PrivacyWindowController.shared.present(entry: .addTopicFilter)
                }
            }
            .listBox
        }
    }

    // MARK: Data sharing

    private var dataSharingSection: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            sectionHeader(title: "DATA SHARING") { EmptyView() }
            CaptureToggleRow(
                title: "Help improve Highlight",
                description: "Share anonymized logs from your AI interactions so the team can spot and fix problems. Covers screen data, actions, chats, and meeting notes.",
                isOn: $store.capture.telemetry)
        }
    }

    // MARK: Shared UI helpers

    private func addRowButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: BriefSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.briefInkTertiary)
                Text(label)
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkSecondary)
            }
            .padding(.horizontal, BriefSpacing.xl)
            .padding(.vertical, BriefSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var listDivider: some View {
        Rectangle()
            .fill(Color.briefHairlineSoft.opacity(0.4))
            .frame(height: 0.5)
            .padding(.horizontal, BriefSpacing.xl)
    }

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

private extension View {
    var listBox: some View {
        self.background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        )
    }
}

#Preview {
    PrivacySettingsView(store: PrivacyStore())
        .frame(width: 900, height: 760)
        .background(Color.briefPaper)
}
