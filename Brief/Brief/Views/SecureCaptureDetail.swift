import SwiftUI

// MARK: - SecureCaptureBanner

struct SecureCaptureBanner: View {
    var variation: SecureCaptureVariation = .A
    @State private var expanded = false
    @State private var scanY: CGFloat = -1.0       // A: scan line position (0–1 of card height)
    @State private var shieldScale: CGFloat = 1.0  // A+D: shield heartbeat
    @State private var borderPhase: CGFloat = 0.0  // D: border trace phase

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            variation.header(expanded: $expanded, shieldScale: shieldScale)
            if expanded {
                SecureCaptureDetail(onDark: true)
                    .transition(.opacity)
                    .padding(.horizontal, BriefSpacing.xl)
                    .padding(.bottom, BriefSpacing.md)
            }
        }
        .animation(.briefStandard, value: expanded)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous))
        .overlay(borderOverlay)
        .onAppear(perform: startAnimations)
    }

    // MARK: Background

    @ViewBuilder
    private var background: some View {
        switch variation {
        case .A:
            ZStack(alignment: .top) {
                Color(white: 0.08)
                // Scan line — a soft horizontal band sweeping top→bottom
                GeometryReader { geo in
                    let h = geo.size.height
                    LinearGradient(
                        stops: [
                            .init(color: .clear,                              location: 0),
                            .init(color: Color.briefHighlight.opacity(0.18),  location: 0.5),
                            .init(color: .clear,                              location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 28)
                    .offset(y: scanY * h - 14)
                    .blur(radius: 4)
                }
            }
        case .D:
            Color(white: 0.08)
        }
    }

    // MARK: Border overlay (D only — animated trace)

    @ViewBuilder
    private var borderOverlay: some View {
        if variation == .D {
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: .clear,                              location: 0),
                            .init(color: .clear,                              location: max(0, borderPhase - 0.15)),
                            .init(color: Color.briefHighlight.opacity(0.9),   location: borderPhase),
                            .init(color: Color.briefHighlight.opacity(0.0),   location: min(1, borderPhase + 0.08)),
                            .init(color: .clear,                              location: 1),
                        ],
                        center: .center,
                        angle: .degrees(borderPhase * 360)
                    ),
                    lineWidth: 1.5
                )
        }
    }

    // MARK: Animations

    private func startAnimations() {
        // Shield heartbeat — both variations
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            shieldScale = 1.08
        }
        switch variation {
        case .A:
            // Scan line — 4s loop, pause at bottom before reset
            animateScan()
        case .D:
            // Border trace — continuous rotation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                borderPhase = 1.0
            }
        }
    }

    private func animateScan() {
        scanY = 0
        withAnimation(.easeIn(duration: 2.8)) {
            scanY = 1.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            scanY = -0.1
            animateScan()
        }
    }
}

// MARK: - Variation enum

enum SecureCaptureVariation: Equatable {
    case A  // dark + scan line sweep + shield pulse
    case D  // dark + border trace + shield pulse

    var onDark: Bool { true }

    @ViewBuilder
    func header(expanded: Binding<Bool>, shieldScale: CGFloat) -> some View {
        HStack(spacing: BriefSpacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.briefHighlight)
                .scaleEffect(shieldScale)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: shieldScale)
            Text("Secure Capture")
                .briefStyle(.bodyMedium)
                .foregroundStyle(.white)
            Spacer(minLength: 0)
            Button { expanded.wrappedValue.toggle() } label: {
                HStack(spacing: BriefSpacing.xs) {
                    Text("What's protected?")
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefHighlight.opacity(0.8))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.briefHighlight.opacity(0.7))
                        .rotationEffect(.degrees(expanded.wrappedValue ? 0 : -90))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BriefSpacing.xl)
        .padding(.vertical, BriefSpacing.md)
    }
}

// MARK: - SecureCaptureDetail — what's protected explainer

struct SecureCaptureDetail: View {
    var onDark: Bool = false

    private var primary: Color   { onDark ? .white : Color.briefInkPrimary }
    private var secondary: Color { onDark ? .white.opacity(0.65) : Color.briefInkSecondary }
    private var bullet: Color    { onDark ? .white.opacity(0.35) : Color.briefInkTertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            point("Automatic filtering",
                  "Highlight automatically filters out sensitive categories such as banks, government sites, and medical portals.")
            point("Stored locally, encrypted",
                  "Captured data is encrypted and stored locally on your device. Highlight cannot access your raw data.")
            point("Never used for training",
                  "Your data is never used to train AI models.")
        }
        .padding(.top, BriefSpacing.sm)
        .padding(.bottom, BriefSpacing.xs)
    }

    private func point(_ title: String, _ body: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
            Text("•")
                .briefStyle(.bodySmall)
                .foregroundStyle(bullet)
                .frame(width: 8, alignment: .center)
            VStack(alignment: .leading, spacing: BriefSpacing.xxs) {
                Text(title)
                    .briefStyle(.bodySmall)
                    .foregroundStyle(primary)
                Text(body)
                    .briefStyle(.bodySmall)
                    .foregroundStyle(secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Banner Test Page

struct SecureCaptureBannerTestView: View {
    var body: some View {
        SelectionSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: BriefSpacing.xxxl) {
                    VStack(alignment: .leading, spacing: BriefSpacing.xs) {
                        Text("Secure Capture — Banner Variations")
                            .briefStyle(.bodyMedium)
                            .foregroundStyle(Color.briefInkPrimary)
                        Text("Tap 'What's protected?' on each to see expanded state.")
                            .briefStyle(.bodySmall)
                            .foregroundStyle(Color.briefInkSecondary)
                    }
                    bannerRow("A — Scan line sweep + shield pulse", .A)
                    bannerRow("D — Border trace + shield pulse", .D)
                    Spacer(minLength: BriefSpacing.mega)
                }
                .frame(maxWidth: BriefLayout.readingWidth, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, BriefSpacing.huge)
                .padding(.top, BriefSpacing.xxl)
            }
        }
    }

    private func bannerRow(_ label: String, _ v: SecureCaptureVariation) -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            Text(label)
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkTertiary)
            SecureCaptureBanner(variation: v)
        }
    }
}

#Preview("Banner Test") {
    SecureCaptureBannerTestView()
        .frame(width: 700, height: 500)
        .background(Color.briefPaper)
}
