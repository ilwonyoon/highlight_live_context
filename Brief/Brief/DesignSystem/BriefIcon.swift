import SwiftUI
import AppKit

// MARK: - Icon loader for bundled SVG brand marks
// macOS 14+ NSImage can load SVG directly. We force template rendering
// so inline provenance icons inherit the foregroundStyle color.

enum BriefIconRendering {
    case template  // monochrome, tint via foregroundStyle (inline brief body)
    case original  // brand color preserved (Integrations cards)
}

struct BriefIcon: View {
    let source: BriefSource
    let size: CGFloat
    let rendering: BriefIconRendering

    init(_ source: BriefSource, size: CGFloat = 14, rendering: BriefIconRendering = .template) {
        self.source = source
        self.size = size
        self.rendering = rendering
    }

    var body: some View {
        if let image = loadedImage {
            Image(nsImage: image)
                .resizable()
                .renderingMode(rendering == .template ? .template : .original)
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            // Fallback: SF Symbol
            Image(systemName: source.sfSymbol)
                .font(.system(size: size * 0.9, weight: .medium))
                .frame(width: size, height: size)
        }
    }

    private var loadedImage: NSImage? {
        guard let name = source.iconAssetName else { return nil }
        let url = Bundle.main.url(forResource: name, withExtension: "svg", subdirectory: "Icons")
              ?? Bundle.main.url(forResource: name, withExtension: "svg")
        guard let url else { return nil }
        return NSImage(contentsOf: url)
    }
}
