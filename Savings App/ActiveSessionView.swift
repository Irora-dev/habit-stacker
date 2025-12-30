//
//  ActiveSessionView.swift
//  Habit Stacking App
//

import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    let stack: HabitStack
    let onComplete: ([Habit], SessionLog?) -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var habits: [Habit]
    @State private var currentIndex: Int = 0
    @State private var totalElapsedSeconds: Int = 0
    @State private var habitElapsedSeconds: Int = 0
    @State private var timer: Timer? = nil
    @State private var isAnimating: Bool = false
    @State private var showCompletion: Bool = false
    @State private var completionScale: CGFloat = 0.5
    @State private var completionOpacity: Double = 0
    @State private var topCardOffset: CGFloat = 0
    @State private var topCardOpacity: Double = 1
    @State private var stackAnimationComplete: Bool = false
    @State private var cardOffsets: [CGFloat] = []
    @State private var showSparks: Bool = false
    @State private var cardShake: CGFloat = 0
    @State private var completionComment: String = ""
    @State private var habitDurations: [Int] = []
    @State private var skippedHabits: Set<Int> = []
    @Environment(\.dismiss) private var dismiss

    init(stack: HabitStack, onComplete: @escaping ([Habit], SessionLog?) -> Void) {
        self.stack = stack
        self.onComplete = onComplete
        self._habits = State(initialValue: stack.sortedHabits)
    }

    var currentHabit: Habit? {
        guard currentIndex < habits.count else { return nil }
        return habits[currentIndex]
    }

    var completedCount: Int {
        habits.count - skippedHabits.count
    }

    var body: some View {
        ZStack {
            // Cosmic background
            CosmicSessionBackground(color: stack.color)

            if showCompletion {
                completionView
            } else {
                sessionContent
            }

            // Gold sparks overlay
            if showSparks {
                GoldSparksView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            // Initialize habit durations array
            habitDurations = Array(repeating: 0, count: habits.count)
            startTimer()
            // Initialize card offsets for animation
            cardOffsets = Array(repeating: 600, count: habits.count)
            // Animate cards stacking in
            animateStackIn()
        }
        .onDisappear { stopTimer() }
    }

    // MARK: - Session Content
    var sessionContent: some View {
        VStack(spacing: 24) {
            // Header with close button
            HStack {
                Button(action: {
                    HapticManager.shared.lightTap()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                }

                Spacer()

                Text(stack.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                // Invisible spacer for balance
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal)

            // Progress indicator
            HStack(spacing: 4) {
                Text("\(currentIndex + 1)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("of \(habits.count)")
                    .font(.system(size: 18))
                    .foregroundColor(.nebulaLavender.opacity(0.6))
            }

            Spacer()

            // Habit Stack
            habitStackView
                .frame(height: 340)

            Spacer()

            // Timer section with skip button
            timerSection

            // Hint text
            Text("Tap card to complete • Skip to move on")
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.4))
                .padding(.bottom, 40)
        }
        .padding()
    }

    // MARK: - Habit Stack View
    var habitStackView: some View {
        ZStack {
            // Show remaining habits as stacked cards behind
            ForEach(Array(habits.enumerated().reversed()), id: \.element.id) { index, habit in
                if index >= currentIndex {
                    let stackPosition = index - currentIndex

                    // More dramatic rotation for messy pile effect
                    let rotation: Double = {
                        if stackPosition == 0 { return 0 }
                        // Use habit id to create consistent "random" rotation
                        let seed = habit.name.hashValue
                        let baseRotation = 3.0 + Double(stackPosition) * 1.5
                        return seed % 2 == 0 ? baseRotation : -baseRotation
                    }()

                    // Slight horizontal offset for pile effect
                    let xOffset: CGFloat = {
                        if stackPosition == 0 { return 0 }
                        let seed = habit.name.hashValue
                        let baseOffset: CGFloat = CGFloat(stackPosition) * 3
                        return seed % 2 == 0 ? baseOffset : -baseOffset
                    }()

                    // Animation offset (cards fly in from bottom)
                    let animationOffset: CGFloat = {
                        if index < cardOffsets.count {
                            return cardOffsets[index]
                        }
                        return 0
                    }()

                    HabitCard(
                        habit: habit,
                        color: stack.color,
                        isTop: stackPosition == 0 && stackAnimationComplete
                    )
                    .rotationEffect(.degrees(rotation))
                    .offset(
                        x: xOffset + (stackPosition == 0 ? cardShake : 0),
                        y: (stackPosition == 0 ? topCardOffset : CGFloat(stackPosition) * 6) + animationOffset
                    )
                    .scaleEffect(stackPosition == 0 ? 1.0 : 1.0 - CGFloat(stackPosition) * 0.02)
                    .opacity(stackPosition == 0 ? topCardOpacity : max(0.4, 1.0 - Double(stackPosition) * 0.1))
                    .zIndex(Double(habits.count - index))
                    .onTapGesture {
                        if stackPosition == 0 && !isAnimating && stackAnimationComplete {
                            completeCurrentHabit()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stack Animation
    func animateStackIn() {
        // Animate cards one by one from bottom of stack to top
        for i in (0..<habits.count).reversed() {
            let delay = Double(habits.count - 1 - i) * 0.08
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                if i < cardOffsets.count {
                    cardOffsets[i] = 0
                }
            }
        }

        // Mark animation complete after all cards have landed
        let totalDelay = Double(habits.count) * 0.08 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            stackAnimationComplete = true
        }
    }

    // MARK: - Timer Section
    var timerSection: some View {
        VStack(spacing: 12) {
            // Current habit timer (primary)
            HStack(spacing: 16) {
                // Skip button
                Button(action: skipCurrentHabit) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.cardBackground.opacity(0.7))
                        )
                }

                // Habit timer
                HStack(spacing: 8) {
                    Image(systemName: "stopwatch.fill")
                        .foregroundColor(stack.color)

                    Text(formatTime(habitElapsedSeconds))
                        .font(.system(size: 28, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.cardBackground.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(stack.color.opacity(0.3), lineWidth: 1)
                        )
                )

                // Placeholder for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }

            // Total time (secondary)
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.5))
                Text("Total: \(formatTime(totalElapsedSeconds))")
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.5))
            }
        }
    }

    // MARK: - Completion View
    var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 40)

                // Celebration icon
                ZStack {
                    // Animated rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(stack.color.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                            .frame(width: CGFloat(120 + i * 30), height: CGFloat(120 + i * 30))
                            .scaleEffect(completionScale)
                            .opacity(completionOpacity)
                    }

                    // Outer glow
                    Circle()
                        .fill(stack.color.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .scaleEffect(completionScale)

                    // Main circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [stack.color, stack.color.opacity(0.8)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: stack.color.opacity(0.6), radius: 20)
                        .scaleEffect(completionScale)

                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(completionScale)
                }

                Text("Stack Complete!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .opacity(completionOpacity)

                Text("You finished \(completedCount) habit\(completedCount == 1 ? "" : "s") in \(formatTime(totalElapsedSeconds))")
                    .font(.subheadline)
                    .foregroundColor(.nebulaLavender.opacity(0.7))
                    .opacity(completionOpacity)

                // Stats row
                HStack(spacing: 32) {
                    StatBadge(icon: "flame.fill", value: "\(stack.streak + 1)", label: "Streak", color: .nebulaMagenta)
                    StatBadge(icon: "clock.fill", value: formatTime(totalElapsedSeconds), label: "Time", color: .nebulaCyan)
                    StatBadge(icon: "checkmark.circle.fill", value: "\(completedCount)", label: "Done", color: .nebulaGold)
                    if !skippedHabits.isEmpty {
                        StatBadge(icon: "forward.fill", value: "\(skippedHabits.count)", label: "Skipped", color: .nebulaLavender)
                    }
                }
                .opacity(completionOpacity)

                // Comment field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a note (optional)")
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.6))

                    TextField("How did it go?", text: $completionComment, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.cardBackground.opacity(0.7))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .lineLimit(3...6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
                .opacity(completionOpacity)

                Spacer()
                    .frame(height: 20)

                Button(action: saveAndDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(stack.color)
                        )
                        .shadow(color: stack.color.opacity(0.4), radius: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(completionOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                completionScale = 1.0
                completionOpacity = 1.0
            }
        }
    }

    // MARK: - Actions
    func completeCurrentHabit() {
        guard currentIndex < habits.count, !isAnimating else { return }

        isAnimating = true

        // Record duration for this habit
        if currentIndex < habitDurations.count {
            habitDurations[currentIndex] = habitElapsedSeconds
        }

        // Haptic feedback
        HapticManager.shared.habitComplete()

        // Show gold sparks
        showSparks = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showSparks = false
        }

        // Quick shake animation
        withAnimation(.easeInOut(duration: 0.05)) {
            cardShake = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: 0.05)) {
                cardShake = -8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.05)) {
                cardShake = 5
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.05)) {
                cardShake = 0
            }
        }

        // Animate top card flying up and fading out (after shake)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.3)) {
                topCardOffset = -400
                topCardOpacity = 0
            }
        }

        // Update habit and move to next
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            habits[currentIndex].isCompleted = true
            habits[currentIndex].completedAt = Date()

            moveToNextHabit()
        }
    }

    func skipCurrentHabit() {
        guard currentIndex < habits.count, !isAnimating else { return }

        isAnimating = true

        // Record this habit as skipped
        skippedHabits.insert(currentIndex)

        // Record duration even for skipped habits
        if currentIndex < habitDurations.count {
            habitDurations[currentIndex] = habitElapsedSeconds
        }

        // Light haptic
        HapticManager.shared.lightTap()

        // Animate card sliding off to the side
        withAnimation(.easeIn(duration: 0.3)) {
            topCardOffset = -300
            topCardOpacity = 0
        }

        // Move to next
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            moveToNextHabit()
        }
    }

    func moveToNextHabit() {
        if currentIndex < habits.count - 1 {
            currentIndex += 1
            // Reset card position and habit timer for next card
            topCardOffset = 0
            topCardOpacity = 1
            habitElapsedSeconds = 0
            isAnimating = false
        } else {
            // All done - celebration!
            stopTimer()
            HapticManager.shared.celebration()
            withAnimation {
                showCompletion = true
            }
        }
    }

    func saveAndDismiss() {
        HapticManager.shared.lightTap()

        // Create habit logs
        var habitLogs: [HabitLog] = []
        for (index, habit) in habits.enumerated() {
            let duration = index < habitDurations.count ? habitDurations[index] : 0
            let wasSkipped = skippedHabits.contains(index)
            let log = HabitLog(
                habitName: habit.name,
                habitIcon: habit.icon,
                duration: duration,
                wasSkipped: wasSkipped,
                order: index
            )
            habitLogs.append(log)
        }

        // Create session log
        let sessionLog = SessionLog(
            stackId: stack.id,
            stackName: stack.name,
            totalDuration: totalElapsedSeconds,
            comment: completionComment,
            habitsCompleted: completedCount,
            habitsSkipped: skippedHabits.count,
            habitLogs: habitLogs
        )

        // Save to model context
        modelContext.insert(sessionLog)

        onComplete(habits, sessionLog)
        dismiss()
    }

    // MARK: - Timer Functions
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalElapsedSeconds += 1
            habitElapsedSeconds += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.nebulaLavender.opacity(0.6))
        }
    }
}

// MARK: - Habit Card
struct HabitCard: View {
    let habit: Habit
    let color: Color
    let isTop: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(color.opacity(isTop ? 0.25 : 0.15))
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)

                // Main circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color, color.opacity(0.7)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: color.opacity(0.6), radius: 15)

                // Icon
                Image(systemName: habit.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }

            // Habit name
            Text(habit.name)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .padding(.horizontal, 24)
        .background(
            ZStack {
                // Drop shadow (darker, offset down)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.5))
                    .offset(y: 8)
                    .blur(radius: 12)

                // Card background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cardBackground.opacity(1.0),
                                Color.cardBackground.opacity(0.9),
                                Color.cosmicDeep
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Inner highlight at top
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isTop ? 0.08 : 0.04),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                // Border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(isTop ? 0.5 : 0.25),
                                color.opacity(isTop ? 0.2 : 0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isTop ? 2 : 1
                    )
            }
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Cosmic Session Background
struct CosmicSessionBackground: View {
    let color: Color

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.cosmicBlack,
                    Color.cosmicDeep,
                    Color.cosmicBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Central glow matching stack color
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -50)

            // Accent glow
            Circle()
                .fill(Color.nebulaPurple.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: 300)
        }
    }
}

// MARK: - Gold Sparks View
struct GoldSparksView: View {
    @State private var sparks: [Spark] = []

    struct Spark: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Double
        var velocityX: CGFloat
        var velocityY: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparks) { spark in
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundColor(.nebulaGold)
                        .scaleEffect(spark.scale)
                        .opacity(spark.opacity)
                        .rotationEffect(.degrees(spark.rotation))
                        .position(x: spark.x, y: spark.y)
                        .shadow(color: .nebulaGold.opacity(0.8), radius: 4)
                }
            }
            .onAppear {
                createSparks(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    func createSparks(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2 - 50

        // Create initial sparks
        for _ in 0..<20 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 150...300)
            let spark = Spark(
                x: centerX,
                y: centerY,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1.0,
                rotation: Double.random(in: 0...360),
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed
            )
            sparks.append(spark)
        }

        // Animate sparks outward
        withAnimation(.easeOut(duration: 0.5)) {
            for i in sparks.indices {
                sparks[i].x += sparks[i].velocityX * 0.4
                sparks[i].y += sparks[i].velocityY * 0.4
                sparks[i].opacity = 0
                sparks[i].scale *= 0.3
                sparks[i].rotation += Double.random(in: 90...180)
            }
        }
    }
}
