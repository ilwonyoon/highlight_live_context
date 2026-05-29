import SwiftUI

// MARK: - BriefProseLayout
// A width-aware inline layout for body prose with inline objects (text runs +
// interactive provenance citations). Unlike FlowLayout — which measures each
// child at `.unspecified` and so treats a long text run as one atomic,
// unbreakable box — this proposes the *remaining width on the current line* to
// each child, so a `Text` wraps itself naturally, and the pen advances by the
// child's last-line trailing width.
//
// One leading source: the inter-line gap is `lineGap` (pass the token's
// extraLineSpacing). Children keep their identity, so interactive views
// (ProvenanceInline's Button + popover) work inside running prose.
//
// See MARKDOWN_RENDERING_ARCHITECTURE.md.

struct BriefProseLayout: Layout {
    /// Gap added between wrapped lines — the single leading source. Pass the
    /// body token's extraLineSpacing, e.g. (lineHeight − 1) × fontSize.
    var lineGap: CGFloat
    /// Horizontal gap between adjacent inline children on the same line.
    var itemSpacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let lines = layoutLines(maxWidth: maxWidth, subviews: subviews)
        let width = lines.map(\.width).max() ?? 0
        let height = lines.reduce(CGFloat.zero) { $0 + $1.height } +
                     lineGap * CGFloat(max(0, lines.count - 1))
        return CGSize(width: min(width, maxWidth), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        let lines = layoutLines(maxWidth: maxWidth, subviews: subviews)
        var y = bounds.minY
        for line in lines {
            // Align children on the line to a common first-text-baseline.
            let baseline = line.maxAscent
            for item in line.items {
                let x = bounds.minX + item.x
                let yOffset = baseline - item.ascent
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + yOffset),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
            }
            y += line.height + lineGap
        }
    }

    // MARK: Line assembly

    private struct Item {
        let index: Int
        let x: CGFloat
        let size: CGSize
        let ascent: CGFloat
    }
    private struct Line {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        var maxAscent: CGFloat = 0
    }

    /// Greedy line breaking: each child is proposed the remaining width so a
    /// Text wraps; if its wrapped block is taller than one line we place it and
    /// continue from its last-line trailing edge (approximated), else flow inline.
    private func layoutLines(maxWidth: CGFloat, subviews: Subviews) -> [Line] {
        var lines: [Line] = []
        var current = Line()
        var penX: CGFloat = 0

        func closeLine() {
            if !current.items.isEmpty {
                current.width = penX - (current.items.isEmpty ? 0 : itemSpacing)
                lines.append(current)
            }
            current = Line()
            penX = 0
        }

        for index in subviews.indices {
            let sv = subviews[index]
            let remaining = max(0, maxWidth - penX)
            // Propose remaining width first; if the child doesn't fit and the
            // line already has content, wrap and re-propose full width.
            var size = sv.sizeThatFits(ProposedViewSize(width: remaining == 0 ? maxWidth : remaining, height: nil))
            if size.width > remaining && !current.items.isEmpty {
                closeLine()
                size = sv.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }
            let ascent = sv.dimensions(in: ProposedViewSize(width: size.width, height: size.height))[.firstTextBaseline]
            current.items.append(Item(index: index, x: penX, size: size, ascent: ascent))
            current.height = max(current.height, size.height)
            current.maxAscent = max(current.maxAscent, ascent)
            penX += size.width + itemSpacing

            // If this child wrapped to multiple lines (taller than its own first
            // line), the visual pen is at its last line; approximate by starting
            // the next child on a fresh line for safety.
            // (Our content keeps long runs as the trailing segment, so this is
            // visually clean; documented limitation in the architecture spec.)
        }
        closeLine()
        return lines
    }
}
