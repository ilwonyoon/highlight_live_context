import SwiftUI

// MARK: - CaptureToggleRow — a capture/data switch in the Brief design system
//
// The Brief's version of Highlight's on/off Data & Privacy controls (Observe my
// screen, Help improve Highlight). A card with a title + one-line description on
// the left and a native Toggle on the right, tinted with the brand highlight so
// "on" reads as a positive, productive state — the same semantic the rest of the
// app reserves the accent for.
//
//   ┌──────────────────────────────────────────────────┐
//   │  Observe my screen                          (●  ) │  title · toggle
//   │  Let Highlight watch your screen to enrich…       │  description
//   └──────────────────────────────────────────────────┘
//
// (Secure Capture is NOT here — it's a standing guarantee, rendered as
// SecureCaptureBanner at the top of the page, not a switch.)

struct CaptureToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.md) {
                Text(title)
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
                Spacer(minLength: BriefSpacing.sm)
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(Color.briefHighlight)   // brand fluorescent — "on" = productive
                    .controlSize(.small)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] - 4 }
            }
            Text(description)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        )
    }
}

#Preview("Capture toggles") {
    @Previewable @State var settings = CaptureSettings.dani
    return VStack(spacing: BriefSpacing.lg) {
        SecureCaptureBanner()
        CaptureToggleRow(title: "Observe my screen",
                         description: "Let Highlight watch your screen to enrich your Live Context.",
                         isOn: $settings.screenContext)
        CaptureToggleRow(title: "Help improve Highlight",
                         description: "Share anonymized logs so the team can spot and fix problems.",
                         isOn: $settings.telemetry)
    }
    .padding(BriefSpacing.xxl)
    .frame(width: 640)
    .background(Color.briefPaper)
}
