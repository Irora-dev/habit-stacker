//
//  NotificationManager.swift
//  Habit Stacking App
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notifications

    /// Schedules notifications for all habit stacks, grouping those with similar times
    func scheduleNotifications(for stacks: [HabitStack]) {
        // First, remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard isAuthorized else { return }

        // Group stacks by their reminder time (within 15-minute windows)
        let groupedStacks = groupStacksByTime(stacks)

        // Schedule a notification for each group
        for (timeKey, stackGroup) in groupedStacks {
            scheduleGroupedNotification(for: stackGroup, at: timeKey)
        }
    }

    /// Groups habit stacks that have reminder times within 30 minutes of each other
    private func groupStacksByTime(_ stacks: [HabitStack]) -> [Date: [HabitStack]] {
        let calendar = Calendar.current
        var groups: [Date: [HabitStack]] = [:]

        for stack in stacks {
            // Normalize the reminder time to today
            let reminderComponents = calendar.dateComponents([.hour, .minute], from: stack.reminderTime)
            guard let normalizedTime = calendar.date(
                bySettingHour: reminderComponents.hour ?? 0,
                minute: reminderComponents.minute ?? 0,
                second: 0,
                of: Date()
            ) else { continue }

            // Round to nearest 30-minute interval for grouping
            let roundedTime = roundToNearest30Minutes(normalizedTime)

            if groups[roundedTime] != nil {
                groups[roundedTime]?.append(stack)
            } else {
                groups[roundedTime] = [stack]
            }
        }

        return groups
    }

    private func roundToNearest30Minutes(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let minute = components.minute ?? 0
        let roundedMinute = (minute / 30) * 30

        return calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: roundedMinute,
            second: 0,
            of: date
        ) ?? date
    }

    private func scheduleGroupedNotification(for stacks: [HabitStack], at time: Date) {
        guard !stacks.isEmpty else { return }

        let content = UNMutableNotificationContent()

        if stacks.count == 1 {
            // Single stack notification
            let stack = stacks[0]
            content.title = "Time for \(stack.name)"
            content.body = "You have \(stack.habits.count) habits to complete. Start with: \(stack.anchorHabit)"
        } else {
            // Multiple stacks notification
            let stackNames = stacks.map { $0.name }
            let totalHabits = stacks.reduce(0) { $0 + $1.habits.count }

            content.title = "Time for your habits!"
            if stacks.count == 2 {
                content.body = "\(stackNames[0]) and \(stackNames[1]) are ready. \(totalHabits) habits total."
            } else {
                content.body = "\(stackNames[0]) and \(stacks.count - 1) other stacks are ready. \(totalHabits) habits total."
            }
        }

        content.sound = .default
        content.badge = NSNumber(value: stacks.count)

        // Create trigger for the reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true // Repeat daily
        )

        // Create unique identifier based on time
        let identifier = "habitstack-\(components.hour ?? 0)-\(components.minute ?? 0)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // MARK: - Cancel Notifications

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func cancelNotification(for stack: HabitStack) {
        // Since we group notifications, we need to reschedule all
        // This will be called when a stack is deleted
        // The parent view should call scheduleNotifications with updated list
    }

    // MARK: - Debug

    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications: \(requests.count)")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
            }
        }
    }
}

// MARK: - Notification Extension for HabitStack
extension HabitStack {
    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
}
