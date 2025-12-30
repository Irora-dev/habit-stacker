//
//  HomeScreenView.swift
//  Habit Stacking App
//

import SwiftUI

struct DailyQuote {
    let text: String
    let author: String
}

struct HomeScreenView: View {
    @Binding var showMainApp: Bool
    @State private var animateCurrentWeek: Bool = false
    @State private var borderRotation: Double = 0

    private let currentWeek: Int = {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        return weekOfYear
    }()

    private static let dailyQuotes: [DailyQuote] = [
        DailyQuote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Will Durant"),
        DailyQuote(text: "Small daily improvements over time lead to stunning results.", author: "Robin Sharma"),
        DailyQuote(text: "Motivation is what gets you started. Habit is what keeps you going.", author: "Jim Ryun"),
        DailyQuote(text: "You'll never change your life until you change something you do daily.", author: "John C. Maxwell"),
        DailyQuote(text: "The secret of your future is hidden in your daily routine.", author: "Mike Murdock"),
        DailyQuote(text: "Habits are the compound interest of self-improvement.", author: "James Clear"),
        DailyQuote(text: "First we make our habits, then our habits make us.", author: "John Dryden"),
        DailyQuote(text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier"),
        DailyQuote(text: "The journey of a thousand miles begins with a single step.", author: "Lao Tzu"),
        DailyQuote(text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt"),
        DailyQuote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        DailyQuote(text: "Start where you are. Use what you have. Do what you can.", author: "Arthur Ashe"),
        DailyQuote(text: "A year from now you may wish you had started today.", author: "Karen Lamb"),
        DailyQuote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),
        DailyQuote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
        DailyQuote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        DailyQuote(text: "Fall seven times, stand up eight.", author: "Japanese Proverb"),
        DailyQuote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        DailyQuote(text: "What you do today can improve all your tomorrows.", author: "Ralph Marston"),
        DailyQuote(text: "Perseverance is not a long race; it is many short races one after the other.", author: "Walter Elliot"),
        DailyQuote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
        DailyQuote(text: "The man who moves a mountain begins by carrying away small stones.", author: "Confucius"),
        DailyQuote(text: "Whether you think you can or you think you can't, you're right.", author: "Henry Ford"),
        DailyQuote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        DailyQuote(text: "The mind is everything. What you think you become.", author: "Buddha"),
        DailyQuote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis"),
        DailyQuote(text: "What lies behind us and what lies before us are tiny matters compared to what lies within us.", author: "Ralph Waldo Emerson"),
        DailyQuote(text: "Discipline is the bridge between goals and accomplishment.", author: "Jim Rohn"),
        DailyQuote(text: "How we spend our days is, of course, how we spend our lives.", author: "Annie Dillard"),
        DailyQuote(text: "Each morning we are born again. What we do today is what matters most.", author: "Buddha")
    ]

    private var todaysQuote: DailyQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % Self.dailyQuotes.count
        return Self.dailyQuotes[index]
    }

    init(showMainApp: Binding<Bool>) {
        self._showMainApp = showMainApp
    }

    var body: some View {
        ZStack {
            // Cosmic background
            CosmicBackgroundView()

            VStack(spacing: 0) {
                // Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: .nebulaPurple.opacity(0.5), radius: 10)
                    .padding(.top, 30)
                    .padding(.bottom, 8)

                // Daily Quote
                VStack(spacing: 6) {
                    Text("\"\(todaysQuote.text)\"")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.nebulaLavender.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("— \(todaysQuote.author)")
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.5))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                // 52 Week Dots
                WeekDotsView(currentWeek: currentWeek, animateCurrentWeek: animateCurrentWeek)
                    .padding(.horizontal, 12)

                Spacer()

                // Enter App Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showMainApp = true
                    }
                }) {
                    Text("Enter App")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.nebulaLavender.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            .nebulaCyan,
                                            .nebulaPurple,
                                            .nebulaMagenta,
                                            .nebulaLavender,
                                            .nebulaCyan
                                        ],
                                        center: .center,
                                        angle: .degrees(borderRotation)
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .nebulaPurple.opacity(0.2), radius: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animateCurrentWeek = true
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
    }
}

// MARK: - Week Dots View
struct WeekDotsView: View {
    let currentWeek: Int
    let animateCurrentWeek: Bool

    private let columns = 8 // 8 columns x 7 rows = 56 (last 4 hidden)
    private let rows = 7

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let totalHeight = geometry.size.height
            let horizontalSpacing: CGFloat = 6
            let verticalSpacing: CGFloat = 10
            let totalHorizontalSpacing = horizontalSpacing * CGFloat(columns - 1)
            let totalVerticalSpacing = verticalSpacing * CGFloat(rows - 1)

            // Calculate dot size based on both width and height constraints
            let dotSizeFromWidth = (totalWidth - totalHorizontalSpacing) / CGFloat(columns)
            let dotSizeFromHeight = (totalHeight - totalVerticalSpacing) / CGFloat(rows)
            let dotSize = min(dotSizeFromWidth, dotSizeFromHeight) * 0.95

            VStack(spacing: verticalSpacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: horizontalSpacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            let weekNumber = row * columns + col + 1
                            if weekNumber <= 52 {
                                WeekDot(
                                    weekNumber: weekNumber,
                                    currentWeek: currentWeek,
                                    isAnimating: animateCurrentWeek,
                                    size: dotSize
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Individual Week Cell (Calendar Style)
struct WeekDot: View {
    let weekNumber: Int
    let currentWeek: Int
    let isAnimating: Bool
    let size: CGFloat

    private var dotState: DotState {
        if weekNumber == currentWeek {
            return .current
        } else if weekNumber < currentWeek {
            return .past
        } else {
            return .future
        }
    }

    enum DotState {
        case past, current, future
    }

    private var fontSize: CGFloat {
        size * 0.38
    }

    private var cornerRadius: CGFloat {
        size * 0.2
    }

    var body: some View {
        ZStack {
            switch dotState {
            case .past:
                // Completed week with X
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.nebulaPurple.opacity(0.15))
                    .frame(width: size, height: size)

                Image(systemName: "xmark")
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.nebulaPurple.opacity(0.6))

            case .current:
                // Glowing square for current week
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.nebulaCyan.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.nebulaCyan.opacity(0.7), lineWidth: 1.5)
                    )
                    .shadow(color: .nebulaCyan.opacity(isAnimating ? 0.35 : 0.2), radius: isAnimating ? 5 : 3)

                Text("\(weekNumber)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.nebulaCyan)

            case .future:
                // Subtle square with border for future weeks
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.nebulaLavender.opacity(0.04))
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.nebulaLavender.opacity(0.15), lineWidth: 1)
                    )

                Text("\(weekNumber)")
                    .font(.system(size: fontSize, weight: .medium, design: .rounded))
                    .foregroundColor(.nebulaLavender.opacity(0.25))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeScreenView(showMainApp: .constant(false))
}
