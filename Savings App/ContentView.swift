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
    @StateObject private var intelligence = IntelligenceEngine.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var activeStack: HabitStack? = nil
    @State private var creatingStackFor: TimeBlock? = nil
    @State private var animationTrigger: UUID = UUID()
    @State private var showStats: Bool = false
    @State private var showInspiration: Bool = false
    @State private var showInsights: Bool = false
    @State private var showPaywall: Bool = false
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

    // Time blocks in natural order (no longer sorting by completion)
    var sortedTimeBlocks: [TimeBlock] {
        return TimeBlock.allCases
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
                        onInspirationTap: { showInspiration = true },
                        onInsightsTap: { showInsights = true }
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
        .sheet(isPresented: $showInsights) {
            SuggestionsListView()
        }
        .sheet(isPresented: $showPaywall) {
            CosmosPaywallView()
        }
        .sheet(item: $selectedSuggestedStack) { suggestedStack in
            SuggestedStackDetailSheet(
                suggestedStack: suggestedStack,
                onAddToStacks: { stack in
                    // Check premium limit
                    if !subscriptionService.canCreateMoreStacks(currentCount: habitStacks.count) {
                        selectedSuggestedStack = nil
                        showPaywall = true
                        return
                    }
                    modelContext.insert(stack)
                    selectedSuggestedStack = nil
                },
                onStartNow: { stack in
                    if !subscriptionService.canCreateMoreStacks(currentCount: habitStacks.count) {
                        selectedSuggestedStack = nil
                        showPaywall = true
                        return
                    }
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
                    // Re-analyze for insights
                    intelligence.analyze(stacks: habitStacks)
                }
            }
        }
        .onAppear {
            // Schedule notifications on app launch
            NotificationManager.shared.scheduleNotifications(for: habitStacks)
            // Analyze habits for intelligence suggestions
            intelligence.analyze(stacks: habitStacks)
        }
        .onChange(of: habitStacks.count) { _, _ in
            // Reschedule notifications when stacks are added/removed
            NotificationManager.shared.scheduleNotifications(for: habitStacks)
            // Re-analyze for insights
            intelligence.analyze(stacks: habitStacks)
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
    let onInsightsTap: () -> Void

    @State private var showStreakMessage = false
    @StateObject private var intelligence = IntelligenceEngine.shared

    private var streakMessage: String? {
        StreakMessages.message(for: currentStreak)
    }

    private var hasHighPrioritySuggestions: Bool {
        !intelligence.getHighPrioritySuggestions().isEmpty
    }

    var body: some View {
        VStack(spacing: CosmosSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.7))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Today, \(Date().formatted(date: .long, time: .omitted))")

                Spacer()

                // Insights button (if suggestions available)
                if !intelligence.suggestions.isEmpty {
                    Button(action: onInsightsTap) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(.nebulaCyan)
                                .frame(width: 36, height: 36)
                                .background(Color.cardBackground.opacity(0.8))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.nebulaCyan.opacity(0.3), lineWidth: 1)
                                )

                            if hasHighPrioritySuggestions {
                                Circle()
                                    .fill(Color.nebulaMagenta)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    .accessibilityLabel("View insights\(hasHighPrioritySuggestions ? ", has important notifications" : "")")
                }

                // Inspiration button
                Button(action: onInspirationTap) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.nebulaGold)
                        .frame(width: 36, height: 36)
                        .background(Color.cardBackground.opacity(0.8))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                        )
                }
                .accessibilityLabel("Get inspiration for new habits")

                // Streak indicator (tappable)
                Button(action: {
                    onStreakTap()
                    if streakMessage != nil {
                        showStreakMessage = true
                    }
                }) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.nebulaMagenta)
                        .frame(width: 36, height: 36)
                        .background(Color.cardBackground.opacity(0.8))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.nebulaMagenta.opacity(0.3), lineWidth: 1)
                        )
                }
                .accessibilityLabel("\(currentStreak) day streak")
                .accessibilityHint("Double tap to view statistics")

                // Profile menu
                ProfileMenuView()
            }

            // Streak milestone message
            if let message = streakMessage, showStreakMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.nebulaGold)
                    .padding(.horizontal, CosmosSpacing.md)
                    .padding(.vertical, CosmosSpacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.nebulaGold.opacity(0.15))
                    )
                    .transition(.opacity.combined(with: .scale))
                    .onAppear {
                        HapticManager.shared.play(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation(.cosmosStandard) {
                                showStreakMessage = false
                            }
                        }
                    }
            }
        }
        .animation(.cosmosStandard, value: showStreakMessage)
    }
}

// MARK: - Profile Menu
struct ProfileMenuView: View {
    @State private var showProfileSheet: Bool = false

    var body: some View {
        Button(action: { showProfileSheet = true }) {
            Image(systemName: "person.fill")
                .font(.system(size: 16))
                .foregroundColor(.nebulaLavender)
                .frame(width: 36, height: 36)
                .background(Color.cardBackground.opacity(0.8))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.nebulaLavender.opacity(0.3), lineWidth: 1)
                )
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileView()
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutAlert: Bool = false
    @State private var showPaywall: Bool = false
    @State private var notificationsEnabled: Bool = true
    @State private var hapticFeedbackEnabled: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CosmosSpacing.xl) {
                        // Profile Header
                        profileHeader

                        // Premium Section
                        premiumSection

                        // Settings Sections
                        settingsSection

                        // Account Section
                        accountSection

                        // App Info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.nebulaCyan)
                }
            }
            .toolbarBackground(Color.cosmicBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                try? authManager.signOut()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showPaywall) {
            CosmosPaywallView()
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: CosmosSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.nebulaPurple.opacity(0.2))
                    .frame(width: 80, height: 80)

                Circle()
                    .stroke(Color.nebulaPurple.opacity(0.5), lineWidth: 2)
                    .frame(width: 80, height: 80)

                if let name = authManager.user?.displayName, let firstLetter = name.first {
                    Text(String(firstLetter).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.nebulaPurple)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.nebulaPurple)
                }
            }

            // Name & Email
            VStack(spacing: 4) {
                if let name = authManager.user?.displayName {
                    Text(name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }

                if let email = authManager.user?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.7))
                }
            }

            // Premium Badge
            if subscriptionService.isPremium {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("Premium Member")
                        .font(.caption.bold())
                }
                .foregroundColor(.nebulaGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.nebulaGold.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.vertical, CosmosSpacing.lg)
    }

    // MARK: - Premium Section
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: CosmosSpacing.md) {
            Text("Subscription")
                .font(.headline)
                .foregroundColor(.white)

            if subscriptionService.isPremium {
                // Already premium
                CosmosCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.nebulaCyan)
                                Text("Premium Active")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Text("You have access to all features")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.7))
                        }
                        Spacer()
                    }
                }
            } else {
                // Upgrade prompt
                Button(action: { showPaywall = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.nebulaGold)
                                Text("Upgrade to Premium")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Text("Unlock unlimited stacks, insights & more")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.nebulaLavender.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CosmosRadius.lg)
                            .fill(
                                LinearGradient(
                                    colors: [Color.nebulaPurple.opacity(0.3), Color.nebulaMagenta.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmosRadius.lg)
                                    .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: CosmosSpacing.md) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.white)

            CosmosCard {
                VStack(spacing: 0) {
                    // Notifications
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .nebulaCyan,
                        title: "Notifications"
                    ) {
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .tint(.nebulaCyan)
                    }

                    Divider()
                        .background(Color.nebulaLavender.opacity(0.1))

                    // Haptic Feedback
                    SettingsRow(
                        icon: "hand.tap.fill",
                        iconColor: .nebulaMagenta,
                        title: "Haptic Feedback"
                    ) {
                        Toggle("", isOn: $hapticFeedbackEnabled)
                            .labelsHidden()
                            .tint(.nebulaMagenta)
                    }

                    Divider()
                        .background(Color.nebulaLavender.opacity(0.1))

                    // App Icon (Premium)
                    SettingsRow(
                        icon: "app.fill",
                        iconColor: .nebulaPurple,
                        title: "App Icon",
                        isPremium: !subscriptionService.isPremium
                    ) {
                        HStack(spacing: 4) {
                            Text("Default")
                                .font(.subheadline)
                                .foregroundColor(.nebulaLavender.opacity(0.5))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.3))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: CosmosSpacing.md) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.white)

            CosmosCard {
                VStack(spacing: 0) {
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await subscriptionService.restorePurchases()
                        }
                    }) {
                        SettingsRow(
                            icon: "arrow.clockwise",
                            iconColor: .nebulaGold,
                            title: "Restore Purchases"
                        ) {
                            if subscriptionService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }

                    Divider()
                        .background(Color.nebulaLavender.opacity(0.1))

                    // Export Data
                    Button(action: {}) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: .nebulaCyan,
                            title: "Export Data"
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.3))
                        }
                    }

                    Divider()
                        .background(Color.nebulaLavender.opacity(0.1))

                    // Sign Out
                    Button(action: { showSignOutAlert = true }) {
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            iconColor: .nebulaMagenta,
                            title: "Sign Out",
                            titleColor: .nebulaMagenta
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }

    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(spacing: CosmosSpacing.sm) {
            Text("Stakk")
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.5))

            Text("Version 1.0.0")
                .font(.caption2)
                .foregroundColor(.nebulaLavender.opacity(0.3))

            HStack(spacing: CosmosSpacing.lg) {
                Button(action: {}) {
                    Text("Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                }

                Text("•")
                    .foregroundColor(.nebulaLavender.opacity(0.3))

                Button(action: {}) {
                    Text("Terms of Service")
                        .font(.caption2)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                }
            }
        }
        .padding(.top, CosmosSpacing.lg)
    }
}

// MARK: - Settings Row
struct SettingsRow<Accessory: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    var titleColor: Color = .white
    var isPremium: Bool = false
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        HStack(spacing: CosmosSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)

            Text(title)
                .font(.subheadline)
                .foregroundColor(titleColor)

            if isPremium {
                Text("PRO")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.nebulaGold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.nebulaGold.opacity(0.2))
                    .cornerRadius(4)
            }

            Spacer()

            accessory()
        }
        .padding(.vertical, CosmosSpacing.md)
        .contentShape(Rectangle())
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

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isExpanded: Bool = true
    @State private var hasAutoCollapsed: Bool = false

    private var animation: Animation {
        reduceMotion ? .linear(duration: 0.01) : .cosmosStandard
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CosmosSpacing.md) {
            // Time block header (always tappable for dropdown)
            HStack(spacing: CosmosSpacing.lg) {
                // Tappable header area for expand/collapse
                Button(action: {
                    withAnimation(animation) {
                        isExpanded.toggle()
                    }
                    HapticManager.shared.play(.lightTap)
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
                        }

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(timeBlock.rawValue) section\(isComplete ? ", completed" : "")")
                .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")

                // Chevron toggle button - separate for easier tapping
                Button(action: {
                    withAnimation(animation) {
                        isExpanded.toggle()
                    }
                    HapticManager.shared.play(.lightTap)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isComplete ? .nebulaLavender.opacity(0.5) : .nebulaLavender.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(CosmosRadius.sm)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Collapse section" : "Expand section")

                // Add stack button - always bright
                Button(action: onAddTap) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(timeBlock.color)
                        .font(.title2)
                        .shadow(color: timeBlock.color.opacity(0.4), radius: 4)
                }
                .accessibilityLabel("Add new stack to \(timeBlock.rawValue)")
            }

            // Show stacks or placeholder (collapsible when complete)
            if isExpanded {
                if stacks.isEmpty {
                    Text("No habits yet. Tap + to create your first one.")
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(CosmosRadius.md)
                } else {
                    ForEach(stacks) { stack in
                        HabitStackCard(stack: stack)
                            .onTapGesture {
                                onStackTap(stack)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(stack.name), \(stack.habits.filter { $0.isCompleted }.count) of \(stack.habits.count) habits completed")
                            .accessibilityHint("Double tap to start session")
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CosmosRadius.lg)
                .fill(Color.cardBackground.opacity(isComplete ? 0.4 : 0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: CosmosRadius.lg)
                        .stroke(isComplete ? Color.nebulaCyan.opacity(0.2) : timeBlock.color.opacity(0.15), lineWidth: 1)
                )
        )
        .opacity(isComplete ? 0.7 : 1.0)
        .onChange(of: isComplete) { wasComplete, nowComplete in
            // Auto-collapse when section becomes complete
            if nowComplete && !wasComplete && !hasAutoCollapsed {
                let delayedAnimation = reduceMotion ? animation : animation.delay(0.5)
                withAnimation(delayedAnimation) {
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
                HStack(spacing: 6) {
                    Text(stack.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.nebulaCyan)
                    }
                }

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
        .modelContainer(for: [
            CosmosUser.self,
            HabitStack.self,
            Habit.self,
            HabitCompletion.self,
            SessionLog.self,
            HabitLog.self
        ], inMemory: true)
}
