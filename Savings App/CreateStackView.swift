//
//  CreateStackView.swift
//  Habit Stacking App
//

import SwiftUI

// MARK: - Suggested Habit Model
struct SuggestedHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

struct CreateStackView: View {
    let timeBlock: TimeBlock
    let onSave: (HabitStack) -> Void
    let prefilledAnchor: String?
    let prefilledStackName: String?
    let isGuidedMode: Bool

    @State private var stackName: String = ""
    @State private var anchorHabit: String = ""
    @State private var reminderTime: Date = Date()
    @State private var habits: [Habit] = []
    @State private var newHabitName: String = ""
    @State private var showAnchorPicker: Bool = false
    @State private var isEveryDay: Bool = true
    @State private var selectedDays: Set<Int> = Set(1...7)
    @Environment(\.dismiss) private var dismiss

    // Suggested habits for morning routine
    private let suggestedMorningHabits: [SuggestedHabit] = [
        SuggestedHabit(name: "Meditation", icon: "brain.head.profile"),
        SuggestedHabit(name: "Reading", icon: "book.fill"),
        SuggestedHabit(name: "Journaling", icon: "pencil.and.outline"),
        SuggestedHabit(name: "Skin Care", icon: "face.smiling"),
        SuggestedHabit(name: "Stretching", icon: "figure.flexibility"),
        SuggestedHabit(name: "Hydrate", icon: "drop.fill"),
        SuggestedHabit(name: "Make Bed", icon: "bed.double.fill"),
        SuggestedHabit(name: "Cold Shower", icon: "shower.fill")
    ]

    init(timeBlock: TimeBlock, prefilledAnchor: String? = nil, prefilledStackName: String? = nil, isGuidedMode: Bool = false, onSave: @escaping (HabitStack) -> Void) {
        self.timeBlock = timeBlock
        self.prefilledAnchor = prefilledAnchor
        self.prefilledStackName = prefilledStackName
        self.isGuidedMode = isGuidedMode
        self.onSave = onSave
        // Initialize with prefilled values if provided
        self._anchorHabit = State(initialValue: prefilledAnchor ?? "")
        self._stackName = State(initialValue: prefilledStackName ?? "")
    }
    
    var canSave: Bool {
        !stackName.isEmpty && !anchorHabit.isEmpty && !habits.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Cosmic background
            CosmicBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header
                    
                    // Stack name
                    inputSection(title: "Stack Name", placeholder: "e.g., Morning Kickstart") {
                        TextField("", text: $stackName)
                            .textFieldStyle(CosmicTextFieldStyle())
                    }
                    
                    // Anchor habit (first habit in the stack)
                    inputSection(title: "Anchor Habit", subtitle: "Your first habit - something you already do that starts this stack", placeholder: "") {
                        HStack(spacing: 12) {
                            TextField("e.g., Brush teeth", text: $anchorHabit)
                                .textFieldStyle(CosmicTextFieldStyle())

                            Button(action: { showAnchorPicker = true }) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title3)
                                    .foregroundColor(.nebulaGold)
                                    .padding(12)
                                    .background(Color.cardBackground.opacity(0.8))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.nebulaGold.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    // Habits list
                    habitsSection

                    // Day selection
                    daySelectionSection

                    // Reminder time
                    inputSection(title: "Remind Me At", placeholder: "") {
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }

                    // Save button
                    saveButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAnchorPicker) {
            AnchorPickerSheet(timeBlock: timeBlock) { anchor in
                anchorHabit = anchor.name
            }
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.nebulaLavender.opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: timeBlock.icon)
                    .foregroundColor(timeBlock.color)
                    .shadow(color: timeBlock.color.opacity(0.5), radius: 4)
                Text("New \(timeBlock.rawValue) Stack")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Invisible balance
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.clear)
        }
    }
    
    // MARK: - Input Section
    func inputSection<Content: View>(
        title: String,
        subtitle: String? = nil,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.6))
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Day Selection Section
    var daySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Show On")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            Text("Choose which days this stack appears")
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.6))

            // Every day toggle
            HStack {
                Button(action: {
                    isEveryDay = true
                    selectedDays = Set(1...7)
                }) {
                    HStack {
                        Image(systemName: isEveryDay ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isEveryDay ? timeBlock.color : .nebulaLavender.opacity(0.4))
                        Text("Every Day")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isEveryDay ? timeBlock.color.opacity(0.2) : Color.cardBackground.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isEveryDay ? timeBlock.color.opacity(0.5) : Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                            )
                    )
                }

                Button(action: {
                    isEveryDay = false
                }) {
                    HStack {
                        Image(systemName: !isEveryDay ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!isEveryDay ? timeBlock.color : .nebulaLavender.opacity(0.4))
                        Text("Specific Days")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!isEveryDay ? timeBlock.color.opacity(0.2) : Color.cardBackground.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(!isEveryDay ? timeBlock.color.opacity(0.5) : Color.nebulaLavender.opacity(0.1), lineWidth: 1)
                            )
                    )
                }

                Spacer()
            }

            // Day buttons (only show when specific days selected)
            if !isEveryDay {
                HStack(spacing: 8) {
                    ForEach(WeekdayHelper.displayOrder, id: \.self) { day in
                        dayButton(for: day)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Day Button
    func dayButton(for day: Int) -> some View {
        let isSelected = selectedDays.contains(day)
        return Button(action: {
            if isSelected {
                // Don't allow deselecting all days
                if selectedDays.count > 1 {
                    selectedDays.remove(day)
                }
            } else {
                selectedDays.insert(day)
            }
        }) {
            Text(WeekdayHelper.letter(for: day))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .nebulaLavender.opacity(0.6))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? timeBlock.color : Color.cardBackground.opacity(0.7))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? timeBlock.color.opacity(0.8) : Color.nebulaLavender.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isSelected ? timeBlock.color.opacity(0.4) : .clear, radius: 4)
        }
    }

    // MARK: - Habits Section
    var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Your Habits")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            Text("Add habits to do after your anchor habit")
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.6))

            // Existing habits with reorder buttons
            ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                habitRow(habit: habit, index: index)
            }

            // Add new habit
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 40, height: 40)

                    Image(systemName: newHabitName.isEmpty ? "plus" : detectIcon(for: newHabitName))
                        .foregroundColor(newHabitName.isEmpty ? .nebulaLavender.opacity(0.4) : timeBlock.color)
                }

                TextField("Add a habit...", text: $newHabitName)
                    .textFieldStyle(CosmicTextFieldStyle())
                    .onSubmit {
                        addHabit()
                    }

                Button(action: addHabit) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(newHabitName.isEmpty ? .nebulaLavender.opacity(0.3) : timeBlock.color)
                        .shadow(color: newHabitName.isEmpty ? .clear : timeBlock.color.opacity(0.5), radius: 4)
                }
                .disabled(newHabitName.isEmpty)
            }

            // Suggested habits section (only in guided mode or for morning)
            if isGuidedMode || timeBlock == .morning {
                suggestedHabitsSection
            }
        }
    }

    // MARK: - Suggested Habits Section
    var suggestedHabitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .background(Color.nebulaLavender.opacity(0.2))
                .padding(.vertical, 8)

            Text("Suggested Habits")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            Text("Tap to add popular morning habits")
                .font(.caption)
                .foregroundColor(.nebulaLavender.opacity(0.6))

            // Grid of suggested habits
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(suggestedMorningHabits) { suggestion in
                    // Only show if not already added
                    if !habits.contains(where: { $0.name.lowercased() == suggestion.name.lowercased() }) {
                        Button(action: {
                            addSuggestedHabit(suggestion)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: suggestion.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(timeBlock.color)

                                Text(suggestion.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Spacer()

                                Image(systemName: "plus.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(timeBlock.color.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.cardBackground.opacity(0.7))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(timeBlock.color.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Habit Row
    func habitRow(habit: Habit, index: Int) -> some View {
        HStack(spacing: 10) {
            // Reorder buttons
            VStack(spacing: 4) {
                Button(action: { moveHabitUp(at: index) }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(index > 0 ? timeBlock.color : .nebulaLavender.opacity(0.2))
                }
                .disabled(index == 0)

                Button(action: { moveHabitDown(at: index) }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(index < habits.count - 1 ? timeBlock.color : .nebulaLavender.opacity(0.2))
                }
                .disabled(index >= habits.count - 1)
            }
            .frame(width: 24)

            ZStack {
                Circle()
                    .fill(timeBlock.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Circle()
                    .stroke(timeBlock.color.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)

                Image(systemName: habit.icon)
                    .foregroundColor(timeBlock.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .foregroundColor(.white)
                Text("Step \(index + 1)")
                    .font(.caption2)
                    .foregroundColor(.nebulaLavender.opacity(0.5))
            }

            Spacer()

            Button(action: { removeHabit(at: index) }) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(.nebulaLavender.opacity(0.4))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(timeBlock.color.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        Button(action: saveStack) {
            Text("Create Stack")
                .font(.headline)
                .foregroundColor(canSave ? .white : .nebulaLavender.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canSave ? timeBlock.color : Color.white.opacity(0.05))
                )
                .shadow(color: canSave ? timeBlock.color.opacity(0.4) : .clear, radius: 8)
        }
        .disabled(!canSave)
        .padding(.top, 12)
    }
    
    // MARK: - Actions
    func addHabit() {
        guard !newHabitName.isEmpty else { return }
        let habit = Habit(
            name: newHabitName,
            icon: detectIcon(for: newHabitName),
            order: habits.count
        )
        withAnimation(.easeInOut(duration: 0.2)) {
            habits.append(habit)
        }
        newHabitName = ""
        HapticManager.shared.lightTap()
    }

    func addSuggestedHabit(_ suggestion: SuggestedHabit) {
        let habit = Habit(
            name: suggestion.name,
            icon: suggestion.icon,
            order: habits.count
        )
        withAnimation(.easeInOut(duration: 0.2)) {
            habits.append(habit)
        }
        HapticManager.shared.lightTap()
    }

    func removeHabit(at index: Int) {
        _ = withAnimation(.easeInOut(duration: 0.2)) {
            habits.remove(at: index)
        }
        // Update order for remaining habits
        for (i, _) in habits.enumerated() {
            habits[i].order = i
        }
    }

    func moveHabit(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        // Update order for all habits
        for (i, _) in habits.enumerated() {
            habits[i].order = i
        }
    }

    func moveHabitUp(at index: Int) {
        guard index > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            habits.swapAt(index, index - 1)
            // Update order for all habits
            for (i, _) in habits.enumerated() {
                habits[i].order = i
            }
        }
        HapticManager.shared.lightTap()
    }

    func moveHabitDown(at index: Int) {
        guard index < habits.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            habits.swapAt(index, index + 1)
            // Update order for all habits
            for (i, _) in habits.enumerated() {
                habits[i].order = i
            }
        }
        HapticManager.shared.lightTap()
    }
    
    func saveStack() {
        // Create anchor habit as the first habit in the stack
        // Use time block icon for anchor since it represents the time of day
        let anchorHabitItem = Habit(
            name: anchorHabit,
            icon: timeBlock.icon,
            order: 0
        )

        // Shift all other habits' order by 1
        var allHabits = [anchorHabitItem]
        for (index, habit) in habits.enumerated() {
            habit.order = index + 1
            allHabits.append(habit)
        }

        let stack = HabitStack(
            name: stackName,
            timeBlock: timeBlock,
            anchorHabit: anchorHabit,
            reminderTime: reminderTime,
            habits: allHabits,
            color: timeBlock.color,
            streak: 0,
            scheduledDays: selectedDays
        )
        onSave(stack)
        dismiss()
    }
}

// MARK: - Cosmic Text Field Style
struct CosmicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.cardBackground.opacity(0.7))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Preview
#Preview {
    CreateStackView(
        timeBlock: .morning,
        prefilledAnchor: "Waking Up",
        prefilledStackName: "Wake Up Routine",
        isGuidedMode: true
    ) { _ in }
}
