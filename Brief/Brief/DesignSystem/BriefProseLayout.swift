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

    /// Greedy line breaking.
    ///
    /// The cascading one-glyph-per-line break we used to hit came from continuing a
    /// line *after* a child had wrapped internally. SwiftUI's Layout API exposes no
    /// per-line geometry, and a placed `Text` renders *all* its lines from the origin
    /// it's given — it does not reflow its continuation back to the container's left
    /// edge. So "fill the tail of this line, then wrap to the margin" is impossible
    /// for a single child; attempting it is what corrupted the pen.
    ///
    /// Given that, the rule is simple and correct: a child is **atomic on a line**.
    /// • If its natural width fits the remaining space, place it inline.
    /// • Otherwise break to a fresh, full-width line and place it there — where, if it
    ///   is a long run, it wraps cleanly because every one of its lines shares the
    ///   left edge. A long run then closes the line after itself (no child may sit on
    ///   its unknowable last line).
    ///
    /// The cost is an occasional short line before a long run — ragged, but never
    /// broken. (To pack tighter, split runs into word-children upstream; not needed
    /// for the brief's short clauses.)
    private func layoutLines(maxWidth: CGFloat, subviews: Subviews) -> [Line] {
        var lines: [Line] = []
        var current = Line()
        var penX: CGFloat = 0

        func closeLine() {
            if !current.items.isEmpty {
                current.width = penX - itemSpacing
                lines.append(current)
            }
            current = Line()
            penX = 0
        }

        func append(_ index: Int, _ sv: Subviews.Element, _ size: CGSize) {
            let ascent = sv.dimensions(in: ProposedViewSize(width: size.width, height: size.height))[.firstTextBaseline]
            current.items.append(Item(index: index, x: penX, size: size, ascent: ascent))
            current.height = max(current.height, size.height)
            current.maxAscent = max(current.maxAscent, ascent)
            penX += size.width + itemSpacing
        }

        for index in subviews.indices {
            let sv = subviews[index]
            let remaining = max(0, maxWidth - penX)

            // Natural single-line footprint, and whether it fits in what's left.
            let natural = sv.sizeThatFits(ProposedViewSize(width: .infinity, height: nil))

            if natural.width <= remaining + 0.5 {
                append(index, sv, natural)        // fits inline, unbroken
                continue
            }

            // Doesn't fit: break first so the child owns the full line width.
            if !current.items.isEmpty { closeLine() }

            let full = sv.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            append(index, sv, full)
            // If it wrapped to multiple lines, nothing may follow on its last line.
            if full.height > natural.height + 0.5 { closeLine() }
        }
        closeLine()
        return lines
    }
}
