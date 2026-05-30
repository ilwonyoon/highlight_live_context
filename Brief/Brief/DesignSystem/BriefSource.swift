import SwiftUI

// MARK: - Provenance source
// Every fact in a Brief carries a source. Eight sources total:
// 1 Highlight-native (voice/meeting) + 7 integrations.
//
// Inline in the brief body, all sources render in monochrome (inkPrimary tint)
// so the brand colors don't clutter the editorial reading surface.
// Brand colors are reserved for dedicated surfaces (Integrations cards).

enum BriefSource: String, CaseIterable, Hashable {
    case voice
    case gmail
    case github
    case notion
    case docs
    case slack
    case linear
    case cursor
    case gcal       // Google Calendar — connector (no brand SVG yet; SF fallback)
    case outlook    // Outlook Calendar — connector (no brand SVG yet; SF fallback)

    /// Display label for tooltips, accessibility, integration cards.
    var label: String {
        switch self {
        case .voice:   return "Meeting"
        case .gmail:   return "Gmail"
        case .github:  return "GitHub"
        case .notion:  return "Notion"
        case .docs:    return "Google Docs"
        case .slack:   return "Slack"
        case .linear:  return "Linear"
        case .cursor:  return "Cursor"
        case .gcal:    return "Google Calendar"
        case .outlook: return "Outlook"
        }
    }

    /// Asset name. Voice + calendars are rendered with SF Symbols (no brand SVG
    /// yet); the rest load bundled SVGs. Drop gcal.svg / outlook.svg into
    /// Resources/Icons to upgrade the calendars to real brand marks.
    var iconAssetName: String? {
        switch self {
        case .voice:   return nil // uses SF Symbol "waveform"
        case .gmail:   return "gmail"
        case .github:  return "github"
        case .notion:  return "notion"
        case .docs:    return "googledocs"
        case .slack:   return "slack"
        case .linear:  return "linear"
        case .cursor:  return "cursor"
        case .gcal:    return "gcal"     // falls back to SF until the SVG exists
        case .outlook: return "outlook"  // falls back to SF until the SVG exists
        }
    }

    /// SF Symbol fallback (used for voice; also fallback if SVG fails to load).
    var sfSymbol: String {
        switch self {
        case .voice:   return "waveform"
        case .gmail:   return "envelope"
        case .github:  return "chevron.left.forwardslash.chevron.right"
        case .notion:  return "doc.text"
        case .docs:    return "doc.richtext"
        case .slack:   return "number"
        case .linear:  return "square.stack.3d.up"
        case .cursor:  return "cursorarrow.rays"
        case .gcal:    return "calendar"
        case .outlook: return "calendar.badge.clock"
        }
    }
}
