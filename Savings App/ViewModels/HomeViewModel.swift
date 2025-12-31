//
//  HomeViewModel.swift
//  Cosmos Productivity Suite - Stakk
//
//  ViewModel for the main Home screen following PROJECT_STRUCTURE.md
//

import SwiftUI
import SwiftData
import Observation

// MARK: - Home View Model
@MainActor
@Observable
class HomeViewModel {
    // MARK: - Services
    private let intelligence = IntelligenceEngine.shared
    private let subscriptionService = SubscriptionService.shared

    // MARK: - State
    var activeStack: HabitStack?
    var creatingStackFor: TimeBlock?
    var showStats = false
    var showInspiration = false
    var showInsights = false
    var showPaywall = false
    var selectedAnchorTemplate: AnchorTemplate?
    var selectedSuggestedStack: SuggestedStack?
    var animationTrigger = UUID()

    // MARK: - Computed Properties
    func totalCompletedToday(stacks: [HabitStack]) -> Int {
        stacks.flatMap { $0.habits }.filter { $0.isCompleted }.count
    }

    func isSectionComplete(_ block: TimeBlock, stacks: [HabitStack]) -> Bool {
        let stacksInBlock = stacks.filter { $0.timeBlock == block && $0.shouldShowToday }
        guard !stacksInBlock.isEmpty else { return false }

        return stacksInBlock.allSatisfy { stack in
            guard !stack.habits.isEmpty else { return false }
            return stack.habits.allSatisfy { habit in
                guard habit.isCompleted, let completedAt = habit.completedAt else { return false }
                return Calendar.current.isDateInToday(completedAt)
            }
        }
    }

    func currentStreak(stacks: [HabitStack]) -> Int {
        let calendar = Calendar.current
        let allHabits = stacks.flatMap { $0.habits }
        var streak = 0
        var checkDate = Date()

        func completionsForDate(_ date: Date) -> Int {
            allHabits.filter { habit in
                guard let completedAt = habit.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: date)
            }.count
        }

        if completionsForDate(checkDate) == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        while completionsForDate(checkDate) > 0 {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    // MARK: - Actions
    func openStats() {
        showStats = true
    }

    func openInspiration() {
        showInspiration = true
    }

    func openInsights() {
        showInsights = true
    }

    func createStack(for timeBlock: TimeBlock) {
        creatingStackFor = timeBlock
    }

    func startSession(stack: HabitStack) {
        activeStack = stack
    }

    func sessionCompleted(stacks: [HabitStack]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.animationTrigger = UUID()
            self?.intelligence.analyze(stacks: stacks)
        }
    }

    func canCreateMoreStacks(currentCount: Int) -> Bool {
        subscriptionService.canCreateMoreStacks(currentCount: currentCount)
    }

    func showPremiumPaywall() {
        showPaywall = true
    }

    func analyzeHabits(stacks: [HabitStack]) {
        intelligence.analyze(stacks: stacks)
    }

    // MARK: - Suggested Stack Actions
    func addSuggestedStack(_ stack: HabitStack, currentCount: Int, modelContext: ModelContext) {
        if !canCreateMoreStacks(currentCount: currentCount) {
            selectedSuggestedStack = nil
            showPaywall = true
            return
        }
        modelContext.insert(stack)
        selectedSuggestedStack = nil
    }

    func startSuggestedStack(_ stack: HabitStack, currentCount: Int, modelContext: ModelContext) {
        if !canCreateMoreStacks(currentCount: currentCount) {
            selectedSuggestedStack = nil
            showPaywall = true
            return
        }
        modelContext.insert(stack)
        selectedSuggestedStack = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.activeStack = stack
        }
    }
}

// MARK: - Stats View Model
@MainActor
@Observable
class StatsViewModel {
    let habitStacks: [HabitStack]

    init(habitStacks: [HabitStack]) {
        self.habitStacks = habitStacks
    }

    var totalHabits: Int {
        habitStacks.flatMap { $0.habits }.count
    }

    var completedToday: Int {
        habitStacks.flatMap { $0.habits }
            .filter { habit in
                guard habit.isCompleted, let completedAt = habit.completedAt else { return false }
                return Calendar.current.isDateInToday(completedAt)
            }
            .count
    }

    var totalCompletions: Int {
        habitStacks.flatMap { $0.habits }.reduce(0) { $0 + $1.totalCompletions }
    }

    var longestStreak: Int {
        habitStacks.map { $0.longestStreak }.max() ?? 0
    }

    var averageCompletionRate: Double {
        let habits = habitStacks.flatMap { $0.habits }
        guard !habits.isEmpty else { return 0 }
        return habits.reduce(0.0) { $0 + $1.weeklyCompletionRate } / Double(habits.count)
    }

    // Weekly completion data for charts
    func weeklyCompletionData() -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        var data: [(String, Int)] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let count = habitStacks.flatMap { $0.habits }
                .filter { habit in
                    guard let completedAt = habit.completedAt else { return false }
                    return calendar.isDate(completedAt, inSameDayAs: date)
                }
                .count
            data.append((dayName, count))
        }

        return data
    }
}

// MARK: - Create Stack View Model
@MainActor
@Observable
class CreateStackViewModel {
    let timeBlock: TimeBlock
    var stackName = ""
    var anchorHabit = ""
    var reminderTime = Date()
    var selectedDays: Set<Int> = Set(1...7)
    var habits: [EditableHabit] = []
    var isGuidedMode = false

    struct EditableHabit: Identifiable {
        let id = UUID()
        var name: String
        var icon: String

        init(name: String = "", icon: String = "circle.fill") {
            self.name = name
            self.icon = icon
        }
    }

    init(timeBlock: TimeBlock, prefilledAnchor: String? = nil, prefilledStackName: String? = nil, isGuidedMode: Bool = false) {
        self.timeBlock = timeBlock
        self.anchorHabit = prefilledAnchor ?? ""
        self.stackName = prefilledStackName ?? ""
        self.isGuidedMode = isGuidedMode
    }

    var isValid: Bool {
        !stackName.isEmpty && !anchorHabit.isEmpty && !habits.isEmpty
    }

    var stackColor: Color {
        timeBlock.color
    }

    func addHabit(_ name: String) {
        let icon = detectIcon(for: name)
        habits.append(EditableHabit(name: name, icon: icon))
    }

    func removeHabit(at index: Int) {
        guard habits.indices.contains(index) else { return }
        habits.remove(at: index)
    }

    func moveHabit(from: Int, to: Int) {
        guard habits.indices.contains(from), habits.indices.contains(to) else { return }
        let habit = habits.remove(at: from)
        habits.insert(habit, at: to)
    }

    func createStack() -> HabitStack {
        let stack = HabitStack(
            name: stackName,
            timeBlock: timeBlock,
            anchorHabit: anchorHabit,
            reminderTime: reminderTime,
            habits: habits.enumerated().map { index, editable in
                Habit(name: editable.name, icon: editable.icon, order: index)
            },
            color: stackColor,
            scheduledDays: selectedDays
        )
        return stack
    }
}
