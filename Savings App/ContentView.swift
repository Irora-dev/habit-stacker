//
//  ContentView.swift
//  Habit Stacking App
//

import SwiftUI
import SwiftData

// MARK: - Cosmic Nebula Color Theme
extension Color {
    // Base colors
    static let cosmicBlack = Color(red: 0.04, green: 0.04, blue: 0.08)
    static let cosmicDeep = Color(red: 0.08, green: 0.06, blue: 0.14)
    static let cardBackground = Color(red: 0.12, green: 0.10, blue: 0.20)
    
    // Accent colors
    static let nebulaCyan = Color(red: 0.25, green: 0.85, blue: 0.95)
    static let nebulaMagenta = Color(red: 0.95, green: 0.35, blue: 0.75)
    static let nebulaLavender = Color(red: 0.70, green: 0.55, blue: 0.95)
    static let nebulaPurple = Color(red: 0.55, green: 0.30, blue: 0.85)
    static let nebulaGold = Color(red: 1.0, green: 0.80, blue: 0.40)
    
    // Gradients
    static let nebulaGradient = LinearGradient(
        colors: [nebulaMagenta, nebulaPurple, nebulaCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Time Block Enum
enum TimeBlock: String, CaseIterable {
    case morning = "Morning"
    case midday = "Midday"
    case evening = "Evening"
    case night = "Night"
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return .nebulaGold
        case .midday: return .nebulaCyan
        case .evening: return .nebulaMagenta
        case .night: return .nebulaLavender
        }
    }
}

// MARK: - Main View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitStack.createdAt) private var habitStacks: [HabitStack]
    @State private var activeStack: HabitStack? = nil
    @State private var creatingStackFor: TimeBlock? = nil
    @State private var animationTrigger: UUID = UUID()
    @State private var showStats: Bool = false
    @State private var showInspiration: Bool = false
    @State private var selectedAnchorTemplate: AnchorTemplate? = nil
    @State private var selectedSuggestedStack: SuggestedStack? = nil

    var totalCompletedToday: Int {
        habitStacks.flatMap { $0.habits }.filter { $0.isCompleted }.count
    }

    // Check if a time block section is complete (all stacks scheduled for today fully completed)
    func isSectionComplete(_ block: TimeBlock) -> Bool {
        let stacksInBlock = habitStacks.filter { $0.timeBlock == block && $0.shouldShowToday }

        // If no stacks scheduled for today, section is not "complete" (nothing to complete)
        guard !stacksInBlock.isEmpty else { return false }

        // Check if all stacks in this block have all habits completed today
        return stacksInBlock.allSatisfy { stack in
            guard !stack.habits.isEmpty else { return false }
            return stack.habits.allSatisfy { habit in
                guard habit.isCompleted, let completedAt = habit.completedAt else { return false }
                return Calendar.current.isDateInToday(completedAt)
            }
        }
    }

    // Sort time blocks: incomplete first (in natural order), then complete ones at bottom
    var sortedTimeBlocks: [TimeBlock] {
        let allBlocks = TimeBlock.allCases
        let incomplete = allBlocks.filter { !isSectionComplete($0) }
        let complete = allBlocks.filter { isSectionComplete($0) }
        return incomplete + complete
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let allHabits = habitStacks.flatMap { $0.habits }
        var streak = 0
        var checkDate = Date()

        func completionsForDate(_ date: Date) -> Int {
            allHabits.filter { habit in
                guard let completedAt = habit.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: date)
            }.count
        }

        // Check if there are completions today, if not start from yesterday
        if completionsForDate(checkDate) == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        // Count consecutive days with completions
        while completionsForDate(checkDate) > 0 {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    var body: some View {
        ZStack {
            // Cosmic background
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderView(
                        currentStreak: currentStreak,
                        onStreakTap: { showStats = true },
                        onInspirationTap: { showInspiration = true }
                    )

                    // Stats & Sun Arc
                    TodayStatsView(completedCount: totalCompletedToday, animationTrigger: animationTrigger)

                    // Suggested Stacks Section
                    SuggestedStacksSection(onStackTap: { stack in
                        selectedSuggestedStack = stack
                    })

                    // Time Blocks - completed sections move to bottom
                    ForEach(sortedTimeBlocks, id: \.self) { block in
                        TimeBlockCard(
                            timeBlock: block,
                            stacks: habitStacks.filter { $0.timeBlock == block && $0.shouldShowToday },
                            isComplete: isSectionComplete(block),
                            onStackTap: { stack in
                                activeStack = stack
                            },
                            onAddTap: {
                                creatingStackFor = block
                            }
                        )
                    }
                    .animation(.easeInOut(duration: 0.3), value: sortedTimeBlocks)
                }
                .padding()
            }
        }
        .fullScreenCover(item: $activeStack) { stack in
            ActiveSessionView(stack: stack) { completedHabits, sessionLog in
                // Update habits - SwiftData auto-saves
                for habit in completedHabits {
                    if let existingHabit = stack.habits.first(where: { $0.id == habit.id }) {
                        existingHabit.isCompleted = habit.isCompleted
                        existingHabit.completedAt = habit.completedAt
                    }
                }
                stack.streak += 1
            }
        }
        .sheet(item: $creatingStackFor) { timeBlock in
            CreateStackView(timeBlock: timeBlock) { newStack in
                modelContext.insert(newStack)
            }
        }
        .sheet(isPresented: $showInspiration) {
            AnchorInspirationView { anchor in
                selectedAnchorTemplate = anchor
            }
        }
        .sheet(item: $selectedAnchorTemplate) { anchor in
            CreateStackView(
                timeBlock: anchor.timeBlock,
                prefilledAnchor: anchor.name
            ) { newStack in
                modelContext.insert(newStack)
            }
        }
        .fullScreenCover(isPresented: $showStats) {
            StatsView(habitStacks: habitStacks)
        }
        .sheet(item: $selectedSuggestedStack) { suggestedStack in
            SuggestedStackDetailSheet(
                suggestedStack: suggestedStack,
                onAddToStacks: { stack in
                    modelContext.insert(stack)
                    selectedSuggestedStack = nil
                },
                onStartNow: { stack in
                    modelContext.insert(stack)
                    selectedSuggestedStack = nil
                    // Small delay to let the sheet dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        activeStack = stack
                    }
                }
            )
        }
        .onChange(of: activeStack) { oldValue, newValue in
            // When returning from a session (activeStack becomes nil)
            if oldValue != nil && newValue == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    animationTrigger = UUID()
                }
            }
        }
        .onAppear {
            // Schedule notifications on app launch
            NotificationManager.shared.scheduleNotifications(for: habitStacks)
        }
        .onChange(of: habitStacks.count) { _, _ in
            // Reschedule notifications when stacks are added/removed
            NotificationManager.shared.scheduleNotifications(for: habitStacks)
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackgroundView: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.cosmicBlack,
                    Color.cosmicDeep,
                    Color(red: 0.10, green: 0.05, blue: 0.18),
                    Color.cosmicBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Nebula glow - top right
            Circle()
                .fill(Color.nebulaMagenta.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 150, y: -200)
            
            // Nebula glow - bottom left
            Circle()
                .fill(Color.nebulaPurple.opacity(0.12))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: -150, y: 400)
            
            // Subtle cyan accent
            Circle()
                .fill(Color.nebulaCyan.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 100, y: 200)
        }
    }
}

// MARK: - Make TimeBlock Identifiable for sheet
extension TimeBlock: Identifiable {
    var id: String { self.rawValue }
}

// MARK: - Header
struct HeaderView: View {
    let currentStreak: Int
    let onStreakTap: () -> Void
    let onInspirationTap: () -> Void

    var body: some View {
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

            // Inspiration button
            Button(action: onInspirationTap) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.nebulaGold)
                    .padding(10)
                    .background(Color.cardBackground.opacity(0.8))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                    )
            }

            // Streak indicator (tappable)
            Button(action: onStreakTap) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.nebulaMagenta)
                    Text("\(currentStreak)")
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
            }

            // Profile menu
            ProfileMenuView()
        }
    }
}

// MARK: - Profile Menu
struct ProfileMenuView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showSignOutAlert: Bool = false

    var body: some View {
        Menu {
            if let email = authManager.user?.email {
                Label(email, systemImage: "envelope.fill")
            }

            Divider()

            Button(role: .destructive, action: { showSignOutAlert = true }) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.nebulaLavender)
                .padding(.leading, 8)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                try? authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Today Stats View
struct TodayStatsView: View {
    let completedCount: Int
    let animationTrigger: UUID
    @State private var displayedCount: Int = 0
    @State private var previousCount: Int = 0

    var accentColor: Color {
        switch displayedCount {
        case 0:
            return .nebulaLavender.opacity(0.6)
        case 1...4:
            return .nebulaCyan
        case 5...9:
            return .nebulaMagenta
        case 10...14:
            return .nebulaGold
        default:
            return .white
        }
    }

    var body: some View {
        ZStack {
            // Cosmic Arc
            CosmicArcView()

            // Stats overlay - centered in arc
            VStack(spacing: 4) {
                Text("\(displayedCount)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: accentColor.opacity(0.5), radius: 10)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.12), value: displayedCount)

                Text("habits completed")
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.6))
            }
            .offset(y: 20)
        }
        .frame(height: 160)
        .padding(.vertical, 8)
        .onAppear {
            displayedCount = completedCount
            previousCount = completedCount
        }
        .onChange(of: animationTrigger) { _, _ in
            // Triggered when returning from habit session
            let oldValue = previousCount
            let newValue = completedCount
            previousCount = completedCount

            if oldValue != newValue {
                animateCount(from: oldValue, to: newValue)
            }
        }
    }

    private func animateCount(from oldValue: Int, to newValue: Int) {
        let difference = newValue - oldValue
        guard difference != 0 else { return }

        let steps = abs(difference)
        let stepDuration: Double = 0.12

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                if difference > 0 {
                    displayedCount = oldValue + i + 1
                } else {
                    displayedCount = oldValue - i - 1
                }
            }
        }
    }
}

// MARK: - Cosmic Arc
struct CosmicArcView: View {
    // Time-based position calculation
    // 6am = start of arc (left), 11:59pm = end of arc (right)
    private var timeProgress: Double {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        // Convert to decimal hours
        let currentTime = Double(hour) + Double(minute) / 60.0

        // Map 6am (6.0) to midnight (24.0) onto 0...1
        // Before 6am, show at start; after midnight would wrap
        if currentTime < 6.0 {
            // Before 6am - show near the end (night time)
            return 0.95
        }

        // 6am = 0, midnight (24) = 1
        let progress = (currentTime - 6.0) / 18.0
        return min(max(progress, 0), 1)
    }

    // Is it night time? (after 7pm / 19:00)
    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19 || hour < 6
    }

    // Calculate position on arc
    private func dotOffset(in width: CGFloat) -> CGPoint {
        let radius = width * 0.45
        // Arc goes from 180° (left) to 0° (right)
        // Progress 0 = 180°, Progress 1 = 0°
        let angle = Double.pi * (1 - timeProgress) // 180° to 0° in radians

        let x = cos(angle) * radius
        let y = -sin(angle) * radius // Negative because Y is flipped in SwiftUI

        return CGPoint(x: x, y: y)
    }

    private var dotColor: Color {
        isNightTime ? .nebulaLavender : .nebulaGold
    }

    private var dotGlowColor: Color {
        isNightTime ? .nebulaPurple : .nebulaGold
    }

    var body: some View {
        GeometryReader { geo in
            let offset = dotOffset(in: geo.size.width)

            ZStack {
                // Glow behind arc
                SunArcShape()
                    .stroke(Color.nebulaMagenta.opacity(0.3), lineWidth: 12)
                    .blur(radius: 8)

                // Main arc
                SunArcShape()
                    .stroke(
                        LinearGradient(
                            colors: [.nebulaGold, .nebulaMagenta, .nebulaPurple, .nebulaCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )

                // Sun/Moon indicator - positioned based on time
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, dotColor],
                            center: .center,
                            startRadius: 0,
                            endRadius: 10
                        )
                    )
                    .frame(width: 16, height: 16)
                    .shadow(color: dotGlowColor.opacity(0.8), radius: 8)
                    .shadow(color: dotGlowColor.opacity(0.4), radius: 16)
                    .offset(x: offset.x, y: geo.size.height + offset.y)
            }
        }
        .frame(height: 120)
    }
}

struct SunArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width * 0.45,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

// MARK: - Time Block Card
struct TimeBlockCard: View {
    let timeBlock: TimeBlock
    let stacks: [HabitStack]
    var isComplete: Bool = false
    let onStackTap: (HabitStack) -> Void
    let onAddTap: () -> Void

    @State private var isExpanded: Bool = true
    @State private var hasAutoCollapsed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Time block header (tappable when complete)
            HStack {
                // Tappable header area for completed sections
                Button(action: {
                    if isComplete {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isExpanded.toggle()
                        }
                        HapticManager.shared.lightTap()
                    }
                }) {
                    HStack {
                        Image(systemName: timeBlock.icon)
                            .foregroundColor(isComplete ? timeBlock.color.opacity(0.5) : timeBlock.color)
                            .font(.title2)
                            .shadow(color: isComplete ? .clear : timeBlock.color.opacity(0.5), radius: 4)

                        Text(timeBlock.rawValue)
                            .font(.headline)
                            .foregroundColor(isComplete ? .nebulaLavender.opacity(0.5) : .white)

                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.nebulaCyan.opacity(0.6))
                                .font(.subheadline)

                            // Show hint to redo when collapsed
                            if !isExpanded {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .foregroundColor(.nebulaLavender.opacity(0.4))
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(!isComplete)

                Spacer()

                // Chevron toggle (only when complete)
                if isComplete {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }

                // Add stack button
                Button(action: onAddTap) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(isComplete ? timeBlock.color.opacity(0.4) : timeBlock.color)
                        .font(.title2)
                }
            }

            // Show stacks or placeholder (collapsible when complete)
            if isExpanded {
                if stacks.isEmpty {
                    Text("No stacks yet — tap + to create one")
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                } else {
                    ForEach(stacks) { stack in
                        HabitStackCard(stack: stack)
                            .onTapGesture {
                                onStackTap(stack)
                            }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground.opacity(isComplete ? 0.4 : 0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isComplete ? Color.nebulaCyan.opacity(0.2) : timeBlock.color.opacity(0.15), lineWidth: 1)
                )
        )
        .opacity(isComplete ? 0.7 : 1.0)
        .onChange(of: isComplete) { wasComplete, nowComplete in
            // Auto-collapse when section becomes complete
            if nowComplete && !wasComplete && !hasAutoCollapsed {
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    isExpanded = false
                    hasAutoCollapsed = true
                }
            }
            // Reset auto-collapse flag if section becomes incomplete again
            if !nowComplete {
                hasAutoCollapsed = false
                isExpanded = true
            }
        }
    }
}

// MARK: - Habit Stack Card (Compact)
struct HabitStackCard: View {
    let stack: HabitStack

    var completedCount: Int {
        stack.habits.filter { $0.isCompleted }.count
    }

    var totalHabits: Int {
        stack.habits.count
    }

    var firstHabitIcon: String {
        stack.sortedHabits.first?.icon ?? "link"
    }

    var isComplete: Bool {
        completedCount == totalHabits && totalHabits > 0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Anchor icon
            ZStack {
                Circle()
                    .fill(isComplete ? stack.color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)

                Circle()
                    .stroke(isComplete ? stack.color.opacity(0.5) : stack.color.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 48, height: 48)

                Image(systemName: firstHabitIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isComplete ? stack.color : .nebulaLavender.opacity(0.7))
            }

            // Stack info
            VStack(alignment: .leading, spacing: 4) {
                Text(stack.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.nebulaCyan.opacity(0.6))
                    Text(stack.anchorHabit)
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Progress & count
            VStack(alignment: .trailing, spacing: 4) {
                // Progress indicator
                HStack(spacing: 3) {
                    ForEach(0..<min(totalHabits, 5), id: \.self) { index in
                        Circle()
                            .fill(index < completedCount ? stack.color : Color.nebulaLavender.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                    if totalHabits > 5 {
                        Text("+")
                            .font(.system(size: 8))
                            .foregroundColor(.nebulaLavender.opacity(0.4))
                    }
                }

                // Count
                Text("\(completedCount)/\(totalHabits) habits")
                    .font(.caption2)
                    .foregroundColor(.nebulaLavender.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicDeep)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isComplete ? stack.color.opacity(0.4) : stack.color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: [HabitStack.self, Habit.self], inMemory: true)
}
