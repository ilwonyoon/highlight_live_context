import SwiftUI

// MARK: - PrivacyScenario — privacy as the first PanelScenario
//
// Plugs the privacy domain into the general ChatPanel. The panel knows nothing
// about privacy; this adapter supplies the proactive brief, the drill-in detail
// screens, and (later) the wish→scan→rule flow — all as PanelTurns/PanelCards.
//
// Reuses the existing privacy model (PrivacyState) and the bucket-card view
// (PrivacyBucketCard) verbatim; this file is just the bridge between them and
// the chat panel.
//
// See PRIVACY_EXECUTION.md §5.

@MainActor
final class PrivacyScenario: PanelScenario {
    /// The privacy state this scenario reads and edits. Mock for now; wiring it
    /// to a shared store (so the main window's count updates) comes next.
    private var state = PrivacyState.mock

    var title: String { "Manage privacy" }
    var composerPlaceholder: String { "Tell me what to keep private…" }

    // MARK: Opening — the proactive brief (the assistant has already laid out
    // how protection works right now), then the two bucket cards.

    func openingTurns() -> [PanelTurn] {
        [
            .assistantText("Here's how I'm protecting you right now. Two things I handle automatically, and the lines you've drawn yourself. Tell me what to change — you don't have to touch a setting."),
            // Both buckets in ONE card (Automatic above, Your rules below).
            .assistantCard(BucketsCombinedCard(state: state)),
        ]
    }

    // MARK: Drill-in destinations — Automatic / Your rules, in full.

    func detailDestinations() -> [PanelDestination] {
        [
            PanelDestination(title: "Automatic", card: BucketCard(kind: .automatic, state: state, expanded: true)),
            PanelDestination(title: "Your rules", card: BucketCard(kind: .yourRules, state: state, expanded: true)),
        ]
    }

    // MARK: Respond — turn a spoken wish into a rule.
    //
    // First pass: acknowledge + create the rule + confirm. The scan-and-propose
    // step (find matching items, ask before applying) lands next.

    func respond(to userText: String) async -> [PanelTurn] {
        let rule = PrivacyRule(what: userText.trimmingCharacters(in: .whitespacesAndNewlines))
        return [
            .assistantThinking("Looking through what I've captured…"),
            .assistantText("Done — I'll keep anything about \u{201C}\(rule.what)\u{201D} out of your work context, across every source. You can change or undo this anytime, just tell me."),
            .assistantCard(RuleCreatedCard(rule: rule)),
        ]
    }

    func confirm(_ action: any PanelAction) async -> [PanelTurn] {
        []   // no confirmable CTAs in the first pass (added with the scan flow)
    }
}

// MARK: - Cards (PanelCard wrappers around the existing privacy views)

/// The two buckets as ONE card — Automatic above, Your rules below, in a single
/// surface (the merged top block). Each still drills in via its own chevron.
private struct BucketsCombinedCard: PanelCard {
    let state: PrivacyState
    func makeBody() -> some View {
        VStack(spacing: BriefSpacing.lg) {
            PrivacyBucketCard(kind: .automatic, state: state)
            PrivacyBucketCard(kind: .yourRules, state: state)
        }
    }
}

/// Wraps the existing PrivacyBucketCard so the chat panel can host it without
/// knowing what it is. `expanded` pre-opens it for the detail screens.
private struct BucketCard: PanelCard {
    let kind: PrivacyBucketCard.Kind
    let state: PrivacyState
    var expanded: Bool = false

    func makeBody() -> some View {
        PrivacyBucketCard(kind: kind, state: state, startExpanded: expanded)
    }
}

/// The confirmation card after a rule is authored — the new rule, materialized.
private struct RuleCreatedCard: PanelCard {
    let rule: PrivacyRule

    func makeBody() -> some View {
        HStack(alignment: .top, spacing: BriefSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.briefHighlightDeep)
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.what)
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("New rule · applies across all sources")
                    .briefStyle(.monoMeta)
                    .foregroundStyle(Color.briefInkTertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefHighlightWash)
        )
    }
}
