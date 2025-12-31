//
//  IntelligenceEngine.swift
//  Cosmos Productivity Suite - Stakk
//
//  On-device intelligence following INTELLIGENCE_ENGINE.md
//

import SwiftUI
import SwiftData

// MARK: - Suggestion Types
enum SuggestionType: String {
    case habitStreakRisk
    case habitOptimization
    case newHabitSuggestion
    case scheduleOptimization
    case weeklyReview
    case moodCorrelation
    case completionPattern
}

// MARK: - Suggestion Priority
enum SuggestionPriority: Int, Comparable {
    case low = 0
    case medium = 1
    case high = 2

    static func < (lhs: SuggestionPriority, rhs: SuggestionPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Suggestion Model
struct Suggestion: Identifiable {
    let id: UUID
    let type: SuggestionType
    let priority: SuggestionPriority
    let title: String
    let message: String
    let createdAt: Date
    let expiresAt: Date?
    let habitID: UUID?
    let stackID: UUID?
    let dismissable: Bool

    init(
        type: SuggestionType,
        priority: SuggestionPriority,
        title: String,
        message: String,
        habitID: UUID? = nil,
        stackID: UUID? = nil,
        expiresAt: Date? = nil,
        dismissable: Bool = true
    ) {
        self.id = UUID()
        self.type = type
        self.priority = priority
        self.title = title
        self.message = message
        self.createdAt = Date()
        self.expiresAt = expiresAt
        self.habitID = habitID
        self.stackID = stackID
        self.dismissable = dismissable
    }
}

// MARK: - At Risk Habit
struct AtRiskHabit: Identifiable {
    let id: UUID
    let habit: Habit
    let riskLevel: RiskLevel
    let reason: AtRiskReason
    let suggestedAction: String

    enum RiskLevel {
        case low, medium, high

        var color: Color {
            switch self {
            case .low: return .nebulaGold
            case .medium: return .nebulaMagenta
            case .high: return .nebulaMagenta
            }
        }
    }

    enum AtRiskReason {
        case decliningRate      // Completion rate dropping
        case missedRecently     // Missed last 2+ days
        case neverOnThisDay     // Never completed on today's day of week
        case longStreak         // Long streak creates pressure

        var description: String {
            switch self {
            case .decliningRate: return "Completion rate is dropping"
            case .missedRecently: return "Missed recently"
            case .neverOnThisDay: return "You rarely complete this on this day"
            case .longStreak: return "Long streak at risk"
            }
        }
    }
}

// MARK: - Productivity Window
struct ProductivityWindow: Identifiable {
    let id = UUID()
    let dayOfWeek: Int?        // nil = every day
    let hourRange: ClosedRange<Int>
    let confidence: Double
    let evidence: String

    var timeDescription: String {
        let startHour = hourRange.lowerBound
        let endHour = hourRange.upperBound
        let start = formatHour(startHour)
        let end = formatHour(endHour)
        return "\(start) - \(end)"
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(displayHour)\(period)"
    }
}

// MARK: - Intelligence Engine
@MainActor
class IntelligenceEngine: ObservableObject {
    static let shared = IntelligenceEngine()

    @Published private(set) var suggestions: [Suggestion] = []
    @Published private(set) var atRiskHabits: [AtRiskHabit] = []
    @Published private(set) var productivityWindows: [ProductivityWindow] = []

    private var dismissedSuggestionIDs: Set<UUID> = []

    private init() {}

    // MARK: - Analyze Data
    func analyze(stacks: [HabitStack]) {
        suggestions.removeAll()
        atRiskHabits.removeAll()

        let allHabits = stacks.flatMap { $0.habits }

        // Detect at-risk habits
        detectAtRiskHabits(allHabits)

        // Generate suggestions
        generateStreakRiskSuggestions()
        generateOptimizationSuggestions(stacks: stacks)
        generateCompletionPatternInsights(habits: allHabits)

        // Sort by priority
        suggestions.sort { $0.priority > $1.priority }

        // Apply rate limiting
        suggestions = Array(suggestions.prefix(10))
    }

    // MARK: - At Risk Detection
    private func detectAtRiskHabits(_ habits: [Habit]) {
        for habit in habits {
            if let atRisk = checkIfAtRisk(habit) {
                atRiskHabits.append(atRisk)
            }
        }
    }

    private func checkIfAtRisk(_ habit: Habit) -> AtRiskHabit? {
        // Check for long streak at risk
        if habit.currentStreak >= 7 && habit.isStreakAtRisk {
            return AtRiskHabit(
                id: UUID(),
                habit: habit,
                riskLevel: habit.currentStreak >= 14 ? .high : .medium,
                reason: .longStreak,
                suggestedAction: "Complete this habit today to maintain your \(habit.currentStreak)-day streak"
            )
        }

        // Check for missed recently
        if let lastCompletion = habit.completedAt {
            let daysSince = Calendar.current.dateComponents([.day], from: lastCompletion, to: Date()).day ?? 0
            if daysSince >= 2 && habit.currentStreak == 0 {
                return AtRiskHabit(
                    id: UUID(),
                    habit: habit,
                    riskLevel: .low,
                    reason: .missedRecently,
                    suggestedAction: "Get back on track with '\(habit.name)'"
                )
            }
        }

        // Check for declining completion rate
        if habit.weeklyCompletionRate < 0.5 && habit.totalCompletions > 7 {
            return AtRiskHabit(
                id: UUID(),
                habit: habit,
                riskLevel: .medium,
                reason: .decliningRate,
                suggestedAction: "Your completion rate for '\(habit.name)' has dropped. Consider adjusting the time or frequency."
            )
        }

        return nil
    }

    // MARK: - Streak Risk Suggestions
    private func generateStreakRiskSuggestions() {
        for atRisk in atRiskHabits where atRisk.riskLevel == .high {
            let suggestion = Suggestion(
                type: .habitStreakRisk,
                priority: .high,
                title: "\(atRisk.habit.currentStreak)-day streak at risk",
                message: "You haven't completed '\(atRisk.habit.name)' today. Your streak will reset at midnight.",
                habitID: atRisk.habit.id,
                expiresAt: Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
            )
            addSuggestion(suggestion)
        }
    }

    // MARK: - Optimization Suggestions
    private func generateOptimizationSuggestions(stacks: [HabitStack]) {
        for stack in stacks {
            // Check for optimal habit ordering
            let completionOrder = analyzeCompletionOrder(stack.habits)
            if let reorderSuggestion = completionOrder {
                addSuggestion(reorderSuggestion)
            }

            // Check for schedule optimization
            if let scheduleSuggestion = analyzeSchedule(stack) {
                addSuggestion(scheduleSuggestion)
            }
        }
    }

    private func analyzeCompletionOrder(_ habits: [Habit]) -> Suggestion? {
        // Simplified: suggest putting highest completion rate habits first
        let sortedByRate = habits.sorted { $0.weeklyCompletionRate > $1.weeklyCompletionRate }
        let currentOrder = habits.sorted { $0.order < $1.order }

        if sortedByRate.first?.id != currentOrder.first?.id,
           let bestHabit = sortedByRate.first,
           bestHabit.weeklyCompletionRate > 0.8 {
            return Suggestion(
                type: .habitOptimization,
                priority: .low,
                title: "Stack order tip",
                message: "Consider moving '\(bestHabit.name)' to the start of your stack. It has your highest completion rate.",
                habitID: bestHabit.id
            )
        }

        return nil
    }

    private func analyzeSchedule(_ stack: HabitStack) -> Suggestion? {
        // Check if stack is scheduled on days with low completion
        let completionRate = stack.completionRate

        if completionRate < 0.3 && !stack.habits.isEmpty {
            return Suggestion(
                type: .scheduleOptimization,
                priority: .medium,
                title: "Schedule review",
                message: "'\(stack.name)' has a low completion rate. Consider adjusting the scheduled days or reminder time.",
                stackID: stack.id
            )
        }

        return nil
    }

    // MARK: - Completion Pattern Insights
    private func generateCompletionPatternInsights(habits: [Habit]) {
        // Analyze completion times to find productivity windows
        var hourCounts: [Int: Int] = [:]

        for habit in habits {
            for completion in habit.completions {
                let hour = Calendar.current.component(.hour, from: completion.completedAt)
                hourCounts[hour, default: 0] += 1
            }
        }

        // Find peak hours
        if let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key,
           hourCounts[peakHour, default: 0] > 5 {
            let window = ProductivityWindow(
                dayOfWeek: nil,
                hourRange: peakHour...(peakHour + 2),
                confidence: 0.7,
                evidence: "You complete most habits around this time"
            )
            productivityWindows.append(window)

            addSuggestion(Suggestion(
                type: .completionPattern,
                priority: .low,
                title: "Peak productivity time",
                message: "You're most productive \(window.timeDescription). Schedule important habits then.",
                expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())
            ))
        }
    }

    // MARK: - Suggestion Management
    private func addSuggestion(_ suggestion: Suggestion) {
        guard !dismissedSuggestionIDs.contains(suggestion.id) else { return }

        // Check expiry
        if let expiresAt = suggestion.expiresAt, expiresAt < Date() {
            return
        }

        suggestions.append(suggestion)
    }

    func dismissSuggestion(_ suggestion: Suggestion) {
        dismissedSuggestionIDs.insert(suggestion.id)
        suggestions.removeAll { $0.id == suggestion.id }
    }

    func clearAllSuggestions() {
        suggestions.removeAll()
    }

    // MARK: - Get Suggestions for Display
    func getActiveSuggestions(limit: Int = 5) -> [Suggestion] {
        Array(suggestions.prefix(limit))
    }

    func getHighPrioritySuggestions() -> [Suggestion] {
        suggestions.filter { $0.priority == .high }
    }
}

// MARK: - Suggestion Card View
struct SuggestionCardView: View {
    let suggestion: Suggestion
    let onDismiss: () -> Void
    let onAction: () -> Void

    var priorityColor: Color {
        switch suggestion.priority {
        case .high: return .nebulaMagenta
        case .medium: return .nebulaGold
        case .low: return .nebulaLavender
        }
    }

    var priorityIcon: String {
        switch suggestion.priority {
        case .high: return "exclamationmark.circle.fill"
        case .medium: return "lightbulb.fill"
        case .low: return "info.circle.fill"
        }
    }

    var body: some View {
        CosmosCard(borderColor: priorityColor) {
            VStack(alignment: .leading, spacing: CosmosSpacing.sm) {
                HStack {
                    Image(systemName: priorityIcon)
                        .foregroundColor(priorityColor)

                    Text(suggestion.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    if suggestion.dismissable {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.nebulaLavender.opacity(0.6))
                        }
                        .accessibilityLabel("Dismiss suggestion")
                    }
                }

                Text(suggestion.message)
                    .font(.subheadline)
                    .foregroundColor(.nebulaLavender.opacity(0.8))
                    .lineLimit(3)

                if suggestion.habitID != nil || suggestion.stackID != nil {
                    Button(action: onAction) {
                        Text("View")
                            .font(.caption.bold())
                            .foregroundColor(priorityColor)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suggestion.priority == .high ? "Important: " : "")\(suggestion.title). \(suggestion.message)")
    }
}

// MARK: - At Risk Badge View
struct AtRiskHabitBadge: View {
    let atRisk: AtRiskHabit

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
                .foregroundColor(atRisk.riskLevel.color)

            Text(atRisk.reason.description)
                .font(.caption2)
                .foregroundColor(atRisk.riskLevel.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(atRisk.riskLevel.color.opacity(0.15))
        )
        .accessibilityLabel("Warning: \(atRisk.reason.description)")
    }
}

// MARK: - Suggestions List View
struct SuggestionsListView: View {
    @StateObject private var intelligence = IntelligenceEngine.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                if intelligence.suggestions.isEmpty {
                    CosmosEmptyState(
                        icon: "sparkles",
                        title: "No suggestions",
                        message: "Keep completing habits and we'll share insights when we spot patterns."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: CosmosSpacing.md) {
                            ForEach(intelligence.suggestions) { suggestion in
                                SuggestionCardView(
                                    suggestion: suggestion,
                                    onDismiss: {
                                        withAnimation(.cosmosStandard) {
                                            intelligence.dismissSuggestion(suggestion)
                                        }
                                    },
                                    onAction: {
                                        // Handle navigation to habit/stack
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.nebulaCyan)
                }
            }
        }
    }
}
