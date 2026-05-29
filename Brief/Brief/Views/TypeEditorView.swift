import SwiftUI

// MARK: - TypeEditorView
// Full fine-tuning editor for the document's type + spacing. Three panes:
//   left   — pick what to edit (each text type, or the spacing group)
//   center — the REAL Live Context document, driven live by the shared DocStyle
//   right  — controls for the selected target (weight, size, line-height,
//            tracking, color picker) or all spacing sliders
// Tuning updates the center immediately; the VALUES dump copies back to tokens.

struct TypeEditorView: View {
    @ObservedObject var style: DocStyle
    @State private var target: EditTarget = .h2

    enum EditTarget: Hashable { case h2, h3, label, value, provenance, spacing }

    var body: some View {
        HSplitView {
            targetList.frame(width: 190)
            centerPreview.frame(minWidth: 380)
            controls.frame(width: 300)
        }
    }

    // MARK: Left — target list

    private var targetList: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xs) {
            Text("EDIT")
                .font(.briefMeta).foregroundStyle(Color.briefInkTertiary)
                .padding(.bottom, BriefSpacing.xs)
            row("Section heading", .h2)
            row("Sub-heading", .h3)
            row("Lead-in label", .label)
            row("Body / value", .value)
            row("Provenance", .provenance)
            Divider().padding(.vertical, BriefSpacing.sm)
            row("Spacing & marker", .spacing)
            Spacer()
        }
        .padding(BriefSpacing.lg)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.briefPaperNav)
    }

    private func row(_ title: String, _ t: EditTarget) -> some View {
        Text(title)
            .font(.briefBodySmall)
            .foregroundStyle(target == t ? Color.briefInkPrimary : Color.briefInkSecondary)
            .padding(.horizontal, BriefSpacing.sm).padding(.vertical, BriefSpacing.xs + 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: BriefRadius.chip)
                .fill(target == t ? Color.briefSelectionActive : .clear))
            .contentShape(Rectangle())
            .onTapGesture { target = t }
    }

    // MARK: Center — the real document, live

    private var centerPreview: some View {
        ScrollView {
            LiveContextDocument(style: style)
                .frame(maxWidth: BriefLayout.readingWidth, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, BriefSpacing.huge)
                .padding(.vertical, BriefSpacing.xxl)
        }
        .background(Color.briefPaper)
    }

    // MARK: Right — controls for the selected target

    private var controls: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                switch target {
                case .h2:         textControls(\.h2)
                case .h3:         textControls(\.h3)
                case .label:      textControls(\.label)
                case .value:      textControls(\.value)
                case .provenance: textControls(\.provenance)
                case .spacing:    spacingControls
                }
                Divider().padding(.vertical, BriefSpacing.sm)
                Text("VALUES").font(.briefMeta).foregroundStyle(Color.briefInkTertiary)
                Text(style.valuesDump)
                    .font(.briefMonoMeta).foregroundStyle(Color.briefInkPrimary)
                    .textSelection(.enabled)
                    .padding(BriefSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: BriefRadius.chip).fill(Color.briefPaperSunken))
            }
            .padding(BriefSpacing.xl)
        }
        .background(Color.briefPaperNav)
    }

    // Text-style controls bound to a DocStyle keypath.
    private func textControls(_ kp: ReferenceWritableKeyPath<DocStyle, DocTextStyle>) -> some View {
        let s = style[keyPath: kp]
        return VStack(alignment: .leading, spacing: BriefSpacing.lg) {
            Text(s.label).font(.briefTitle3).foregroundStyle(Color.briefInkPrimary)

            // Weight / face
            Text("Weight").font(.briefBodySmall).foregroundStyle(Color.briefInkSecondary)
            Picker("", selection: Binding(
                get: { style[keyPath: kp].face },
                set: { style[keyPath: kp].face = $0 })) {
                ForEach(DocFontFace.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu).labelsHidden()

            sliderRow("Size", value: Binding(
                get: { style[keyPath: kp].size }, set: { style[keyPath: kp].size = $0 }),
                in: 10...40, step: 1, fmt: "%.0f")
            sliderRow("Line height", value: Binding(
                get: { style[keyPath: kp].lineHeight }, set: { style[keyPath: kp].lineHeight = $0 }),
                in: 1.0...1.4, step: 0.01, fmt: "%.2f")          // granular 1.0–1.4
            sliderRow("Tracking", value: Binding(
                get: { style[keyPath: kp].tracking }, set: { style[keyPath: kp].tracking = $0 }),
                in: -3...1, step: 0.1, fmt: "%.1f")

            ColorPicker("Color", selection: Binding(
                get: { style[keyPath: kp].color }, set: { style[keyPath: kp].color = $0 }),
                supportsOpacity: false)
                .font(.briefBodySmall)
        }
    }

    private var spacingControls: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.lg) {
            Text("Spacing & marker").font(.briefTitle3).foregroundStyle(Color.briefInkPrimary)
            sliderRow("Bullet gap (within group)", value: $style.bulletGap, in: 0...20, step: 1, fmt: "%.0f")
            sliderRow("Heading → body", value: $style.headingToBody, in: 0...28, step: 1, fmt: "%.0f")
            sliderRow("Group gap", value: $style.groupGap, in: 0...56, step: 1, fmt: "%.0f")
            sliderRow("Heading top", value: $style.headingTop, in: 8...64, step: 1, fmt: "%.0f")
            sliderRow("Marker inset", value: $style.markerInset, in: 2...20, step: 1, fmt: "%.0f")
        }
    }

    private func sliderRow(_ label: String, value: Binding<CGFloat>, in range: ClosedRange<CGFloat>, step: CGFloat, fmt: String) -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xxs) {
            HStack {
                Text(label).font(.briefBodySmall).foregroundStyle(Color.briefInkPrimary)
                Spacer()
                Text(String(format: fmt, Double(value.wrappedValue)))
                    .font(.briefMonoMeta).foregroundStyle(Color.briefInkSecondary)
            }
            Slider(value: Binding(get: { Double(value.wrappedValue) },
                                  set: { value.wrappedValue = CGFloat($0) }),
                   in: Double(range.lowerBound)...Double(range.upperBound), step: Double(step))
        }
    }
}
