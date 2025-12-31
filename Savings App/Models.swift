//
//  Models.swift
//  Cosmos Productivity Suite - Stakk
//
//  Data models following DATA_MODELS.md specifications
//

import SwiftUI
import SwiftData

// MARK: - Cosmos User Model
@Model
final class CosmosUser {
    var id: UUID = UUID()
    var createdAt: Date = Date()

    // Subscription
    var subscriptionTierRaw: String = "free"
    var subscriptionExpiresAt: Date?
    var subscriptionProductID: String?
    var originalPurchaseDate: Date?
    var hasLifetimePurchase: Bool = false

    // Preferences
    var preferredWakeTime: Date?
    var preferredSleepTime: Date?
    var workdayStart: Date?
    var workdayEnd: Date?
    var weekStartsOnMonday: Bool = true
    var timezone: String = TimeZone.current.identifier

    // Onboarding State
    var hasCompletedOnboarding: Bool = false
    var hasSeenPremiumPrompt: Bool = false
    var lastStreakMilestoneShown: Int = 0

    // Computed Properties
    var subscriptionTier: SubscriptionTier {
        get { SubscriptionTier(rawValue: subscriptionTierRaw) ?? .free }
        set { subscriptionTierRaw = newValue.rawValue }
    }

    var isPremium: Bool {
        if hasLifetimePurchase { return true }
        guard subscriptionTier == .premium else { return false }
        guard let expiresAt = subscriptionExpiresAt else { return false }
        return expiresAt > Date()
    }

    init() {
        self.id = UUID()
        self.createdAt = Date()
    }
}

// MARK: - Frequency Type
enum FrequencyType: String, Codable, CaseIterable {
    case daily
    case specificDays
    case timesPerWeek

    var displayName: String {
        switch self {
        case .daily: return "Every Day"
        case .specificDays: return "Specific Days"
        case .timesPerWeek: return "Times Per Week"
        }
    }
}

// MARK: - Mood Level
enum MoodLevel: Int, Codable, CaseIterable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case great = 5

    var emoji: String {
        switch self {
        case .veryLow: return "😔"
        case .low: return "😕"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }

    var displayName: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .great: return "Great"
        }
    }
}

// MARK: - Energy Level
enum EnergyLevel: Int, Codable, CaseIterable {
    case exhausted = 1
    case tired = 2
    case normal = 3
    case energized = 4
    case peak = 5

    var emoji: String {
        switch self {
        case .exhausted: return "🔋"
        case .tired: return "😴"
        case .normal: return "⚡"
        case .energized: return "💪"
        case .peak: return "🔥"
        }
    }

    var displayName: String {
        switch self {
        case .exhausted: return "Exhausted"
        case .tired: return "Tired"
        case .normal: return "Normal"
        case .energized: return "Energized"
        case .peak: return "Peak"
        }
    }
}

// MARK: - Habit Model
@Model
final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "circle.fill"
    var emoji: String?
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var order: Int = 0
    var createdAt: Date = Date()

    // Enhanced fields for cross-app compatibility
    var estimatedDurationMinutes: Int?
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalCompletions: Int = 0

    // Frequency settings
    var frequencyTypeRaw: String = "daily"
    var frequencyDaysRaw: String?  // Comma-separated weekday numbers
    var frequencyCount: Int?       // For timesPerWeek

    // Cross-app linking (for future Summit integration)
    var linkedGoalID: UUID?

    @Relationship(inverse: \HabitStack.habits)
    var stack: HabitStack?

    @Relationship(deleteRule: .cascade)
    var completions: [HabitCompletion] = []

    // Computed Properties
    var frequencyType: FrequencyType {
        get { FrequencyType(rawValue: frequencyTypeRaw) ?? .daily }
        set { frequencyTypeRaw = newValue.rawValue }
    }

    var frequencyDays: Set<Int>? {
        get {
            guard let raw = frequencyDaysRaw else { return nil }
            let days = raw.split(separator: ",").compactMap { Int($0) }
            return Set(days)
        }
        set {
            frequencyDaysRaw = newValue?.sorted().map { String($0) }.joined(separator: ",")
        }
    }

    init(name: String, icon: String, isCompleted: Bool = false, completedAt: Date? = nil, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.order = order
        self.createdAt = Date()
    }

    // MARK: - Streak Calculation
    func updateStreak(completed: Bool) {
        if completed {
            currentStreak += 1
            totalCompletions += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
    }

    /// Check if habit is at risk of breaking streak
    var isStreakAtRisk: Bool {
        guard currentStreak >= 3 else { return false }
        guard let lastCompletion = completedAt else { return true }

        let calendar = Calendar.current
        let hoursSinceCompletion = calendar.dateComponents([.hour], from: lastCompletion, to: Date()).hour ?? 0

        // At risk if more than 20 hours since last completion
        return hoursSinceCompletion >= 20
    }

    /// Completion rate for last 7 days
    var weeklyCompletionRate: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCompletions = completions.filter { $0.completedAt >= weekAgo }
        return Double(recentCompletions.count) / 7.0
    }
}

// MARK: - Habit Completion Model (New)
@Model
final class HabitCompletion {
    var id: UUID = UUID()
    var completedAt: Date = Date()
    var date: Date = Date()  // Calendar date without time for querying

    // Context for cross-app intelligence
    var durationMinutes: Int?
    var notes: String?
    var moodRaw: Int?
    var energyLevelRaw: Int?

    @Relationship(inverse: \Habit.completions)
    var habit: Habit?

    // Computed Properties
    var mood: MoodLevel? {
        get { moodRaw.flatMap { MoodLevel(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }

    var energyLevel: EnergyLevel? {
        get { energyLevelRaw.flatMap { EnergyLevel(rawValue: $0) } }
        set { energyLevelRaw = newValue?.rawValue }
    }

    init(habit: Habit? = nil, completedAt: Date = Date(), durationMinutes: Int? = nil) {
        self.id = UUID()
        self.habit = habit
        self.completedAt = completedAt
        self.date = Calendar.current.startOfDay(for: completedAt)
        self.durationMinutes = durationMinutes
    }
}

// MARK: - Habit Stack Model
@Model
final class HabitStack {
    var id: UUID = UUID()
    var name: String = ""
    var timeBlockRaw: String = "Morning"
    var anchorHabit: String = ""
    var reminderTime: Date = Date()
    @Relationship(deleteRule: .cascade)
    var habits: [Habit] = []
    var colorName: String = "nebulaGold"
    var streak: Int = 0
    var longestStreak: Int = 0
    var createdAt: Date = Date()
    var isArchived: Bool = false

    // Stores scheduled days as comma-separated weekday numbers (1=Sun, 2=Mon, ..., 7=Sat)
    var scheduledDaysRaw: String = "1,2,3,4,5,6,7"

    // Cross-app linking
    var linkedGoalID: UUID?

    var timeBlock: TimeBlock {
        get { TimeBlock(rawValue: timeBlockRaw) ?? .morning }
        set { timeBlockRaw = newValue.rawValue }
    }

    var color: Color {
        get { Color.fromName(colorName) }
        set { colorName = newValue.toName() }
    }

    var sortedHabits: [Habit] {
        habits.sorted { $0.order < $1.order }
    }

    var scheduledDays: Set<Int> {
        get {
            if scheduledDaysRaw.isEmpty {
                return Set(1...7)
            }
            let days = scheduledDaysRaw.split(separator: ",").compactMap { Int($0) }
            return Set(days)
        }
        set {
            scheduledDaysRaw = newValue.sorted().map { String($0) }.joined(separator: ",")
        }
    }

    var shouldShowToday: Bool {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        return scheduledDays.contains(todayWeekday)
    }

    var isEveryDay: Bool {
        scheduledDays.count == 7 || scheduledDaysRaw.isEmpty
    }

    /// Completion rate for this stack
    var completionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let completed = habits.filter { $0.isCompleted }.count
        return Double(completed) / Double(habits.count)
    }

    /// Check if all habits are completed today
    var isCompletedToday: Bool {
        guard !habits.isEmpty else { return false }
        return habits.allSatisfy { habit in
            guard habit.isCompleted, let completedAt = habit.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }
    }

    init(name: String, timeBlock: TimeBlock, anchorHabit: String, reminderTime: Date, habits: [Habit] = [], color: Color, streak: Int = 0, scheduledDays: Set<Int> = Set(1...7)) {
        self.id = UUID()
        self.name = name
        self.timeBlockRaw = timeBlock.rawValue
        self.anchorHabit = anchorHabit
        self.reminderTime = reminderTime
        self.habits = habits
        self.colorName = color.toName()
        self.streak = streak
        self.createdAt = Date()
        self.scheduledDaysRaw = scheduledDays.sorted().map { String($0) }.joined(separator: ",")
    }

    /// Update stack streak
    func updateStreak() {
        if isCompletedToday {
            streak += 1
            if streak > longestStreak {
                longestStreak = streak
            }
        }
    }
}

// MARK: - Weekday Helpers
struct WeekdayHelper {
    static let allDays: Set<Int> = Set(1...7)
    static let weekdays: Set<Int> = Set(2...6)
    static let weekends: Set<Int> = [1, 7]

    static func shortName(for weekday: Int) -> String {
        switch weekday {
        case 1: return "Sun"
        case 2: return "Mon"
        case 3: return "Tue"
        case 4: return "Wed"
        case 5: return "Thu"
        case 6: return "Fri"
        case 7: return "Sat"
        default: return ""
        }
    }

    static func letter(for weekday: Int) -> String {
        switch weekday {
        case 1: return "S"
        case 2: return "M"
        case 3: return "T"
        case 4: return "W"
        case 5: return "T"
        case 6: return "F"
        case 7: return "S"
        default: return ""
        }
    }

    static let displayOrder: [Int] = [2, 3, 4, 5, 6, 7, 1]
}

// MARK: - Session Log Model
@Model
final class SessionLog {
    var id: UUID = UUID()
    var stackId: UUID = UUID()
    var stackName: String = ""
    var completedAt: Date = Date()
    var totalDuration: Int = 0
    var comment: String = ""
    var habitsCompleted: Int = 0
    var habitsSkipped: Int = 0
    var moodRaw: Int?
    var energyLevelRaw: Int?

    @Relationship(deleteRule: .cascade)
    var habitLogs: [HabitLog] = []

    var mood: MoodLevel? {
        get { moodRaw.flatMap { MoodLevel(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }

    var energyLevel: EnergyLevel? {
        get { energyLevelRaw.flatMap { EnergyLevel(rawValue: $0) } }
        set { energyLevelRaw = newValue?.rawValue }
    }

    init(stackId: UUID, stackName: String, totalDuration: Int, comment: String = "", habitsCompleted: Int, habitsSkipped: Int, habitLogs: [HabitLog] = []) {
        self.id = UUID()
        self.stackId = stackId
        self.stackName = stackName
        self.completedAt = Date()
        self.totalDuration = totalDuration
        self.comment = comment
        self.habitsCompleted = habitsCompleted
        self.habitsSkipped = habitsSkipped
        self.habitLogs = habitLogs
    }
}

// MARK: - Habit Log Model
@Model
final class HabitLog {
    var id: UUID = UUID()
    var habitName: String = ""
    var habitIcon: String = "circle.fill"
    var duration: Int = 0
    var wasSkipped: Bool = false
    var order: Int = 0

    @Relationship(inverse: \SessionLog.habitLogs)
    var sessionLog: SessionLog?

    init(habitName: String, habitIcon: String, duration: Int, wasSkipped: Bool, order: Int) {
        self.id = UUID()
        self.habitName = habitName
        self.habitIcon = habitIcon
        self.duration = duration
        self.wasSkipped = wasSkipped
        self.order = order
    }
}

// MARK: - Color Persistence Helpers
extension Color {
    static func fromName(_ name: String) -> Color {
        switch name {
        case "nebulaCyan": return .nebulaCyan
        case "nebulaMagenta": return .nebulaMagenta
        case "nebulaLavender": return .nebulaLavender
        case "nebulaPurple": return .nebulaPurple
        case "nebulaGold": return .nebulaGold
        default: return .nebulaGold
        }
    }

    func toName() -> String {
        switch self {
        case .nebulaCyan: return "nebulaCyan"
        case .nebulaMagenta: return "nebulaMagenta"
        case .nebulaLavender: return "nebulaLavender"
        case .nebulaPurple: return "nebulaPurple"
        case .nebulaGold: return "nebulaGold"
        default: return "nebulaGold"
        }
    }
}

// MARK: - Icon Detection
func detectIcon(for habitName: String) -> String {
    let name = habitName.lowercased()

    let iconMap: [String: String] = [
        // Morning & Wake Up
        "wake": "sunrise.fill",
        "alarm": "alarm.fill",
        "sunrise": "sunrise.fill",
        "morning": "sun.horizon.fill",
        "stretch": "figure.flexibility",

        // Sleep & Night
        "sleep": "bed.double.fill",
        "bed": "bed.double.fill",
        "rest": "bed.double.fill",
        "relax": "figure.mind.and.body",

        // Hygiene
        "shower": "shower.fill",
        "teeth": "mouth.fill",
        "brush": "mouth.fill",
        "skincare": "face.smiling",
        "face": "face.smiling",

        // Exercise
        "exercise": "figure.run",
        "workout": "dumbbell.fill",
        "gym": "dumbbell.fill",
        "run": "figure.run",
        "walk": "figure.walk",
        "yoga": "figure.yoga",
        "stretching": "figure.flexibility",

        // Mindfulness
        "meditate": "brain.head.profile",
        "meditation": "brain.head.profile",
        "breathe": "wind",
        "mindful": "brain.head.profile",
        "gratitude": "heart.fill",
        "journal": "book.fill",

        // Food & Drinks
        "breakfast": "cup.and.saucer.fill",
        "lunch": "fork.knife",
        "dinner": "fork.knife",
        "water": "drop.fill",
        "hydrate": "drop.fill",
        "coffee": "cup.and.saucer.fill",
        "tea": "cup.and.saucer.fill",

        // Work
        "work": "briefcase.fill",
        "email": "envelope.fill",
        "meeting": "person.3.fill",
        "task": "checklist",
        "plan": "calendar",

        // Learning
        "read": "book.fill",
        "reading": "book.fill",
        "study": "book.fill",
        "learn": "graduationcap.fill",
        "podcast": "headphones",

        // Health
        "medicine": "pill.fill",
        "vitamin": "pill.fill",
        "supplements": "pill.fill",

        // Habits
        "habit": "checkmark.circle.fill",
        "routine": "repeat",
        "goal": "target",
        "streak": "flame.fill"
    ]

    // Check for exact word matches
    let words = name.components(separatedBy: CharacterSet.alphanumerics.inverted)
    for word in words {
        if let icon = iconMap[word] {
            return icon
        }
    }

    // Check for partial matches
    for (keyword, icon) in iconMap {
        if name.contains(keyword) {
            return icon
        }
    }

    return "circle.fill"
}
