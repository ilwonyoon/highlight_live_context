import SwiftUI

// MARK: - PrivacySettingsView — the manual privacy settings page
//
// A conventional settings surface: the user sees and hand-edits the filters that
// keep things out of their context. Two sections — Your filters (editable) and
// Automatic (read-only) — built from the Filter model in PRIVACY_USER_CONTROL.md.
//
// This is Path B (manual). The chat panel is Path A (edit the SAME filters by
// talking). Both touch one underlying set.
//
// Step 1: a stub that proves the nav route (sidebar "Privacy" → this page in the
// main area). The filter cards + sections land next.

struct PrivacySettingsView: View {
    var body: some View {
        SelectionSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                    header
                    placeholder
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

    private var header: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            BriefH1(text: "Privacy")
            Text("What Highlight keeps out of your work context. Edit it here, or just tell the assistant.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var placeholder: some View {
        Text("Filters list — coming in the next step.")
            .briefStyle(.body)
            .foregroundStyle(Color.briefInkTertiary)
            .padding(.top, BriefSpacing.xxl)
    }
}

#Preview {
    PrivacySettingsView()
        .frame(width: 900, height: 700)
        .background(Color.briefPaper)
}
