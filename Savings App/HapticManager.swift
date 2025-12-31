//
//  HapticManager.swift
//  Cosmos Productivity Suite - Stakk
//
//  Haptic feedback patterns following HAPTIC_PATTERNS.md
//

import SwiftUI
import UIKit
import CoreHaptics

// MARK: - Haptic Patterns
enum HapticPattern {
    case selection      // Picker changes, segment control
    case lightTap       // Button press, toggle
    case mediumTap      // Important action confirmed
    case heavyTap       // Destructive action, emphasis
    case softTap        // Subtle feedback, scroll stops
    case rigidTap       // Sharp, distinct feedback
    case doubleTap      // Special confirmation
    case success        // Action completed successfully
    case warning        // Attention needed
    case error          // Something went wrong
    case celebration    // Achievement, milestone
}

// MARK: - Haptic Manager
final class HapticManager {
    static let shared = HapticManager()

    // Pre-initialized generators for lower latency
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareAll()
    }

    /// Prepare all generators for lower latency
    private func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selection.prepare()
        notification.prepare()
    }

    /// Check if device supports haptics
    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Main Play Method
    func play(_ pattern: HapticPattern) {
        guard supportsHaptics else { return }

        switch pattern {
        case .selection:
            selection.selectionChanged()

        case .lightTap:
            impactLight.impactOccurred()

        case .mediumTap:
            impactMedium.impactOccurred()

        case .heavyTap:
            impactHeavy.impactOccurred()

        case .softTap:
            impactSoft.impactOccurred()

        case .rigidTap:
            impactRigid.impactOccurred()

        case .doubleTap:
            impactLight.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactLight.impactOccurred()
            }

        case .success:
            notification.notificationOccurred(.success)

        case .warning:
            notification.notificationOccurred(.warning)

        case .error:
            notification.notificationOccurred(.error)

        case .celebration:
            playCelebration()
        }

        // Re-prepare for next use
        prepareAll()
    }

    /// Enhanced celebration pattern: light → medium → heavy → success
    private func playCelebration() {
        impactLight.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.notification.notificationOccurred(.success)
        }
    }

    // MARK: - Convenience Methods (Backwards Compatible)

    /// Light tap - for button presses
    func lightTap() {
        play(.lightTap)
    }

    /// Medium impact - for completing a habit
    func habitComplete() {
        play(.mediumTap)
    }

    /// Heavy impact - for emphasis
    func heavyImpact() {
        play(.heavyTap)
    }

    /// Success - for completing a stack
    func stackComplete() {
        play(.success)
    }

    /// Double tap celebration
    func celebration() {
        play(.celebration)
    }

    /// Selection changed - for pickers
    func selectionChanged() {
        play(.selection)
    }
}

// MARK: - SwiftUI View Modifier
extension View {
    /// Add haptic feedback on value change
    func cosmosHaptic(_ pattern: HapticPattern, trigger: Bool) -> some View {
        self.onChange(of: trigger) { _, newValue in
            if newValue {
                HapticManager.shared.play(pattern)
            }
        }
    }

    /// Add haptic feedback on tap
    func cosmosHapticOnTap(_ pattern: HapticPattern = .lightTap) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticManager.shared.play(pattern)
            }
        )
    }
}
