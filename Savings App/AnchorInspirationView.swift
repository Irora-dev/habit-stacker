//
//  AnchorInspirationView.swift
//  Habit Stacking App
//

import SwiftUI

// MARK: - Anchor Habit Template
struct AnchorTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let timeBlock: TimeBlock
}

// MARK: - Preset Anchor Habits
struct AnchorHabits {
    static let all: [AnchorTemplate] = [
        // Morning
        AnchorTemplate(name: "Waking Up", icon: "sunrise.fill", timeBlock: .morning),
        AnchorTemplate(name: "Brushing Teeth", icon: "mouth.fill", timeBlock: .morning),
        AnchorTemplate(name: "Morning Coffee", icon: "cup.and.saucer.fill", timeBlock: .morning),
        AnchorTemplate(name: "Shower", icon: "shower.fill", timeBlock: .morning),
        AnchorTemplate(name: "Getting Dressed", icon: "tshirt.fill", timeBlock: .morning),
        AnchorTemplate(name: "Breakfast", icon: "fork.knife", timeBlock: .morning),
        AnchorTemplate(name: "Checking Phone", icon: "iphone", timeBlock: .morning),
        AnchorTemplate(name: "Leaving Home", icon: "door.left.hand.open", timeBlock: .morning),

        // Midday
        AnchorTemplate(name: "Lunch Break", icon: "takeoutbag.and.cup.and.straw.fill", timeBlock: .midday),
        AnchorTemplate(name: "Afternoon Coffee", icon: "mug.fill", timeBlock: .midday),
        AnchorTemplate(name: "Work Meeting", icon: "person.3.fill", timeBlock: .midday),
        AnchorTemplate(name: "Checking Email", icon: "envelope.fill", timeBlock: .midday),
        AnchorTemplate(name: "Snack Time", icon: "carrot.fill", timeBlock: .midday),
        AnchorTemplate(name: "Walking Break", icon: "figure.walk", timeBlock: .midday),

        // Evening
        AnchorTemplate(name: "Getting Home", icon: "house.fill", timeBlock: .evening),
        AnchorTemplate(name: "Dinner", icon: "fork.knife.circle.fill", timeBlock: .evening),
        AnchorTemplate(name: "Watching TV", icon: "tv.fill", timeBlock: .evening),
        AnchorTemplate(name: "Family Time", icon: "figure.2.and.child.holdinghands", timeBlock: .evening),
        AnchorTemplate(name: "Evening Walk", icon: "figure.walk.circle.fill", timeBlock: .evening),
        AnchorTemplate(name: "Cooking", icon: "frying.pan.fill", timeBlock: .evening),

        // Night
        AnchorTemplate(name: "Brushing Teeth", icon: "mouth.fill", timeBlock: .night),
        AnchorTemplate(name: "Skincare Routine", icon: "face.smiling.fill", timeBlock: .night),
        AnchorTemplate(name: "Getting into Bed", icon: "bed.double.fill", timeBlock: .night),
        AnchorTemplate(name: "Reading", icon: "book.fill", timeBlock: .night),
        AnchorTemplate(name: "Charging Phone", icon: "battery.100.bolt", timeBlock: .night),
        AnchorTemplate(name: "Setting Alarm", icon: "alarm.fill", timeBlock: .night),
        AnchorTemplate(name: "Journaling", icon: "note.text", timeBlock: .night),
        AnchorTemplate(name: "Meditation", icon: "sparkles", timeBlock: .night),
    ]

    static func anchors(for timeBlock: TimeBlock) -> [AnchorTemplate] {
        all.filter { $0.timeBlock == timeBlock }
    }
}

// MARK: - Anchor Inspiration View
struct AnchorInspirationView: View {
    let onSelectAnchor: (AnchorTemplate) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    header

                    // Time block sections
                    ForEach(TimeBlock.allCases, id: \.self) { timeBlock in
                        timeBlockSection(timeBlock)
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding()
            }
        }
    }

    // MARK: - Header
    var header: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                }
                Spacer()
            }

            VStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.nebulaGold)
                    .shadow(color: .nebulaGold.opacity(0.5), radius: 10)

                Text("Anchor Habits")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Choose an existing habit to anchor your new stack to")
                    .font(.subheadline)
                    .foregroundColor(.nebulaLavender.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Time Block Section
    func timeBlockSection(_ timeBlock: TimeBlock) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: timeBlock.icon)
                    .foregroundColor(timeBlock.color)
                    .font(.title3)

                Text(timeBlock.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // Anchor habits grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AnchorHabits.anchors(for: timeBlock)) { anchor in
                    AnchorCard(anchor: anchor, timeBlock: timeBlock) {
                        onSelectAnchor(anchor)
                        dismiss()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(timeBlock.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Anchor Card
struct AnchorCard: View {
    let anchor: AnchorTemplate
    let timeBlock: TimeBlock
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.lightTap()
            onTap()
        }) {
            HStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(timeBlock.color.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: anchor.icon)
                        .font(.system(size: 14))
                        .foregroundColor(timeBlock.color)
                }

                // Name
                Text(anchor.name)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 4)

                // Plus icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(timeBlock.color.opacity(0.6))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cosmicDeep)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(timeBlock.color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Anchor Picker Sheet (for CreateStackView)
struct AnchorPickerSheet: View {
    let timeBlock: TimeBlock
    let onSelectAnchor: (AnchorTemplate) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.nebulaLavender.opacity(0.6))
                        }
                        Spacer()
                        Text("Choose Anchor")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }

                    // Current time block anchors
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: timeBlock.icon)
                                .foregroundColor(timeBlock.color)
                            Text("\(timeBlock.rawValue) Anchors")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }

                        ForEach(AnchorHabits.anchors(for: timeBlock)) { anchor in
                            AnchorPickerRow(anchor: anchor, timeBlock: timeBlock) {
                                onSelectAnchor(anchor)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground.opacity(0.5))
                    )

                    // Other time blocks (collapsed)
                    ForEach(TimeBlock.allCases.filter { $0 != timeBlock }, id: \.self) { otherBlock in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: otherBlock.icon)
                                    .foregroundColor(otherBlock.color.opacity(0.6))
                                Text("\(otherBlock.rawValue) Anchors")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.nebulaLavender.opacity(0.6))
                            }

                            ForEach(AnchorHabits.anchors(for: otherBlock)) { anchor in
                                AnchorPickerRow(anchor: anchor, timeBlock: otherBlock) {
                                    onSelectAnchor(anchor)
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground.opacity(0.3))
                        )
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding()
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Anchor Picker Row
struct AnchorPickerRow: View {
    let anchor: AnchorTemplate
    let timeBlock: TimeBlock
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.lightTap()
            onTap()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(timeBlock.color.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: anchor.icon)
                        .font(.system(size: 16))
                        .foregroundColor(timeBlock.color)
                }

                Text(anchor.name)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.4))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cosmicDeep)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AnchorInspirationView { anchor in
        print("Selected: \(anchor.name)")
    }
}
