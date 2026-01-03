//
//  CosmosComponents.swift
//  Cosmos Productivity Suite - Stakk
//
//  Reusable UI components following COMPONENT_LIBRARY.md
//

import SwiftUI

// MARK: - Primary Button
struct CosmosPrimaryButton: View {
    let title: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        _ title: String,
        color: Color = .nebulaPurple,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.play(.lightTap)
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: CosmosRadius.lg)
                    .fill(isLoading ? color.opacity(0.6) : color)
            )
            .shadow(color: color.opacity(0.4), radius: 8)
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading" : "Double tap to activate")
    }
}

// MARK: - Secondary Button
struct CosmosSecondaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(
        _ title: String,
        color: Color = .nebulaLavender,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.play(.lightTap)
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: CosmosRadius.lg)
                        .stroke(color.opacity(0.5), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: CosmosRadius.lg)
                                .fill(Color.cardBackground.opacity(0.5))
                        )
                )
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Icon Button
struct CosmosIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    init(
        icon: String,
        color: Color = .nebulaLavender,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.play(.lightTap)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(Color.cardBackground.opacity(0.7))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel(icon)
    }
}

// MARK: - Card Container
struct CosmosCard<Content: View>: View {
    let opacity: CGFloat
    let borderColor: Color
    var isMinimalist: Bool = ThemeManager.shared.isMinimalist
    let content: Content

    init(
        opacity: CGFloat = 0.7,
        borderColor: Color = .nebulaLavender,
        isMinimalist: Bool = ThemeManager.shared.isMinimalist,
        @ViewBuilder content: () -> Content
    ) {
        self.opacity = opacity
        self.borderColor = borderColor
        self.isMinimalist = isMinimalist
        self.content = content()
    }

    private var cardBg: Color {
        isMinimalist ? .minCard : .cardBackground
    }

    private var strokeColor: Color {
        isMinimalist ? .minSubtle : borderColor
    }

    var body: some View {
        content
            .padding(CosmosSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: CosmosRadius.lg)
                    .fill(cardBg.opacity(opacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmosRadius.lg)
                            .stroke(strokeColor.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Empty State
struct CosmosEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: CosmosSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.nebulaLavender.opacity(0.4))

            VStack(spacing: CosmosSpacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.nebulaLavender.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                CosmosPrimaryButton(actionTitle, action: action)
                    .padding(.horizontal, CosmosSpacing.xxl)
            }
        }
        .padding(CosmosSpacing.xl)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Progress Ring
struct CosmosProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        progress: Double,
        color: Color = .nebulaCyan,
        lineWidth: CGFloat = 8,
        size: CGFloat = 60
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(
                    reduceMotion ? .none : .easeInOut(duration: CosmosDuration.normal),
                    value: progress
                )
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int(progress * 100))% complete")
    }
}

// MARK: - Toast View
struct CosmosToast: View {
    let message: String
    let type: ToastType
    let isShowing: Bool

    enum ToastType {
        case success
        case error
        case info

        var color: Color {
            switch self {
            case .success: return .nebulaCyan
            case .error: return .nebulaMagenta
            case .info: return .nebulaLavender
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        if isShowing {
            HStack(spacing: CosmosSpacing.sm) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, CosmosSpacing.lg)
            .padding(.vertical, CosmosSpacing.md)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
                    .shadow(color: type.color.opacity(0.3), radius: 8)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Celebration Overlay
struct CosmosCelebration: View {
    let isShowing: Bool
    let message: String
    let streakCount: Int?

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let delay: Double
        let color: Color
    }

    var body: some View {
        if isShowing {
            ZStack {
                // Confetti particles
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .offset(x: particle.x)
                        .modifier(ConfettiModifier(delay: particle.delay))
                }

                // Message
                VStack(spacing: CosmosSpacing.md) {
                    if let streak = streakCount {
                        Text("🔥 \(streak) Day Streak!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(message)
                        .font(.headline)
                        .foregroundColor(.nebulaLavender)
                        .multilineTextAlignment(.center)
                }
                .padding(CosmosSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: CosmosRadius.xl)
                        .fill(Color.cardBackground)
                        .shadow(color: .nebulaMagenta.opacity(0.4), radius: 20)
                )
            }
            .onAppear {
                generateParticles()
                HapticManager.shared.play(.celebration)
            }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [.nebulaCyan, .nebulaMagenta, .nebulaGold, .nebulaPurple]
        particles = (0..<20).map { i in
            Particle(
                x: CGFloat.random(in: -150...150),
                delay: Double(i) * 0.05,
                color: colors.randomElement() ?? .nebulaCyan
            )
        }
    }
}

struct ConfettiModifier: ViewModifier {
    let delay: Double
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .offset(y: animate ? 400 : -100)
            .opacity(animate ? 0 : 1)
            .animation(
                .easeOut(duration: 2)
                .delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

// MARK: - Text Field
struct CosmosTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    var isMinimalist: Bool = ThemeManager.shared.isMinimalist

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isMinimalist: Bool = ThemeManager.shared.isMinimalist
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isMinimalist = isMinimalist
    }

    private var cardBg: Color {
        isMinimalist ? .minCard : .cardBackground
    }

    private var textPrimary: Color {
        isMinimalist ? .minTextPrimary : .white
    }

    private var textSecondary: Color {
        isMinimalist ? .minTextTertiary : .nebulaLavender.opacity(0.5)
    }

    private var strokeColor: Color {
        isMinimalist ? .minSubtle : .nebulaLavender
    }

    var body: some View {
        HStack(spacing: CosmosSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(textSecondary)
            }

            TextField(placeholder, text: $text)
                .foregroundColor(textPrimary)
        }
        .padding()
        .background(cardBg.opacity(0.7))
        .cornerRadius(CosmosRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CosmosRadius.md)
                .stroke(strokeColor.opacity(0.1), lineWidth: 1)
        )
        .accessibilityLabel(placeholder)
    }
}

// MARK: - Section Header
struct CosmosSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionIcon: String

    init(
        _ title: String,
        subtitle: String? = nil,
        actionIcon: String = "plus.circle.fill",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionIcon = actionIcon
        self.action = action
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                }
            }

            Spacer()

            if let action = action {
                Button(action: {
                    HapticManager.shared.play(.lightTap)
                    action()
                }) {
                    Image(systemName: actionIcon)
                        .font(.title2)
                        .foregroundColor(.nebulaPurple)
                }
                .accessibilityLabel("Add \(title)")
            }
        }
    }
}

// MARK: - Streak Badge
struct CosmosStreakBadge: View {
    let streak: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(color)
            Text("\(streak)")
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.cardBackground.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(20)
        .accessibilityLabel("\(streak) day streak")
    }
}

// MARK: - At Risk Indicator
struct CosmosAtRiskBadge: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.nebulaGold)

            Text(message)
                .font(.caption)
                .foregroundColor(.nebulaGold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.nebulaGold.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityLabel("Warning: \(message)")
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 24) {
                CosmosPrimaryButton("Get Started") {
                    print("Tapped")
                }

                CosmosSecondaryButton("Learn More") {
                    print("Tapped")
                }

                CosmosCard {
                    Text("This is a card")
                        .foregroundColor(.white)
                }

                CosmosEmptyState(
                    icon: "star.fill",
                    title: "No habits yet",
                    message: "Tap + to create your first habit stack",
                    actionTitle: "Create Stack"
                ) {
                    print("Create")
                }

                HStack {
                    CosmosProgressRing(progress: 0.7)
                    CosmosStreakBadge(streak: 12, color: .nebulaMagenta)
                    CosmosAtRiskBadge(message: "Streak at risk")
                }

                CosmosTextField("Habit name", text: .constant(""), icon: "pencil")
            }
            .padding()
        }
    }
}
