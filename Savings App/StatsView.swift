//
//  StatsView.swift
//  Habit Stacking App
//

import SwiftUI
import SwiftData

struct StatsView: View {
    let habitStacks: [HabitStack]
    @Environment(\.dismiss) private var dismiss
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = nil

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    // MARK: - Computed Properties

    var allHabits: [Habit] {
        habitStacks.flatMap { $0.habits }
    }

    var currentStreak: Int {
        calculateStreak()
    }

    var totalCompleted: Int {
        allHabits.filter { $0.isCompleted }.count
    }

    var monthlyCompleted: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        return allHabits.filter { habit in
            guard let completedAt = habit.completedAt else { return false }
            return completedAt >= startOfMonth && completedAt <= endOfMonth
        }.count
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 24) {
                // Header
                header

                // Stats Cards
                statsSection

                // Month Navigation
                monthNavigation

                // Calendar Grid
                calendarGrid

                Spacer()

                // Back Button
                backButton
            }
            .padding()
        }
        .sheet(item: $selectedDate) { date in
            DayHistoryView(date: date)
        }
    }

    // MARK: - Header

    var header: some View {
        Text("Your Progress")
            .font(.title.bold())
            .foregroundColor(.white)
    }

    // MARK: - Stats Section

    var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "flame.fill",
                value: "\(currentStreak)",
                label: "Day Streak",
                color: .nebulaMagenta
            )

            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(totalCompleted)",
                label: "Total",
                color: .nebulaCyan
            )

            StatCard(
                icon: "calendar",
                value: "\(monthlyCompleted)",
                label: "This Month",
                color: .nebulaGold
            )
        }
    }

    // MARK: - Month Navigation

    var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.nebulaLavender)
            }

            Spacer()

            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.nebulaLavender)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar Grid

    var calendarGrid: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.bold())
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(getDaysInMonth(), id: \.self) { day in
                    DayCell(
                        day: day,
                        displayedMonth: displayedMonth,
                        completionCount: completionsForDate(day),
                        isCurrentMonth: isInDisplayedMonth(day),
                        onTap: {
                            // Only allow tapping days that are not in the future
                            if day <= Date() && isInDisplayedMonth(day) {
                                selectedDate = day
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Back Button

    var backButton: some View {
        Button(action: { dismiss() }) {
            Text("Back")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.nebulaLavender.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.nebulaLavender.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Functions

    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func getDaysInMonth() -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        // Start from the Sunday before the first day of month
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: startOfMonth)!

        // Generate 42 days (6 weeks)
        return (0..<42).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startDate)
        }
    }

    func isInDisplayedMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }

    func completionsForDate(_ date: Date) -> Int {
        allHabits.filter { habit in
            guard let completedAt = habit.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: date)
        }.count
    }

    func calculateStreak() -> Int {
        var streak = 0
        var checkDate = Date()

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
}

// MARK: - Make Date Identifiable for sheet
extension Date: @retroactive Identifiable {
    public var id: TimeInterval { self.timeIntervalSince1970 }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 4)

            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let day: Date
    let displayedMonth: Date
    let completionCount: Int
    let isCurrentMonth: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var isToday: Bool {
        calendar.isDateInToday(day)
    }

    var isFuture: Bool {
        day > Date()
    }

    var dayNumber: Int {
        calendar.component(.day, from: day)
    }

    var cellColor: Color {
        guard isCurrentMonth else { return .clear }

        switch completionCount {
        case 0:
            return .nebulaLavender.opacity(0.05)
        case 1...2:
            return .nebulaCyan.opacity(0.3)
        case 3...4:
            return .nebulaCyan.opacity(0.5)
        default:
            return .nebulaCyan.opacity(0.8)
        }
    }

    var textColor: Color {
        if !isCurrentMonth {
            return .nebulaLavender.opacity(0.2)
        }
        if completionCount > 0 {
            return .white
        }
        return .nebulaLavender.opacity(0.5)
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(dayNumber)")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor)

            if isCurrentMonth && completionCount > 0 {
                Text("\(completionCount)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.nebulaCyan)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(cellColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.nebulaCyan : Color.clear, lineWidth: 2)
        )
        .shadow(color: isToday ? .nebulaCyan.opacity(0.3) : .clear, radius: 4)
        .onTapGesture {
            if isCurrentMonth && !isFuture {
                onTap()
            }
        }
    }
}

// MARK: - Day History View

struct DayHistoryView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Query private var allSessions: [SessionLog]

    init(date: Date) {
        self.date = date
        self._allSessions = Query(sort: \SessionLog.completedAt, order: .reverse)
    }

    // Filter sessions for this day
    private var sessionsThisDay: [SessionLog] {
        let calendar = Calendar.current
        return allSessions.filter { session in
            calendar.isDate(session.completedAt, inSameDayAs: date)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                    }

                    Spacer()

                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    // Invisible balance
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()

                if sessionsThisDay.isEmpty {
                    // Empty state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.nebulaLavender.opacity(0.4))

                        Text("No sessions recorded")
                            .font(.headline)
                            .foregroundColor(.nebulaLavender.opacity(0.6))

                        Text("Complete habit stacks to see your history here")
                            .font(.caption)
                            .foregroundColor(.nebulaLavender.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    // Sessions list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sessionsThisDay) { session in
                                SessionCard(session: session)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: SessionLog

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: session.completedAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.stackName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Completed at \(formattedTime)")
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                }

                Spacer()

                // Duration badge
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text(formatTime(session.totalDuration))
                        .font(.subheadline.bold())
                }
                .foregroundColor(.nebulaCyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.nebulaCyan.opacity(0.15))
                .cornerRadius(12)
            }

            // Stats row
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.nebulaGold)
                    Text("\(session.habitsCompleted) completed")
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                }

                if session.habitsSkipped > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                            .font(.caption)
                            .foregroundColor(.nebulaLavender)
                        Text("\(session.habitsSkipped) skipped")
                            .font(.caption)
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                    }
                }
            }

            // Habit breakdown
            if !session.habitLogs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(session.habitLogs.sorted(by: { $0.order < $1.order })) { habitLog in
                        HStack(spacing: 8) {
                            Image(systemName: habitLog.habitIcon)
                                .font(.caption)
                                .foregroundColor(habitLog.wasSkipped ? .nebulaLavender.opacity(0.4) : .nebulaCyan)
                                .frame(width: 20)

                            Text(habitLog.habitName)
                                .font(.caption)
                                .foregroundColor(habitLog.wasSkipped ? .nebulaLavender.opacity(0.4) : .white)
                                .strikethrough(habitLog.wasSkipped)

                            Spacer()

                            if habitLog.wasSkipped {
                                Text("skipped")
                                    .font(.caption2)
                                    .foregroundColor(.nebulaLavender.opacity(0.4))
                            } else {
                                Text(formatTime(habitLog.duration))
                                    .font(.caption)
                                    .foregroundColor(.nebulaLavender.opacity(0.5))
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }

            // Comment if present
            if !session.comment.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.4))

                    Text(session.comment)
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.7))
                        .italic()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    StatsView(habitStacks: [])
}
