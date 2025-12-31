//
//  CosmosDesignSystem.swift
//  Cosmos Productivity Suite - Stakk
//
//  Design tokens, animation specs, and system constants
//

import SwiftUI

// MARK: - Animation Durations
enum CosmosDuration {
    static let instant: Double = 0.1      // Micro-feedback
    static let fast: Double = 0.15        // Quick transitions
    static let normal: Double = 0.25      // Standard transitions
    static let slow: Double = 0.35        // Modal presentations
    static let deliberate: Double = 0.5   // Celebrations, emphasis
    static let dramatic: Double = 0.8     // Major achievements
}

// MARK: - Animation Extensions
extension Animation {
    /// Quick response, smooth finish
    static let cosmosEaseOut = Animation.easeOut(duration: CosmosDuration.fast)

    /// Natural motion for most transitions
    static let cosmosStandard = Animation.easeInOut(duration: CosmosDuration.normal)

    /// Bouncy, playful for celebrations
    static let cosmosBouncy = Animation.spring(
        response: 0.35,
        dampingFraction: 0.6,
        blendDuration: 0
    )

    /// Smooth, elegant for modals
    static let cosmosSmooth = Animation.spring(
        response: 0.4,
        dampingFraction: 0.85,
        blendDuration: 0
    )

    /// Subtle pulse for attention
    static let cosmosPulse = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)

    /// Stagger for lists
    static func cosmosStagger(index: Int) -> Animation {
        Animation.cosmosStandard.delay(Double(index) * 0.05)
    }
}

// MARK: - Spacing System
enum CosmosSpacing {
    static let xs: CGFloat = 4    // Icon gaps, tight spacing
    static let sm: CGFloat = 8    // Internal element spacing
    static let md: CGFloat = 12   // Card internal padding
    static let lg: CGFloat = 16   // Section spacing
    static let xl: CGFloat = 24   // Major section gaps
    static let xxl: CGFloat = 32  // Screen edge padding
    static let xxxl: CGFloat = 40 // Hero spacing
}

// MARK: - Corner Radius
enum CosmosRadius {
    static let sm: CGFloat = 8    // Buttons, small elements
    static let md: CGFloat = 12   // Input fields, tags
    static let lg: CGFloat = 16   // Cards, containers
    static let xl: CGFloat = 20   // Large cards, sheets
}

// MARK: - Elevation/Shadows
enum CosmosElevation {
    static func subtle(color: Color = .black) -> some View {
        EmptyView()
    }

    static func glow(color: Color, radius: CGFloat = 8) -> some ViewModifier {
        CosmosGlowModifier(color: color, radius: radius)
    }
}

struct CosmosGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4), radius: radius)
    }
}

// MARK: - View Modifier Extensions
extension View {
    /// Apply cosmic glow effect
    func cosmosGlow(color: Color, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.4), radius: radius)
    }

    /// Standard card styling
    func cosmosCardStyle(opacity: CGFloat = 0.7) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: CosmosRadius.lg)
                    .fill(Color.cardBackground.opacity(opacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmosRadius.lg)
                            .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                    )
            )
    }

    /// Animation with accessibility support
    func cosmosAnimation<V: Equatable>(
        _ animation: Animation = .cosmosStandard,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        self.animation(
            reduceMotion ? .linear(duration: 0.01) : animation,
            value: value
        )
    }
}

// MARK: - Streak Milestone Messages
struct StreakMessages {
    static func message(for streak: Int) -> String? {
        switch streak {
        case 3:
            return "3 days—you're off to a good start"
        case 7:
            return "One week! The first week is the hardest"
        case 14:
            return "Two weeks of consistency"
        case 21:
            return "21 days—they say it takes this long to form a habit"
        case 30:
            return "A full month! That's real commitment"
        case 60:
            return "60 days. This is who you are now"
        case 90:
            return "90 days. Most people never get here"
        case 180:
            return "Half a year. Incredible"
        case 365:
            return "One year. You've changed"
        default:
            return nil
        }
    }

    static func recoveryMessage(previousStreak: Int) -> String {
        let messages = [
            "Streak ended at \(previousStreak) days. You can start fresh today.",
            "Yesterday's gone. Today's here. Let's go.",
            "One missed day doesn't erase the \(previousStreak) you completed.",
            "You've proven you can do this—now do it again."
        ]
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - Feature Limits (Free Tier)
struct FeatureLimits {
    static let freeHabitStacks = 2
    static let freeHabitsPerStack = 4
    static let freeCalendarWeeks = 4
    static let maxFreeHabitsTotal = 8
}

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable {
    case free
    case premium

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
}

// MARK: - Premium Features
enum PremiumFeature: String, CaseIterable {
    case unlimitedStacks
    case unlimitedHabits
    case yearCalendar
    case habitInsights
    case customIcons
    case streakRecovery
    case advancedStats
    case cloudSync

    var displayName: String {
        switch self {
        case .unlimitedStacks: return "Unlimited Stacks"
        case .unlimitedHabits: return "Unlimited Habits"
        case .yearCalendar: return "52-Week Calendar"
        case .habitInsights: return "Habit Insights"
        case .customIcons: return "Custom Icons"
        case .streakRecovery: return "Streak Recovery"
        case .advancedStats: return "Advanced Statistics"
        case .cloudSync: return "Cloud Sync"
        }
    }

    var description: String {
        switch self {
        case .unlimitedStacks: return "Create as many habit stacks as you need"
        case .unlimitedHabits: return "Add unlimited habits to each stack"
        case .yearCalendar: return "View your entire year's progress at a glance"
        case .habitInsights: return "Get personalized suggestions and patterns"
        case .customIcons: return "Choose from hundreds of custom icons"
        case .streakRecovery: return "Recover broken streaks once per month"
        case .advancedStats: return "Deep analytics on your habit performance"
        case .cloudSync: return "Sync across all your devices"
        }
    }
}
