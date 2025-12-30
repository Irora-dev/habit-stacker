//
//  OnboardingView.swift
//  Habit Stacking App
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage: Int = 0
    let onCreateFirstStack: () -> Void

    init(hasCompletedOnboarding: Binding<Bool>, onCreateFirstStack: @escaping () -> Void = {}) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
        self.onCreateFirstStack = onCreateFirstStack
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            switch currentPage {
            case 0:
                WelcomeScreen(onNext: { currentPage = 1 })
            case 1:
                HabitLoopScreen(onNext: { currentPage = 2 })
            case 2:
                WalkthroughScreen(onComplete: { currentPage = 3 })
            case 3:
                GuidedFirstStackScreen(onComplete: {
                    hasCompletedOnboarding = true
                    onCreateFirstStack()
                })
            default:
                WelcomeScreen(onNext: { currentPage = 1 })
            }
        }
    }
}

// MARK: - Welcome Screen
struct WelcomeScreen: View {
    let onNext: () -> Void

    @State private var showLogo: Bool = false
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    @State private var showButton: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)

            // Logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .shadow(color: .nebulaMagenta.opacity(0.4), radius: 20)
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1 : 0.8)

            Spacer()
                .frame(height: 50)

            // Main title
            Text("Take Back Control\nOver Your Day")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: .infinity)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)

            Spacer()
                .frame(height: 24)

            // Subtitle - below header
            Text("People who stack their habits are 2-3x more likely to follow through on good habits compared to those who just set goals.")
                .font(.system(size: 16))
                .foregroundColor(.nebulaLavender.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 32)
                .opacity(showSubtitle ? 1 : 0)
                .offset(y: showSubtitle ? 0 : 20)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.nebulaPurple)
                    )
                    .shadow(color: .nebulaPurple.opacity(0.4), radius: 8)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showLogo = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                showSubtitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.2)) {
                showButton = true
            }
        }
    }
}

// MARK: - Habit Loop Screen
struct HabitLoopScreen: View {
    let onNext: () -> Void

    @State private var showCue: Bool = false
    @State private var showArrow1: Bool = false
    @State private var showRoutine: Bool = false
    @State private var showArrow2: Bool = false
    @State private var showReward: Bool = false
    @State private var showExplanation: Bool = false
    @State private var showButton: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("The Habit Loop")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 32)

            // Cue → Routine → Reward flow
            VStack(spacing: 12) {
                // Cue
                HabitLoopItem(
                    icon: "bell.fill",
                    title: "Cue",
                    subtitle: "An anchor triggers your stack",
                    color: .nebulaGold,
                    isVisible: showCue
                )

                // Arrow 1
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.nebulaLavender.opacity(0.4))
                    .opacity(showArrow1 ? 1 : 0)

                // Routine
                HabitLoopItem(
                    icon: "repeat",
                    title: "Routine",
                    subtitle: "Complete habits in order",
                    color: .nebulaCyan,
                    isVisible: showRoutine
                )

                // Arrow 2
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.nebulaLavender.opacity(0.4))
                    .opacity(showArrow2 ? 1 : 0)

                // Reward
                HabitLoopItem(
                    icon: "star.fill",
                    title: "Reward",
                    subtitle: "Build streaks & feel accomplished",
                    color: .nebulaMagenta,
                    isVisible: showReward
                )
            }
            .padding(.horizontal, 24)

            Spacer()
                .frame(height: 32)

            // Explanation
            Text("Stack new habits onto existing ones to make them stick.")
                .font(.system(size: 15))
                .foregroundColor(.nebulaLavender.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(showExplanation ? 1 : 0)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.nebulaPurple)
                    )
                    .shadow(color: .nebulaPurple.opacity(0.4), radius: 8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .opacity(showButton ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showCue = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                showArrow1 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showRoutine = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
                showArrow2 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                showReward = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.4)) {
                showExplanation = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.6)) {
                showButton = true
            }
        }
    }
}

struct HabitLoopItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isVisible: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 46, height: 46)

                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 46, height: 46)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            .shadow(color: color.opacity(0.3), radius: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.nebulaLavender.opacity(0.7))
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
    }
}

// MARK: - Spotlight Frame Preference Key
struct SpotlightFramePreferenceKey: PreferenceKey {
    static var defaultValue: [HighlightArea: CGRect] = [:]

    static func reduce(value: inout [HighlightArea: CGRect], nextValue: () -> [HighlightArea: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

enum HighlightArea {
    case timeBlocks
    case addButton
    case streakButton
}

// MARK: - Walkthrough Screen (Main App Preview)
struct WalkthroughScreen: View {
    let onComplete: () -> Void

    @State private var currentStep: Int = 0
    @State private var spotlightFrames: [HighlightArea: CGRect] = [:]

    private let steps: [(title: String, description: String, highlightArea: HighlightArea)] = [
        ("Time Blocks", "Your day is organized into Morning, Midday, Evening, and Night sections. Each section holds your habit stacks.", .timeBlocks),
        ("Add Habits", "Tap the + button to create a new habit stack for any time of day.", .addButton),
        ("Track Streaks", "Tap your streak to view your progress calendar and see your habit history.", .streakButton)
    ]

    var body: some View {
        ZStack {
            // Mock main app view (simplified)
            MockMainAppView()
                .onPreferenceChange(SpotlightFramePreferenceKey.self) { frames in
                    spotlightFrames = frames
                }

            // Overlay with spotlight cutout
            if let frame = spotlightFrames[steps[currentStep].highlightArea] {
                SpotlightOverlay(frame: frame, cornerRadius: cornerRadiusFor(steps[currentStep].highlightArea))
            }

            // Instruction card
            VStack {
                Spacer()

                VStack(spacing: 16) {
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? Color.nebulaCyan : Color.nebulaLavender.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text(steps[currentStep].title)
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text(steps[currentStep].description)
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentStep < steps.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.nebulaPurple)
                            )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.nebulaLavender.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .coordinateSpace(name: "walkthrough")
    }

    func cornerRadiusFor(_ area: HighlightArea) -> CGFloat {
        switch area {
        case .timeBlocks: return 16
        case .addButton: return 20
        case .streakButton: return 20
        }
    }
}

// MARK: - Spotlight Overlay
struct SpotlightOverlay: View {
    let frame: CGRect
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            // Dark overlay with cutout using mask
            Color.black.opacity(0.8)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .frame(width: frame.width + 8, height: frame.height + 8)
                                .position(x: frame.midX, y: frame.midY)
                                .blendMode(.destinationOut)
                        )
                )
                .compositingGroup()

            // Highlight border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.nebulaCyan, lineWidth: 3)
                .frame(width: frame.width + 8, height: frame.height + 8)
                .shadow(color: .nebulaCyan.opacity(0.6), radius: 10)
                .shadow(color: .nebulaCyan.opacity(0.3), radius: 20)
                .position(x: frame.midX, y: frame.midY)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Spotlight Frame Reporter
struct SpotlightFrameReporter: View {
    let area: HighlightArea

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: SpotlightFramePreferenceKey.self,
                    value: [area: geo.frame(in: .named("walkthrough"))]
                )
        }
    }
}

// MARK: - Mock Main App View
struct MockMainAppView: View {
    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    // Mock Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.nebulaLavender.opacity(0.7))
                        }
                        Spacer()

                        // Streak indicator - with frame reporter
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.nebulaMagenta)
                            Text("0")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.cardBackground.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.nebulaMagenta.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)
                        .background(SpotlightFrameReporter(area: .streakButton))
                    }

                    // Mock arc
                    ZStack {
                        SunArcShape()
                            .stroke(
                                LinearGradient(
                                    colors: [.nebulaGold, .nebulaMagenta, .nebulaPurple, .nebulaCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(height: 120)

                        VStack(spacing: 4) {
                            Text("0")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.nebulaLavender.opacity(0.6))
                            Text("habits completed")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.5))
                        }
                        .offset(y: 20)
                    }
                    .frame(height: 160)

                    // Mock Time Block - with frame reporter
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.nebulaGold)
                                .font(.title2)

                            Text("Morning")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            // Add button - with frame reporter
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nebulaGold)
                                .font(.title2)
                                .background(SpotlightFrameReporter(area: .addButton))
                        }

                        Text("No stacks yet — tap + to create one")
                            .font(.subheadline)
                            .foregroundColor(.nebulaLavender.opacity(0.5))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.nebulaGold.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .background(SpotlightFrameReporter(area: .timeBlocks))
                }
                .padding()
            }
        }
    }
}

// MARK: - Guided First Stack Screen
struct GuidedFirstStackScreen: View {
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var pulseAnimation: Bool = false

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                // Title section
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.nebulaGold, .nebulaMagenta],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .nebulaGold.opacity(0.5), radius: 10)

                    Text("Let's Create Your First Stack")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("We'll help you build the perfect morning routine based on habits that successful people swear by.")
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()
                    .frame(height: 60)

                // Mock Morning section with highlighted + button
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .foregroundColor(.nebulaGold)
                            .font(.title2)
                            .shadow(color: .nebulaGold.opacity(0.5), radius: 4)

                        Text("Morning")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        // Highlighted + button
                        Button(action: onComplete) {
                            ZStack {
                                // Pulse ring
                                Circle()
                                    .stroke(Color.nebulaGold, lineWidth: 2)
                                    .frame(width: 44, height: 44)
                                    .scaleEffect(pulseAnimation ? 1.4 : 1.0)
                                    .opacity(pulseAnimation ? 0 : 0.8)

                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.nebulaGold)
                                    .font(.system(size: 32))
                                    .shadow(color: .nebulaGold.opacity(0.6), radius: 8)
                            }
                        }
                    }

                    Text("Tap + to create your Wake Up Routine")
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 2)
                        )
                )
                .shadow(color: .nebulaGold.opacity(0.2), radius: 12)
                .padding(.horizontal)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }

            // Start pulse animation
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
