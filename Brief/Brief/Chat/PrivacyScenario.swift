import SwiftUI

// MARK: - PrivacyScenario — bridge between chat panel and PrivacyStore
//
// Plugs into PanelScenario so the general ChatPanel drives privacy settings
// via natural language. The scenario holds a reference to the shared PrivacyStore
// so changes made in chat are immediately visible in PrivacySettingsView.
//
// The flow enforces the proposal pattern — AI never mutates directly:
//   user text → PrivacyIntentParser → PrivacyProposal card → user confirms → store.apply()

@MainActor
final class PrivacyScenario: PanelScenario {
    private let store: PrivacyStore

    init(store: PrivacyStore = PrivacyStore()) {
        self.store = store
    }

    var title: String { "Privacy" }
    var composerPlaceholder: String { "Tell me what to keep private…" }

    // MARK: Opening brief

    func openingTurns() -> [PanelTurn] {
        let filterCount = store.userFilters.count
        let autoCount = store.automaticFilters.count
        return [
            .assistantText("Here's how I'm protecting you right now. \(autoCount) automatic rules are always on, and you've set \(filterCount) of your own. Tell me what to change — I'll show you exactly what will happen before anything is applied."),
            .assistantCard(CurrentStateCard(store: store)),
        ]
    }

    // MARK: Respond — parse → propose, never apply directly

    func respond(to userText: String) async -> [PanelTurn] {
        // Simulate a brief thinking pause
        try? await Task.sleep(nanoseconds: 400_000_000)

        let intent = PrivacyIntentParser.parse(userText, store: store)

        switch intent {
        case .unrecognized(let raw):
            return [
                .assistantText("I wasn't sure what to do with \"\(raw)\". Try something like \"Block Slack\", \"Stop keeping anything about salary\", or \"Turn off screen capture\"."),
            ]
        default:
            let proposal = PrivacyProposal(intent: intent, store: store)
            return [
                .assistantText(proposal.explanation),
                .assistantCard(ProposalCard(proposal: proposal, store: store)),
            ]
        }
    }

    // MARK: Confirm — user tapped the confirm button in a ProposalCard

    func confirm(_ action: any PanelAction) async -> [PanelTurn] {
        guard let privacyAction = action as? PrivacyProposalAction else { return [] }
        let result = store.apply(privacyAction.intent)
        return [
            .assistantText(result.success
                ? "Done. \(result.summary)"
                : result.summary),
        ]
    }

    func detailDestinations() -> [PanelDestination] { [] }
}

// MARK: - PrivacyProposal — the intermediate "here's what will change" state

struct PrivacyProposal {
    let intent: PrivacyIntent
    let explanation: String
    let impactNote: String
    let confirmLabel: String

    init(intent: PrivacyIntent, store: PrivacyStore) {
        self.intent = intent
        switch intent {

        case .addAppSite(let name):
            explanation = "I'll add **\(name)** to your blocked apps & sites. New activity from \(name) won't be captured."
            impactNote = "Existing \(name) content in your Live Context will stay until it expires naturally."
            confirmLabel = "Block \(name)"

        case .addTopicFilter(let statement):
            explanation = "I'll add a filter: \"\(statement)\". Anything matching this topic will be kept out of your work context."
            impactNote = "This applies to new captures only. Existing content isn't affected."
            confirmLabel = "Add filter"

        case .addTag(let label, _):
            explanation = "I'll add \"\(label)\" as a keyword to an existing filter."
            impactNote = "The filter will start catching this term immediately."
            confirmLabel = "Add keyword"

        case .removeFilter(let id):
            let name = store.userFilters.first(where: { $0.id == id })?.statement ?? "this filter"
            explanation = "I'll remove \"\(name)\". Content matching it will no longer be filtered."
            impactNote = "This can't be undone automatically — you'd need to recreate it."
            confirmLabel = "Remove filter"

        case .pauseFilter(let id):
            let name = store.userFilters.first(where: { $0.id == id })?.statement ?? "this filter"
            explanation = "I'll pause \"\(name)\". It stays saved but won't filter anything while paused."
            impactNote = "You can resume it any time."
            confirmLabel = "Pause filter"

        case .resumeFilter(let id):
            let name = store.userFilters.first(where: { $0.id == id })?.statement ?? "this filter"
            explanation = "I'll resume \"\(name)\". It will start filtering again immediately."
            impactNote = "Content captured while it was paused isn't retroactively filtered."
            confirmLabel = "Resume filter"

        case .updateStatement(_, let text):
            explanation = "I'll rename this filter to: \"\(text)\"."
            impactNote = "The keywords inside aren't affected — only the label changes."
            confirmLabel = "Rename filter"

        case .updateDuration(_, let duration):
            explanation = "I'll change the retention to: \(duration.label)."
            impactNote = "Applies to future captures. Existing content follows its original retention."
            confirmLabel = "Update retention"

        case .setScreenContext(let on):
            explanation = on
                ? "I'll turn screen capture back on. Highlight will resume building your Live Context."
                : "I'll turn off screen capture. Nothing new will be captured until you turn it back on."
            impactNote = on
                ? "New activity will start appearing in your Live Context."
                : "Your existing Live Context is preserved — only new capture stops."
            confirmLabel = on ? "Enable capture" : "Stop capture"

        case .setSecureCapture(let on):
            explanation = on
                ? "I'll enable Secure Capture. Sensitive sites (banking, health, auth) will be automatically blocked."
                : "I'll disable Secure Capture. Sensitive sites will no longer be automatically blocked."
            impactNote = "Secure Capture is a standing protection — disabling it is a significant change."
            confirmLabel = on ? "Enable Secure Capture" : "Disable Secure Capture"

        case .setTelemetry(let on):
            explanation = on
                ? "I'll enable telemetry sharing. Anonymized logs will help the Highlight team fix issues."
                : "I'll turn off telemetry sharing. No logs will be sent to Highlight."
            impactNote = "Only anonymized, non-personal data is ever shared."
            confirmLabel = on ? "Enable telemetry" : "Stop sharing"

        case .unrecognized:
            explanation = "I couldn't parse that."
            impactNote = ""
            confirmLabel = "OK"
        }
    }
}

// MARK: - PrivacyProposalAction — the PanelAction carrying the confirmed intent

struct PrivacyProposalAction: PanelAction {
    let intent: PrivacyIntent
}

// MARK: - Cards

// Current state summary card shown in the opening brief
private struct CurrentStateCard: PanelCard {
    let store: PrivacyStore

    func makeBody() -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            row(icon: "app.fill",
                label: "Blocked apps & sites",
                value: "\(store.userFilters.filter { $0.layer == .appSite }.flatMap { $0.tags }.count) blocked")
            Divider().padding(.horizontal, BriefSpacing.xs)
            row(icon: "text.magnifyingglass",
                label: "Topic filters",
                value: "\(store.userFilters.filter { $0.layer == .topicKeyword }.count) active")
            Divider().padding(.horizontal, BriefSpacing.xs)
            row(icon: "checkmark.shield.fill",
                label: "Automatic protection",
                value: "\(store.automaticFilters.count) rules · always on")
            Divider().padding(.horizontal, BriefSpacing.xs)
            row(icon: "display",
                label: "Screen capture",
                value: store.capture.screenContext ? "On" : "Off")
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                    .stroke(Color.briefHairlineSoft, lineWidth: 1))
        )
    }

    private func row(icon: String, label: String, value: String) -> some View {
        HStack(spacing: BriefSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: 16)
            Text(label)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkSecondary)
            Spacer(minLength: 0)
            Text(value)
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
        }
    }
}

// Proposal card — shown before the user confirms
private struct ProposalCard: PanelCard {
    let proposal: PrivacyProposal
    let store: PrivacyStore

    var primaryAction: PanelActionButton? {
        PanelActionButton(
            label: proposal.confirmLabel,
            action: PrivacyProposalAction(intent: proposal.intent)
        )
    }

    func makeBody() -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            // Impact note
            if !proposal.impactNote.isEmpty {
                HStack(alignment: .top, spacing: BriefSpacing.sm) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.briefInkTertiary)
                        .padding(.top, 1)
                    Text(proposal.impactNote)
                        .briefStyle(.bodySmall)
                        .foregroundStyle(Color.briefInkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                    .stroke(Color.briefHairlineSoft, lineWidth: 1))
        )
    }
}
