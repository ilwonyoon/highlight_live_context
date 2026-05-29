import SwiftUI

// MARK: - PrivacyBucketCard
//
// One of the two — and only two — buckets the user ever sees:
//   🛡 Automatic   — "I handle this for you" (secrets dropped, personal kept out)
//   ✋ Your rules   — "the lines you drew yourself"
//
// Progressive disclosure: collapsed = a one-line summary + count; tap to expand
// the items/rules underneath. This is the proactive brief made structural — the
// user grasps the whole protection model in two glanceable rows, then drills in
// only if they want to (PRIVACY_MODEL.md: keep the UI a sentence).

struct PrivacyBucketCard: View {
    enum Kind { case automatic, yourRules }

    let kind: Kind
    let state: PrivacyState

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if expanded {
                Divider()
                    .overlay(Color.briefHairlineSoft)
                    .padding(.top, BriefSpacing.md)
                expandedBody
                    .padding(.top, BriefSpacing.md)
            }
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
        .contentShape(Rectangle())
        .onTapGesture { expanded.toggle() }
        .animation(.briefStandard, value: expanded)
    }

    // MARK: Header row — icon + title + summary + count + chevron

    private var headerRow: some View {
        HStack(alignment: .top, spacing: BriefSpacing.md) {
            Text(glyph)
                .font(.system(size: 16))
                .frame(width: 22, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: BriefSpacing.sm) {
                    Text(title)
                        .briefStyle(.headline)
                        .foregroundStyle(Color.briefInkPrimary)
                    countBadge
                }
                Text(summary)
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.briefInkTertiary)
                .rotationEffect(.degrees(expanded ? 0 : -90))
        }
    }

    private var countBadge: some View {
        Text(countText)
            .briefStyle(.monoMeta)
            .foregroundStyle(Color.briefInkTertiary)
            .padding(.horizontal, BriefSpacing.sm)
            .padding(.vertical, 1)
            .background(
                Capsule().fill(Color.briefInkPrimary.opacity(0.05))
            )
    }

    // MARK: Expanded body

    @ViewBuilder
    private var expandedBody: some View {
        switch kind {
        case .automatic:
            VStack(alignment: .leading, spacing: BriefSpacing.lg) {
                ForEach(AutoCategory.allCases) { cat in
                    let items = state.items(in: cat)
                    if !items.isEmpty {
                        AutoCategoryGroup(category: cat, items: items)
                    }
                }
            }
        case .yourRules:
            VStack(alignment: .leading, spacing: BriefSpacing.md) {
                ForEach(state.rules) { rule in
                    RuleRow(rule: rule)
                }
                addRuleHint
            }
        }
    }

    /// A quiet affordance reinforcing the conversational authoring path.
    private var addRuleHint: some View {
        HStack(spacing: BriefSpacing.sm) {
            Image(systemName: "plus.circle")
                .font(.system(size: 12))
                .foregroundStyle(Color.briefInkTertiary)
            Text("Say \u{201C}keep ___ private\u{201D} below to add a line.")
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkTertiary)
        }
        .padding(.top, BriefSpacing.xs)
    }

    // MARK: Per-kind copy

    private var glyph: String { kind == .automatic ? "\u{1F6E1}\u{FE0F}" : "\u{270B}" }

    private var title: String { kind == .automatic ? "Automatic" : "Your rules" }

    private var summary: String {
        switch kind {
        case .automatic:
            return "Secrets and personal life, kept out without you lifting a finger."
        case .yourRules:
            return "Boundaries only you know — drawn in your own words."
        }
    }

    private var countText: String {
        switch kind {
        case .automatic:
            return "\(state.autoItems.count) today"
        case .yourRules:
            let n = state.rules.count
            return n == 1 ? "1 rule" : "\(n) rules"
        }
    }
}

// MARK: - Automatic: one category group (Secrets / Personal life)

private struct AutoCategoryGroup: View {
    let category: AutoCategory
    let items: [AutoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            HStack(spacing: BriefSpacing.sm) {
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.briefInkSecondary)
                    .frame(width: 16)
                Text(category.title)
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
            }
            Text(category.summary)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 24)

            VStack(alignment: .leading, spacing: BriefSpacing.xs) {
                ForEach(items) { item in
                    AutoItemRow(item: item)
                }
            }
            .padding(.leading, 24)
            .padding(.top, 2)
        }
    }
}

/// One auto-protected item. For secrets the value is NEVER shown (echoSafe=false)
/// — only the kind + source. For personal, the echo-safe detail is shown.
private struct AutoItemRow: View {
    let item: AutoItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text("\u{2022}")
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkTertiary)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: BriefSpacing.xs) {
                    Text(item.label)
                        .briefStyle(.bodySmall)
                        .foregroundStyle(Color.briefInkPrimary)
                    Text("\u{00B7} \(item.sourceLabel)")
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                }
                if let detail = item.detail, item.category.echoSafe {
                    Text(detail)
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Your rules: one rule row

private struct RuleRow: View {
    let rule: PrivacyRule

    var body: some View {
        HStack(alignment: .top, spacing: BriefSpacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundStyle(Color.briefInkTertiary)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 1) {
                Text(rule.what)
                    .briefStyle(.body)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: BriefSpacing.xs) {
                    if let scope = rule.scopeLabel {
                        Text(scope)
                            .briefStyle(.monoMeta)
                            .foregroundStyle(Color.briefInkTertiary)
                        Text("\u{00B7}")
                            .briefStyle(.monoMeta)
                            .foregroundStyle(Color.briefInkTertiary)
                    }
                    Text(rule.retention.label)
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                }
            }
            Spacer(minLength: 0)
        }
        // Newly authored rules get a brief highlight wash (wish→rule, step 5).
        .padding(.vertical, BriefSpacing.xs)
        .padding(.horizontal, rule.justAdded ? BriefSpacing.sm : 0)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                .fill(rule.justAdded ? Color.briefHighlightWash : .clear)
        )
    }
}

#Preview("Bucket cards") {
    VStack(spacing: BriefSpacing.xl) {
        PrivacyBucketCard(kind: .automatic, state: .mock)
        PrivacyBucketCard(kind: .yourRules, state: .mock)
    }
    .padding(BriefSpacing.xxl)
    .frame(width: 400)
    .background(Color.briefPaper)
}
