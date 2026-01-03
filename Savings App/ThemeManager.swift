//
//  ThemeManager.swift
//  Cosmos Productivity Suite - Stakk
//
//  Theme management for Cosmic and Minimalist modes
//

import SwiftUI

// MARK: - Theme Mode
public enum ThemeMode: String, Codable, CaseIterable {
    case cosmic
    case minimalist

    var displayName: String {
        switch self {
        case .cosmic: return "Cosmic"
        case .minimalist: return "Minimalist"
        }
    }

    var icon: String {
        switch self {
        case .cosmic: return "sparkles"
        case .minimalist: return "circle.lefthalf.filled"
        }
    }

    var description: String {
        switch self {
        case .cosmic: return "Vibrant nebula aesthetic"
        case .minimalist: return "Clean, distraction-free"
        }
    }
}

// MARK: - Theme Manager
// Notification for theme changes
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

@Observable
public final class ThemeManager {
    public static let shared = ThemeManager()

    public var currentTheme: ThemeMode {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }

    public var isMinimalist: Bool {
        currentTheme == .minimalist
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? "cosmic"
        self.currentTheme = ThemeMode(rawValue: saved) ?? .cosmic
    }

    // MARK: - Dynamic Colors

    public var background: Color {
        isMinimalist ? .minBackground : .cosmicBlack
    }

    public var elevated: Color {
        isMinimalist ? .minElevated : .cosmicDeep
    }

    public var card: Color {
        isMinimalist ? .minCard : .cardBackground
    }

    public var subtle: Color {
        isMinimalist ? .minSubtle : .nebulaLavender.opacity(0.1)
    }

    public var primary: Color {
        isMinimalist ? .minPrimary : .nebulaPurple
    }

    public var success: Color {
        isMinimalist ? .minSuccess : .nebulaCyan
    }

    public var warning: Color {
        isMinimalist ? .minWarning : .nebulaGold
    }

    public var destructive: Color {
        isMinimalist ? .minDestructive : .nebulaMagenta
    }

    public var textPrimary: Color {
        isMinimalist ? .minTextPrimary : .white
    }

    public var textSecondary: Color {
        isMinimalist ? .minTextSecondary : .nebulaLavender.opacity(0.8)
    }

    public var textTertiary: Color {
        isMinimalist ? .minTextTertiary : .nebulaLavender.opacity(0.6)
    }

    public var textDisabled: Color {
        isMinimalist ? .minTextDisabled : .nebulaLavender.opacity(0.4)
    }

    // MARK: - Time Block Colors

    public func timeBlockColor(_ block: String) -> Color {
        switch block.lowercased() {
        case "morning":
            return isMinimalist ? .minMorning : .nebulaGold
        case "midday":
            return isMinimalist ? .minMidday : .nebulaCyan
        case "evening":
            return isMinimalist ? .minEvening : .nebulaMagenta
        case "night":
            return isMinimalist ? .minNight : .nebulaLavender
        default:
            return isMinimalist ? .minTextSecondary : .nebulaLavender
        }
    }
}

// MARK: - Environment Key
struct ThemeKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Minimalist Colors Extension
extension Color {
    // Minimalist Base Colors
    static let minBackground = Color(red: 0.05, green: 0.05, blue: 0.05) // #0D0D0D
    static let minElevated = Color(red: 0.09, green: 0.09, blue: 0.09)   // #171717
    static let minCard = Color(red: 0.13, green: 0.13, blue: 0.13)       // #212121
    static let minSubtle = Color(red: 0.16, green: 0.16, blue: 0.16)     // #2A2A2A

    // Minimalist Accents
    static let minPrimary = Color.white
    static let minSuccess = Color(red: 0.29, green: 0.87, blue: 0.50)    // #4ADE80
    static let minWarning = Color(red: 0.98, green: 0.75, blue: 0.14)    // #FBBF24
    static let minDestructive = Color(red: 0.97, green: 0.44, blue: 0.44) // #F87171

    // Minimalist Text
    static let minTextPrimary = Color(red: 0.96, green: 0.96, blue: 0.96)   // #F5F5F5
    static let minTextSecondary = Color(red: 0.64, green: 0.64, blue: 0.64) // #A3A3A3
    static let minTextTertiary = Color(red: 0.45, green: 0.45, blue: 0.45)  // #737373
    static let minTextDisabled = Color(red: 0.32, green: 0.32, blue: 0.32)  // #525252

    // Minimalist Time Blocks
    static let minMorning = Color(red: 0.83, green: 0.66, blue: 0.34)  // #D4A857
    static let minMidday = Color(red: 0.49, green: 0.83, blue: 0.91)   // #7DD3E8
    static let minEvening = Color(red: 0.85, green: 0.60, blue: 0.78)  // #D898C8
    static let minNight = Color(red: 0.65, green: 0.65, blue: 0.78)    // #A5A5C7
}

// MARK: - Theme Glow Modifier
extension View {
    func themeGlow(color: Color, radius: CGFloat = 8) -> some View {
        self.modifier(ThemeGlowModifier(color: color, radius: radius))
    }
}

struct ThemeGlowModifier: ViewModifier {
    @Environment(\.theme) var theme
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        if theme.isMinimalist {
            content
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        } else {
            content
                .shadow(color: color.opacity(0.4), radius: radius)
        }
    }
}

// MARK: - Themed Background
struct ThemedBackground: View {
    @Environment(\.theme) var theme

    var body: some View {
        if theme.isMinimalist {
            theme.background
                .ignoresSafeArea()
        } else {
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: .cosmicBlack, location: 0),
                        .init(color: .cosmicDeep, location: 0.3),
                        .init(color: .cosmicDeep, location: 0.7),
                        .init(color: .cosmicBlack, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Decorative orbs (cosmic mode only)
                DecorativeOrbs()
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Decorative Orbs
struct DecorativeOrbs: View {
    @Environment(\.theme) var theme

    var body: some View {
        if !theme.isMinimalist {
            ZStack {
                Circle()
                    .fill(Color.nebulaMagenta.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -100, y: -200)

                Circle()
                    .fill(Color.nebulaPurple.opacity(0.12))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 150, y: 100)
            }
        }
    }
}

// MARK: - Themed Card
struct ThemedCard<Content: View>: View {
    @Environment(\.theme) var theme
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.card.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                theme.isMinimalist
                                    ? Color.minSubtle.opacity(0.15)
                                    : Color.nebulaLavender.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - Theme Settings View
struct ThemeSettingsView: View {
    @Environment(\.theme) var theme
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: CosmosSpacing.sm) {
            Text("APPEARANCE")
                .font(.caption.bold())
                .foregroundColor(theme.textTertiary)
                .tracking(1)

            ForEach(ThemeMode.allCases, id: \.self) { mode in
                ThemeOptionRow(
                    mode: mode,
                    isSelected: theme.currentTheme == mode,
                    isLocked: mode == .minimalist && !subscriptionService.canAccess(.minimalistMode)
                ) {
                    if mode == .minimalist && !subscriptionService.canAccess(.minimalistMode) {
                        showPaywall = true
                    } else {
                        withAnimation(.cosmosStandard) {
                            theme.currentTheme = mode
                        }
                        HapticManager.shared.play(.selection)
                    }
                }
            }

            if !subscriptionService.isPremium {
                Text("Minimalist Mode is a premium feature")
                    .font(.caption)
                    .foregroundColor(theme.textDisabled)
                    .padding(.top, CosmosSpacing.xs)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CosmosRadius.lg)
                .fill(theme.card.opacity(0.5))
        )
        .sheet(isPresented: $showPaywall) {
            CosmosPaywallView()
        }
    }
}

struct ThemeOptionRow: View {
    @Environment(\.theme) var theme
    let mode: ThemeMode
    let isSelected: Bool
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmosSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? theme.primary.opacity(0.2) : theme.subtle)
                        .frame(width: 36, height: 36)

                    Image(systemName: mode.icon)
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? theme.primary : theme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(theme.textPrimary)

                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(theme.textTertiary)
                }

                Spacer()

                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Premium")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.nebulaGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.nebulaGold.opacity(0.15))
                    )
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.success)
                }
            }
            .padding(.vertical, CosmosSpacing.sm)
        }
    }
}

// MARK: - Theme Preview Card
struct ThemePreviewCard: View {
    let mode: ThemeMode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(mode == .minimalist ? Color.minCard : Color.cardBackground)
                .frame(height: 60)
                .overlay(
                    HStack {
                        Circle()
                            .fill(mode == .minimalist ? Color.minSuccess : Color.nebulaCyan)
                            .frame(width: 20, height: 20)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(mode == .minimalist ? Color.minTextSecondary : Color.nebulaLavender.opacity(0.5))
                            .frame(width: 60, height: 8)

                        Spacer()
                    }
                    .padding(12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.nebulaCyan : Color.clear, lineWidth: 2)
                )

            Text(mode.displayName)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .nebulaLavender.opacity(0.6))
        }
    }
}
