import SwiftUI

// MARK: - DocStyle
// A live, editable design-token model for the Live Context document. Both the
// document and the editor reference one shared instance, so tuning a value in
// the editor updates the real document immediately. Once values are dialed in,
// copy them into the permanent BriefFont/BriefMarkdown tokens.
//
// Holds: per-type text styles (weight/size/line-height/tracking/color) for the
// types that make up the doc, plus the vertical-rhythm spacing and the bullet
// marker. line-height is editable down to 1.0 with fine (0.01) granularity.

/// Söhne has three real weights; Family (serif) is the hero option.
enum DocFontFace: String, CaseIterable, Identifiable {
    case soehneBuch       // 400
    case soehneKraftig    // 500
    case soehneHalbfett   // 600
    case familyMedium     // serif hero

    var id: String { rawValue }
    var label: String {
        switch self {
        case .soehneBuch:     return "Buch 400"
        case .soehneKraftig:  return "Kräftig 500"
        case .soehneHalbfett: return "Halbfett 600"
        case .familyMedium:   return "Family serif"
        }
    }
    /// The PostScript font at a given size.
    func font(size: CGFloat) -> Font {
        switch self {
        case .soehneBuch:     return .custom("\(BriefFontFamily.soehne)-Buch", size: size)
        case .soehneKraftig:  return .custom("\(BriefFontFamily.soehne)-Kraftig", size: size)
        case .soehneHalbfett: return .custom("\(BriefFontFamily.soehne)-Halbfett", size: size)
        case .familyMedium:   return .custom("\(BriefFontFamily.family)-Bold", size: size) // serif hero (Bold is the lightest Family we have)
        }
    }
}

/// One editable text style.
struct DocTextStyle: Identifiable {
    let id: String          // stable key (e.g. "h2")
    let label: String       // display name in the editor
    var face: DocFontFace
    var size: CGFloat
    var lineHeight: CGFloat // multiple
    var tracking: CGFloat   // points
    var color: Color

    var font: Font { face.font(size: size) }
    /// Extra lineSpacing for SwiftUI (.lineSpacing adds beyond natural leading).
    var extraLineSpacing: CGFloat { max(0, (lineHeight - 1) * size) }
}

final class DocStyle: ObservableObject {
    // Text types that compose the document.
    @Published var h2: DocTextStyle
    @Published var h3: DocTextStyle
    @Published var label: DocTextStyle
    @Published var value: DocTextStyle
    @Published var provenance: DocTextStyle

    // Vertical rhythm (Ilwon's chosen defaults).
    @Published var bulletGap: CGFloat = 7        // within a group
    @Published var headingToBody: CGFloat = 12   // sub-heading → its bullets
    @Published var groupGap: CGFloat = 12        // group → next heading
    @Published var headingTop: CGFloat = 24      // above an H2 section

    // Bullet marker.
    @Published var markerInset: CGFloat = 8       // gap marker → text
    @Published var markerSize: CGFloat = 4.5      // dot diameter (0 = use glyph)

    init() {
        h2 = DocTextStyle(id: "h2", label: "Section heading (H2)",
                          face: .soehneKraftig, size: 17, lineHeight: 1.25, tracking: -0.2, color: .briefInkPrimary)
        h3 = DocTextStyle(id: "h3", label: "Sub-heading (H3)",
                          face: .soehneKraftig, size: 14, lineHeight: 1.40, tracking: 0, color: .briefInkPrimary)
        label = DocTextStyle(id: "label", label: "Lead-in label",
                             face: .soehneBuch, size: 14, lineHeight: 1.20, tracking: 0, color: .briefInkPrimary)
        value = DocTextStyle(id: "value", label: "Body / value",
                             face: .soehneBuch, size: 14, lineHeight: 1.20, tracking: 0, color: .briefInkSecondary)
        provenance = DocTextStyle(id: "provenance", label: "Provenance phrase",
                                  face: .soehneKraftig, size: 14, lineHeight: 1.20, tracking: 0, color: .briefInkPrimary)
    }

    /// All text styles, for the editor's target list.
    var textStyles: [DocTextStyle] { [h2, h3, label, value, provenance] }

    /// Values dump for copying back into permanent tokens.
    var valuesDump: String {
        func line(_ s: DocTextStyle) -> String {
            "\(s.id): \(s.face.rawValue) \(Int(s.size))pt  lh \(String(format: "%.2f", s.lineHeight))  track \(String(format: "%.1f", s.tracking))"
        }
        return """
        — Text —
        \(line(h2))
        \(line(h3))
        \(line(label))
        \(line(value))
        \(line(provenance))
        — Spacing —
        bulletGap: \(Int(bulletGap))
        headingToBody: \(Int(headingToBody))
        groupGap: \(Int(groupGap))
        headingTop: \(Int(headingTop))
        markerInset: \(Int(markerInset))
        markerSize: \(String(format: "%.1f", markerSize))
        """
    }
}
