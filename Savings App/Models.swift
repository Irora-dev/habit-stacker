//
//  Models.swift
//  Habit Stacking App
//

import SwiftUI
import SwiftData

// MARK: - Habit Model
@Model
final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "circle.fill"
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var order: Int = 0

    @Relationship(inverse: \HabitStack.habits)
    var stack: HabitStack?

    init(name: String, icon: String, isCompleted: Bool = false, completedAt: Date? = nil, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.order = order
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
    var createdAt: Date = Date()
    // Stores scheduled days as comma-separated weekday numbers (1=Sun, 2=Mon, ..., 7=Sat)
    // Empty or "1,2,3,4,5,6,7" means every day
    var scheduledDaysRaw: String = "1,2,3,4,5,6,7"

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

    // Get scheduled days as a Set of weekday numbers
    var scheduledDays: Set<Int> {
        get {
            if scheduledDaysRaw.isEmpty {
                return Set(1...7) // Default to every day
            }
            let days = scheduledDaysRaw.split(separator: ",").compactMap { Int($0) }
            return Set(days)
        }
        set {
            scheduledDaysRaw = newValue.sorted().map { String($0) }.joined(separator: ",")
        }
    }

    // Check if this stack should show on the current day
    var shouldShowToday: Bool {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        return scheduledDays.contains(todayWeekday)
    }

    // Check if this stack is set to show every day
    var isEveryDay: Bool {
        scheduledDays.count == 7 || scheduledDaysRaw.isEmpty
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
}

// MARK: - Weekday Helpers
struct WeekdayHelper {
    // Weekday numbers (Calendar standard: 1=Sunday, 2=Monday, ..., 7=Saturday)
    static let allDays: Set<Int> = Set(1...7)
    static let weekdays: Set<Int> = Set(2...6) // Mon-Fri
    static let weekends: Set<Int> = [1, 7] // Sun, Sat

    // Get short name for weekday number
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

    // Get single letter for weekday number
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

    // Days in display order (Monday first)
    static let displayOrder: [Int] = [2, 3, 4, 5, 6, 7, 1] // Mon, Tue, Wed, Thu, Fri, Sat, Sun
}

// MARK: - Session Log Model (for tracking completed sessions)
@Model
final class SessionLog {
    var id: UUID = UUID()
    var stackId: UUID = UUID()
    var stackName: String = ""
    var completedAt: Date = Date()
    var totalDuration: Int = 0 // in seconds
    var comment: String = ""
    var habitsCompleted: Int = 0
    var habitsSkipped: Int = 0
    @Relationship(deleteRule: .cascade)
    var habitLogs: [HabitLog] = []

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

// MARK: - Habit Log Model (for tracking individual habit completion in a session)
@Model
final class HabitLog {
    var id: UUID = UUID()
    var habitName: String = ""
    var habitIcon: String = "circle.fill"
    var duration: Int = 0 // in seconds
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

    // Comprehensive word-to-icon mapping
    let iconMap: [String: String] = [
        // Morning & Wake Up
        "wake": "sunrise.fill",
        "alarm": "alarm.fill",
        "snooze": "bell.slash.fill",
        "sunrise": "sunrise.fill",
        "morning": "sun.horizon.fill",
        "early": "sunrise.fill",
        "dawn": "sun.horizon.fill",
        "rise": "arrow.up.circle.fill",
        "awake": "eye.fill",
        "stretch": "figure.flexibility",
        "yawn": "face.smiling",
        "curtains": "blinds.horizontal.open",
        "daylight": "sun.max.fill",
        "grogginess": "zzz",

        // Sleep & Night
        "sleep": "bed.double.fill",
        "bed": "bed.double.fill",
        "nap": "powersleep",
        "rest": "bed.double.fill",
        "dream": "moon.stars.fill",
        "pillow": "bed.double.fill",
        "blanket": "bed.double.fill",
        "pajamas": "tshirt.fill",
        "nighttime": "moon.fill",
        "evening": "sunset.fill",
        "midnight": "moon.stars.fill",
        "insomnia": "zzz",
        "slumber": "moon.zzz.fill",
        "doze": "zzz",
        "snore": "zzz",
        "relax": "figure.mind.and.body",
        "unwind": "wind",
        "tired": "battery.25",
        "drowsy": "zzz",
        "bedtime": "moon.fill",

        // Hygiene & Personal Care
        "shower": "shower.fill",
        "bath": "bathtub.fill",
        "teeth": "mouth.fill",
        "brush": "mouth.fill",
        "floss": "mouth.fill",
        "mouthwash": "drop.fill",
        "wash": "hands.sparkles.fill",
        "soap": "hands.sparkles.fill",
        "shampoo": "shower.fill",
        "conditioner": "shower.fill",
        "skincare": "face.smiling",
        "face": "face.smiling",
        "moisturize": "drop.fill",
        "lotion": "drop.fill",
        "sunscreen": "sun.max.fill",
        "deodorant": "figure.stand",
        "shave": "scissors",
        "razor": "scissors",
        "trim": "scissors",
        "haircut": "scissors",
        "comb": "comb.fill",
        "hairbrush": "comb.fill",
        "makeup": "paintbrush.fill",
        "cosmetics": "paintbrush.fill",
        "nails": "hand.raised.fill",
        "manicure": "hand.raised.fill",
        "pedicure": "figure.stand",
        "exfoliate": "sparkles",
        "cleanse": "drop.fill",
        "toner": "drop.fill",
        "serum": "drop.fill",
        "mask": "theatermasks.fill",
        "grooming": "scissors",
        "hygiene": "sparkles",
        "toilet": "toilet.fill",
        "bathroom": "toilet.fill",

        // Exercise & Fitness
        "exercise": "figure.run",
        "workout": "dumbbell.fill",
        "gym": "dumbbell.fill",
        "run": "figure.run",
        "running": "figure.run",
        "jog": "figure.run",
        "jogging": "figure.run",
        "walk": "figure.walk",
        "walking": "figure.walk",
        "hike": "figure.hiking",
        "hiking": "figure.hiking",
        "swim": "figure.pool.swim",
        "swimming": "figure.pool.swim",
        "bike": "bicycle",
        "cycling": "bicycle",
        "cycle": "bicycle",
        "lift": "dumbbell.fill",
        "weights": "dumbbell.fill",
        "strength": "dumbbell.fill",
        "cardio": "heart.fill",
        "aerobics": "figure.aerobics",
        "yoga": "figure.yoga",
        "pilates": "figure.pilates",
        "stretching": "figure.flexibility",
        "flexibility": "figure.flexibility",
        "warmup": "flame.fill",
        "cooldown": "snowflake",
        "squat": "figure.strengthtraining.functional",
        "pushup": "figure.strengthtraining.traditional",
        "pullup": "figure.strengthtraining.traditional",
        "plank": "figure.core.training",
        "crunch": "figure.core.training",
        "situp": "figure.core.training",
        "abs": "figure.core.training",
        "core": "figure.core.training",
        "lunge": "figure.strengthtraining.functional",
        "burpee": "figure.jumprope",
        "jumping": "figure.jumprope",
        "jumprope": "figure.jumprope",
        "boxing": "figure.boxing",
        "kickboxing": "figure.kickboxing",
        "martial": "figure.martial.arts",
        "karate": "figure.martial.arts",
        "taekwondo": "figure.martial.arts",
        "dance": "figure.dance",
        "dancing": "figure.dance",
        "zumba": "figure.dance",
        "barre": "figure.barre",
        "crossfit": "figure.cross.training",
        "hiit": "bolt.heart.fill",
        "interval": "timer",
        "treadmill": "figure.run",
        "elliptical": "figure.elliptical",
        "rowing": "figure.rower",
        "climb": "figure.climbing",
        "climbing": "figure.climbing",
        "boulder": "figure.climbing",
        "ski": "figure.skiing.downhill",
        "skiing": "figure.skiing.downhill",
        "snowboard": "figure.snowboarding",
        "skate": "figure.skating",
        "tennis": "figure.tennis",
        "golf": "figure.golf",
        "basketball": "figure.basketball",
        "soccer": "figure.soccer",
        "football": "figure.american.football",
        "baseball": "figure.baseball",
        "volleyball": "figure.volleyball",
        "hockey": "figure.hockey",
        "cricket": "figure.cricket",
        "rugby": "soccerball",
        "badminton": "figure.badminton",
        "racquet": "figure.racquetball",
        "squash": "figure.squash",
        "sports": "sportscourt.fill",
        "athlete": "figure.run",
        "fitness": "heart.fill",
        "train": "figure.strengthtraining.traditional",
        "training": "figure.strengthtraining.traditional",
        "reps": "repeat",
        "sets": "number",
        "recovery": "bandage.fill",
        "muscle": "dumbbell.fill",
        "endurance": "heart.fill",
        "stamina": "bolt.fill",
        "agility": "figure.run",
        "balance": "figure.mind.and.body",
        "posture": "figure.stand",

        // Mindfulness & Mental Health
        "meditate": "brain.head.profile",
        "meditation": "brain.head.profile",
        "breathe": "wind",
        "breathing": "wind",
        "breath": "wind",
        "inhale": "wind",
        "exhale": "wind",
        "mindful": "brain.head.profile",
        "mindfulness": "brain.head.profile",
        "calm": "leaf.fill",
        "peace": "leaf.fill",
        "quiet": "speaker.slash.fill",
        "silence": "speaker.slash.fill",
        "focus": "scope",
        "concentrate": "scope",
        "awareness": "eye.fill",
        "present": "clock.fill",
        "gratitude": "heart.fill",
        "grateful": "heart.fill",
        "thankful": "heart.fill",
        "appreciate": "heart.fill",
        "affirmation": "text.bubble.fill",
        "mantra": "text.bubble.fill",
        "visualize": "eye.fill",
        "visualization": "eye.fill",
        "intention": "target",
        "manifest": "sparkles",
        "reflect": "person.fill.questionmark",
        "reflection": "person.fill.questionmark",
        "therapy": "brain.head.profile",
        "therapist": "person.fill",
        "counseling": "person.2.fill",
        "mental": "brain.head.profile",
        "emotional": "heart.fill",
        "anxiety": "waveform.path",
        "stress": "bolt.fill",
        "destress": "leaf.fill",
        "worry": "cloud.fill",
        "depression": "cloud.rain.fill",
        "mood": "face.smiling",
        "emotion": "heart.fill",
        "feeling": "heart.fill",
        "self-care": "heart.circle.fill",
        "selfcare": "heart.circle.fill",
        "wellness": "sparkles",
        "wellbeing": "sparkles",
        "healing": "cross.fill",
        "grounding": "leaf.fill",
        "centering": "scope",
        "relaxation": "leaf.fill",

        // Food & Meals
        "breakfast": "cup.and.saucer.fill",
        "lunch": "fork.knife",
        "dinner": "fork.knife",
        "supper": "fork.knife",
        "brunch": "fork.knife",
        "eat": "fork.knife",
        "eating": "fork.knife",
        "meal": "fork.knife",
        "food": "fork.knife",
        "snack": "carrot.fill",
        "cook": "frying.pan.fill",
        "cooking": "frying.pan.fill",
        "bake": "oven.fill",
        "baking": "oven.fill",
        "prep": "fork.knife",
        "prepare": "fork.knife",
        "recipe": "book.fill",
        "kitchen": "frying.pan.fill",
        "grocery": "cart.fill",
        "groceries": "cart.fill",
        "shop": "cart.fill",
        "shopping": "bag.fill",
        "vegetables": "carrot.fill",
        "veggies": "carrot.fill",
        "fruit": "apple.logo",
        "salad": "leaf.fill",
        "protein": "fish.fill",
        "meat": "fish.fill",
        "fish": "fish.fill",
        "chicken": "bird.fill",
        "beef": "fork.knife",
        "pork": "fork.knife",
        "eggs": "oval.fill",
        "dairy": "cup.and.saucer.fill",
        "grains": "wheat.bundle.fill",
        "carbs": "birthday.cake.fill",
        "fats": "drop.fill",
        "nutrition": "heart.fill",
        "diet": "scalemass.fill",
        "calories": "flame.fill",
        "macros": "chart.bar.fill",
        "portion": "fork.knife",
        "fast": "clock.fill",
        "fasting": "clock.fill",
        "intermittent": "clock.fill",
        "chew": "mouth.fill",
        "digest": "stomach.fill",
        "guts": "stomach.fill",
        "probiotic": "pill.fill",
        "fiber": "leaf.fill",
        "organic": "leaf.fill",
        "healthy": "heart.fill",
        "clean": "sparkles",
        "whole": "circle.fill",
        "processed": "xmark.circle.fill",
        "sugar": "cube.fill",
        "salt": "shaker.fill",
        "spice": "flame.fill",
        "herb": "leaf.fill",
        "sauce": "drop.fill",
        "dessert": "birthday.cake.fill",
        "treat": "star.fill",
        "indulge": "heart.fill",

        // Drinks & Hydration
        "water": "drop.fill",
        "hydrate": "drop.fill",
        "hydration": "drop.fill",
        "drink": "cup.and.saucer.fill",
        "drinking": "cup.and.saucer.fill",
        "sip": "cup.and.saucer.fill",
        "coffee": "cup.and.saucer.fill",
        "tea": "cup.and.saucer.fill",
        "juice": "cup.and.saucer.fill",
        "smoothie": "cup.and.saucer.fill",
        "shake": "cup.and.saucer.fill",
        "milk": "cup.and.saucer.fill",
        "lemon": "leaf.fill",
        "herbal": "leaf.fill",
        "caffeine": "bolt.fill",
        "decaf": "cup.and.saucer.fill",
        "espresso": "cup.and.saucer.fill",
        "latte": "cup.and.saucer.fill",
        "matcha": "leaf.fill",
        "alcohol": "wineglass.fill",
        "wine": "wineglass.fill",
        "beer": "mug.fill",
        "cocktail": "wineglass.fill",
        "sober": "drop.fill",
        "sobriety": "checkmark.circle.fill",
        "bottle": "waterbottle.fill",
        "refill": "arrow.clockwise",
        "glasses": "drop.fill",
        "ounces": "drop.fill",
        "liters": "drop.fill",

        // Work & Productivity
        "work": "briefcase.fill",
        "working": "briefcase.fill",
        "job": "briefcase.fill",
        "office": "building.2.fill",
        "desk": "desktopcomputer",
        "computer": "desktopcomputer",
        "laptop": "laptopcomputer",
        "email": "envelope.fill",
        "emails": "envelope.fill",
        "inbox": "tray.fill",
        "meeting": "person.3.fill",
        "meetings": "person.3.fill",
        "call": "phone.fill",
        "calls": "phone.fill",
        "zoom": "video.fill",
        "conference": "person.3.fill",
        "presentation": "play.rectangle.fill",
        "project": "folder.fill",
        "task": "checklist",
        "tasks": "checklist",
        "todo": "checklist",
        "deadline": "clock.badge.exclamationmark.fill",
        "schedule": "calendar",
        "calendar": "calendar",
        "planner": "calendar",
        "plan": "calendar",
        "planning": "calendar",
        "organize": "folder.fill",
        "prioritize": "arrow.up.circle.fill",
        "delegate": "person.2.fill",
        "collaborate": "person.2.fill",
        "brainstorm": "lightbulb.fill",
        "idea": "lightbulb.fill",
        "creative": "paintbrush.fill",
        "review": "eye.fill",
        "report": "doc.text.fill",
        "document": "doc.fill",
        "file": "doc.fill",
        "files": "folder.fill",
        "folder": "folder.fill",
        "spreadsheet": "tablecells.fill",
        "data": "chart.bar.fill",
        "analysis": "chart.xyaxis.line",
        "research": "magnifyingglass",
        "write": "pencil",
        "writing": "pencil",
        "draft": "doc.text.fill",
        "edit": "pencil",
        "proofread": "eye.fill",
        "submit": "paperplane.fill",
        "send": "paperplane.fill",
        "reply": "arrowshape.turn.up.left.fill",
        "respond": "arrowshape.turn.up.left.fill",
        "follow-up": "arrow.right.circle.fill",
        "invoice": "doc.text.fill",
        "budget": "dollarsign.circle.fill",
        "expense": "creditcard.fill",
        "timesheet": "clock.fill",
        "clock-in": "clock.badge.checkmark.fill",
        "clock-out": "clock.badge.xmark.fill",
        "commute": "car.fill",
        "travel": "airplane",
        "network": "person.3.sequence.fill",
        "networking": "person.3.sequence.fill",
        "linkedin": "link",
        "update": "arrow.clockwise",
        "sync": "arrow.triangle.2.circlepath",
        "backup": "externaldrive.fill",
        "password": "key.fill",
        "security": "lock.fill",
        "login": "person.badge.key.fill",
        "logout": "rectangle.portrait.and.arrow.right.fill",
        "shutdown": "power",
        "restart": "arrow.clockwise",

        // Learning & Education
        "learn": "graduationcap.fill",
        "learning": "graduationcap.fill",
        "study": "book.fill",
        "studying": "book.fill",
        "read": "book.fill",
        "reading": "book.fill",
        "book": "book.fill",
        "books": "books.vertical.fill",
        "chapter": "bookmark.fill",
        "page": "doc.fill",
        "pages": "doc.on.doc.fill",
        "article": "newspaper.fill",
        "news": "newspaper.fill",
        "blog": "doc.richtext.fill",
        "podcast": "headphones",
        "audiobook": "headphones",
        "listen": "ear.fill",
        "course": "play.rectangle.fill",
        "class": "person.3.fill",
        "lecture": "person.fill",
        "lesson": "book.fill",
        "tutorial": "play.rectangle.fill",
        "video": "play.rectangle.fill",
        "youtube": "play.rectangle.fill",
        "watch": "eye.fill",
        "documentary": "film.fill",
        "education": "graduationcap.fill",
        "school": "building.columns.fill",
        "university": "building.columns.fill",
        "college": "building.columns.fill",
        "degree": "scroll.fill",
        "certificate": "rosette",
        "exam": "doc.text.fill",
        "test": "checkmark.circle.fill",
        "quiz": "questionmark.circle.fill",
        "homework": "pencil.and.outline",
        "assignment": "doc.text.fill",
        "essay": "doc.text.fill",
        "paper": "doc.fill",
        "thesis": "doc.text.fill",
        "notes": "note.text",
        "flashcard": "rectangle.on.rectangle",
        "memorize": "brain.head.profile",
        "memory": "brain.head.profile",
        "recall": "brain.head.profile",
        "practice": "repeat",
        "revise": "pencil",
        "language": "globe",
        "vocabulary": "textformat.abc",
        "grammar": "textformat",
        "duolingo": "globe",
        "skill": "star.fill",
        "skills": "star.fill",
        "knowledge": "lightbulb.fill",
        "wisdom": "lightbulb.fill",
        "curious": "questionmark.circle.fill",
        "curiosity": "questionmark.circle.fill",
        "discover": "sparkle.magnifyingglass",
        "explore": "safari.fill",

        // Health & Medical
        "health": "heart.fill",
        "doctor": "stethoscope",
        "appointment": "calendar.badge.clock",
        "checkup": "stethoscope",
        "dentist": "mouth.fill",
        "optometrist": "eye.fill",
        "physical": "figure.stand",
        "blood": "drop.fill",
        "pressure": "waveform.path.ecg",
        "heart": "heart.fill",
        "pulse": "waveform.path.ecg",
        "heartrate": "heart.fill",
        "weight": "scalemass.fill",
        "weigh": "scalemass.fill",
        "scale": "scalemass.fill",
        "bmi": "scalemass.fill",
        "measure": "ruler.fill",
        "height": "ruler.fill",
        "temperature": "thermometer",
        "fever": "thermometer",
        "symptoms": "list.clipboard.fill",
        "pain": "bandage.fill",
        "ache": "bandage.fill",
        "headache": "brain.head.profile",
        "migraine": "brain.head.profile",
        "medicine": "pill.fill",
        "medication": "pill.fill",
        "pill": "pill.fill",
        "pills": "pill.fill",
        "vitamin": "pill.fill",
        "vitamins": "pill.fill",
        "supplement": "pill.fill",
        "supplements": "pill.fill",
        "prescription": "doc.text.fill",
        "pharmacy": "cross.fill",
        "injection": "syringe.fill",
        "vaccine": "syringe.fill",
        "insulin": "syringe.fill",
        "inhaler": "lungs.fill",
        "allergy": "allergens.fill",
        "allergies": "allergens.fill",
        "asthma": "lungs.fill",
        "diabetes": "drop.fill",
        "glucose": "waveform.path",
        "cholesterol": "heart.fill",
        "eyedrops": "eye.fill",
        "contacts": "eye.fill",
        "hearing": "ear.fill",
        "ergonomic": "figure.stand",
        "chiropractic": "figure.stand",
        "massage": "hands.sparkles.fill",
        "acupuncture": "hand.point.up.fill",
        "physio": "figure.walk",
        "rehab": "figure.walk",
        "immune": "shield.fill",
        "immunity": "shield.fill",
        "antioxidant": "leaf.fill",
        "detox": "leaf.fill",
        "hormone": "waveform.path",
        "period": "calendar",
        "fertility": "heart.fill",
        "pregnant": "heart.fill",
        "prenatal": "pill.fill",

        // Social & Relationships
        "family": "figure.2.and.child.holdinghands",
        "friends": "person.2.fill",
        "friend": "person.fill",
        "partner": "heart.fill",
        "spouse": "heart.fill",
        "husband": "person.fill",
        "wife": "person.fill",
        "kids": "figure.2.and.child.holdinghands",
        "children": "figure.2.and.child.holdinghands",
        "baby": "figure.and.child.holdinghands",
        "parent": "figure.and.child.holdinghands",
        "mom": "figure.and.child.holdinghands",
        "dad": "figure.and.child.holdinghands",
        "grandparent": "person.fill",
        "sibling": "person.2.fill",
        "brother": "person.fill",
        "sister": "person.fill",
        "relative": "person.3.fill",
        "text": "message.fill",
        "message": "message.fill",
        "chat": "bubble.left.fill",
        "talk": "bubble.left.and.bubble.right.fill",
        "conversation": "bubble.left.and.bubble.right.fill",
        "visit": "house.fill",
        "hangout": "person.2.fill",
        "date": "heart.fill",
        "dating": "heart.fill",
        "relationship": "heart.fill",
        "romance": "heart.fill",
        "love": "heart.fill",
        "hug": "person.2.fill",
        "kiss": "heart.fill",
        "intimacy": "heart.fill",
        "connect": "link",
        "connection": "person.line.dotted.person.fill",
        "bond": "link",
        "support": "hand.raised.fill",
        "help": "hand.raised.fill",
        "empathy": "heart.fill",
        "compassion": "heart.fill",
        "kindness": "heart.fill",
        "compliment": "star.fill",
        "appreciation": "heart.fill",
        "forgive": "heart.fill",
        "apologize": "text.bubble.fill",
        "communicate": "bubble.left.and.bubble.right.fill",
        "boundaries": "shield.fill",
        "social": "person.3.fill",
        "community": "person.3.fill",
        "volunteer": "hand.raised.fill",
        "donate": "gift.fill",
        "charity": "heart.fill",
        "give": "gift.fill",
        "gift": "gift.fill",

        // Household & Chores
        "cleaning": "sparkles",
        "tidy": "sparkles",
        "declutter": "trash.fill",
        "dust": "sparkles",
        "vacuum": "sparkles",
        "mop": "drop.fill",
        "sweep": "sparkles",
        "scrub": "sparkles",
        "wipe": "sparkles",
        "sanitize": "sparkles",
        "disinfect": "sparkles",
        "laundry": "washer.fill",
        "dry": "dryer.fill",
        "fold": "rectangle.split.3x1.fill",
        "iron": "flame.fill",
        "dishes": "cup.and.saucer.fill",
        "dishwasher": "dishwasher.fill",
        "trash": "trash.fill",
        "garbage": "trash.fill",
        "recycling": "arrow.3.trianglepath",
        "compost": "leaf.fill",
        "sheets": "bed.double.fill",
        "pillows": "bed.double.fill",
        "towels": "rectangle.fill",
        "floor": "square.fill",
        "window": "window.horizontal",
        "mirror": "rectangle.fill",
        "garage": "car.fill",
        "yard": "leaf.fill",
        "garden": "leaf.fill",
        "lawn": "leaf.fill",
        "mow": "leaf.fill",
        "rake": "leaf.fill",
        "weed": "leaf.fill",
        "plant": "leaf.fill",
        "plants": "leaf.fill",
        "prune": "scissors",
        "harvest": "carrot.fill",
        "pets": "pawprint.fill",
        "dog": "dog.fill",
        "cat": "cat.fill",
        "bird": "bird.fill",
        "feed": "fork.knife",
        "litter": "trash.fill",
        "groom": "scissors",
        "vet": "cross.fill",
        "repair": "wrench.fill",
        "fix": "wrench.fill",
        "maintain": "wrench.fill",
        "maintenance": "wrench.fill",
        "bills": "dollarsign.circle.fill",
        "mail": "envelope.fill",
        "packages": "shippingbox.fill",
        "errands": "car.fill",

        // Finance & Money
        "budgeting": "dollarsign.circle.fill",
        "save": "banknote.fill",
        "saving": "banknote.fill",
        "savings": "banknote.fill",
        "invest": "chart.line.uptrend.xyaxis",
        "investing": "chart.line.uptrend.xyaxis",
        "investment": "chart.line.uptrend.xyaxis",
        "stocks": "chart.line.uptrend.xyaxis",
        "crypto": "bitcoinsign.circle.fill",
        "retirement": "building.columns.fill",
        "401k": "building.columns.fill",
        "ira": "building.columns.fill",
        "pension": "building.columns.fill",
        "bank": "building.columns.fill",
        "banking": "building.columns.fill",
        "account": "creditcard.fill",
        "checking": "creditcard.fill",
        "transfer": "arrow.left.arrow.right",
        "deposit": "arrow.down.to.line",
        "withdraw": "arrow.up.to.line",
        "atm": "banknote.fill",
        "cash": "banknote.fill",
        "spend": "creditcard.fill",
        "spending": "creditcard.fill",
        "expenses": "creditcard.fill",
        "track": "chart.bar.fill",
        "receipt": "doc.text.fill",
        "tax": "doc.text.fill",
        "taxes": "doc.text.fill",
        "income": "arrow.down.circle.fill",
        "salary": "banknote.fill",
        "paycheck": "banknote.fill",
        "debt": "creditcard.fill",
        "loan": "banknote.fill",
        "mortgage": "house.fill",
        "credit": "creditcard.fill",
        "creditcard": "creditcard.fill",
        "payment": "creditcard.fill",
        "bill": "doc.text.fill",
        "insurance": "shield.fill",
        "financial": "dollarsign.circle.fill",
        "money": "dollarsign.circle.fill",

        // Digital & Screen Time
        "phone": "iphone",
        "smartphone": "iphone",
        "screen": "rectangle.fill",
        "screentime": "clock.fill",
        "instagram": "camera.fill",
        "facebook": "person.2.fill",
        "twitter": "bird.fill",
        "tiktok": "play.rectangle.fill",
        "snapchat": "camera.fill",
        "reddit": "text.bubble.fill",
        "netflix": "tv.fill",
        "streaming": "play.rectangle.fill",
        "tv": "tv.fill",
        "television": "tv.fill",
        "gaming": "gamecontroller.fill",
        "games": "gamecontroller.fill",
        "videogames": "gamecontroller.fill",
        "app": "app.fill",
        "apps": "square.grid.2x2.fill",
        "notification": "bell.fill",
        "notifications": "bell.fill",
        "digital": "iphone",
        "unplug": "powerplug.fill",
        "offline": "wifi.slash",
        "airplane": "airplane",
        "limit": "hand.raised.fill",
        "block": "xmark.circle.fill",
        "delete": "trash.fill",
        "unsubscribe": "xmark.circle.fill",
        "unfollow": "person.badge.minus.fill",
        "mute": "speaker.slash.fill",
        "charge": "battery.100.bolt",
        "battery": "battery.100",

        // Creative & Hobbies
        "art": "paintpalette.fill",
        "draw": "pencil.tip",
        "drawing": "pencil.tip",
        "sketch": "pencil",
        "paint": "paintbrush.fill",
        "painting": "paintbrush.fill",
        "color": "paintpalette.fill",
        "design": "paintbrush.fill",
        "craft": "scissors",
        "crafts": "scissors",
        "diy": "hammer.fill",
        "sew": "scissors",
        "sewing": "scissors",
        "knit": "scissors",
        "knitting": "scissors",
        "crochet": "scissors",
        "embroider": "scissors",
        "pottery": "circle.fill",
        "sculpt": "hammer.fill",
        "woodwork": "hammer.fill",
        "build": "hammer.fill",
        "create": "sparkles",
        "music": "music.note",
        "instrument": "pianokeys",
        "piano": "pianokeys",
        "guitar": "guitars.fill",
        "drums": "music.note",
        "sing": "music.mic",
        "singing": "music.mic",
        "compose": "music.note.list",
        "song": "music.note",
        "playlist": "music.note.list",
        "photo": "camera.fill",
        "photography": "camera.fill",
        "camera": "camera.fill",
        "film": "film.fill",
        "journal": "book.fill",
        "journaling": "book.fill",
        "diary": "book.fill",
        "poetry": "doc.text.fill",
        "story": "book.fill",
        "novel": "book.fill",
        "fiction": "book.fill",
        "script": "doc.text.fill",
        "game": "gamecontroller.fill",
        "puzzle": "puzzlepiece.fill",
        "chess": "checkerboard.rectangle",
        "cards": "rectangle.on.rectangle",
        "collect": "tray.full.fill",
        "collection": "tray.full.fill",
        "hobby": "star.fill",
        "gardening": "leaf.fill",
        "brew": "mug.fill",

        // Spiritual & Religious
        "pray": "hands.sparkles.fill",
        "prayer": "hands.sparkles.fill",
        "church": "building.columns.fill",
        "temple": "building.columns.fill",
        "mosque": "building.columns.fill",
        "synagogue": "building.columns.fill",
        "worship": "hands.sparkles.fill",
        "faith": "sparkles",
        "spiritual": "sparkles",
        "religion": "book.fill",
        "bible": "book.fill",
        "quran": "book.fill",
        "torah": "book.fill",
        "scripture": "book.fill",
        "devotion": "heart.fill",
        "devotional": "book.fill",
        "sermon": "person.fill",
        "mass": "person.3.fill",
        "service": "person.3.fill",
        "hymn": "music.note",
        "chant": "music.note",
        "rosary": "circle.fill",
        "blessing": "sparkles",
        "grace": "sparkles",
        "tithe": "dollarsign.circle.fill",
        "offering": "gift.fill",
        "sabbath": "calendar",
        "holy": "sparkles",
        "sacred": "sparkles",
        "soul": "sparkles",
        "spirit": "wind",
        "enlighten": "lightbulb.fill",
        "enlightenment": "sun.max.fill",
        "chakra": "circle.fill",
        "energy": "bolt.fill",
        "aura": "sparkles",
        "karma": "arrow.triangle.2.circlepath",

        // Outdoor & Nature
        "outside": "sun.max.fill",
        "outdoor": "sun.max.fill",
        "nature": "leaf.fill",
        "sunshine": "sun.max.fill",
        "sunlight": "sun.max.fill",
        "park": "tree.fill",
        "forest": "tree.fill",
        "woods": "tree.fill",
        "trail": "figure.hiking",
        "beach": "beach.umbrella.fill",
        "ocean": "water.waves",
        "lake": "water.waves",
        "river": "water.waves",
        "mountain": "mountain.2.fill",
        "camp": "tent.fill",
        "camping": "tent.fill",
        "fishing": "fish.fill",
        "hunt": "scope",
        "sunset": "sunset.fill",
        "picnic": "basket.fill",
        "bonfire": "flame.fill",
        "kayak": "figure.water.fitness",
        "canoe": "figure.water.fitness",
        "surf": "figure.surfing",
        "sail": "sailboat.fill",
        "boat": "ferry.fill",

        // Travel & Transport
        "trip": "airplane",
        "vacation": "beach.umbrella.fill",
        "holiday": "gift.fill",
        "flight": "airplane",
        "fly": "airplane",
        "airport": "airplane",
        "hotel": "building.2.fill",
        "pack": "suitcase.fill",
        "packing": "suitcase.fill",
        "suitcase": "suitcase.fill",
        "passport": "person.text.rectangle.fill",
        "visa": "doc.text.fill",
        "drive": "car.fill",
        "driving": "car.fill",
        "car": "car.fill",
        "bus": "bus.fill",
        "subway": "tram.fill",
        "metro": "tram.fill",
        "taxi": "car.fill",
        "uber": "car.fill",
        "lyft": "car.fill",
        "scooter": "scooter",
        "carpool": "car.2.fill",
        "gas": "fuelpump.fill",
        "fuel": "fuelpump.fill",
        "parking": "p.square.fill",
        "traffic": "car.fill",
        "navigation": "location.fill",
        "gps": "location.fill",
        "map": "map.fill",
        "directions": "arrow.triangle.turn.up.right.diamond.fill",

        // Clothing & Appearance
        "dress": "tshirt.fill",
        "clothes": "tshirt.fill",
        "outfit": "tshirt.fill",
        "wardrobe": "cabinet.fill",
        "closet": "cabinet.fill",
        "shoes": "shoe.fill",
        "accessories": "sparkles",
        "jewelry": "sparkles",
        "sunglasses": "sunglasses.fill",
        "hat": "crown.fill",
        "coat": "tshirt.fill",
        "jacket": "tshirt.fill",
        "uniform": "tshirt.fill",
        "style": "sparkles",
        "fashion": "sparkles",
        "appearance": "person.fill",

        // Events & Time
        "afternoon": "sun.max.fill",
        "daily": "calendar",
        "weekly": "calendar",
        "monthly": "calendar",
        "yearly": "calendar",
        "birthday": "gift.fill",
        "anniversary": "heart.fill",
        "event": "calendar.badge.plus",
        "reminder": "bell.fill",
        "timer": "timer",
        "countdown": "clock.fill",
        "routine": "repeat",
        "ritual": "sparkles",
        "habit": "checkmark.circle.fill",
        "streak": "flame.fill",
        "goal": "target",
        "milestone": "flag.fill",
        "achievement": "trophy.fill",
        "progress": "chart.bar.fill",
        "log": "doc.text.fill",
        "record": "doc.text.fill",
        "check": "checkmark.circle.fill",
        "complete": "checkmark.circle.fill",
        "finish": "flag.checkered",
        "start": "play.fill",
        "begin": "play.fill",
        "end": "stop.fill",
        "pause": "pause.fill",
        "break": "cup.and.saucer.fill",

        // Miscellaneous Actions
        "smile": "face.smiling",
        "laugh": "face.smiling",
        "cry": "drop.fill",
        "stand": "figure.stand",
        "sit": "figure.seated.seatbelt",
        "jump": "figure.jumprope",
        "speak": "waveform",
        "look": "eye.fill",
        "touch": "hand.point.up.left.fill",
        "feel": "heart.fill",
        "think": "brain.head.profile",
        "remember": "brain.head.profile",
        "forget": "brain.head.profile",
        "decide": "checkmark.circle.fill",
        "choose": "hand.tap.fill",
        "try": "star.fill",
        "fail": "xmark.circle.fill",
        "succeed": "checkmark.circle.fill",
        "win": "trophy.fill",
        "lose": "xmark.circle.fill",
        "take": "hand.point.right.fill",
        "share": "square.and.arrow.up.fill",
        "receive": "tray.and.arrow.down.fill",
        "open": "envelope.open.fill",
        "close": "xmark",
        "stop": "stop.fill",
        "continue": "arrow.right",
        "wait": "hourglass",
        "rush": "bolt.fill",
        "slow": "tortoise.fill",
        "repeat": "repeat",
        "skip": "forward.fill",
        "change": "arrow.triangle.2.circlepath",
        "improve": "arrow.up.right",
        "grow": "leaf.fill",
        "teach": "person.fill",
        "lead": "person.fill",
        "follow": "person.fill",
        "inspire": "lightbulb.fill",
        "motivate": "flame.fill",
        "encourage": "hand.thumbsup.fill",
        "celebrate": "party.popper.fill",
        "reward": "gift.fill",
        "punish": "xmark.circle.fill",
        "accept": "checkmark.circle.fill",
        "reject": "xmark.circle.fill",
        "ignore": "eye.slash.fill",
        "notice": "eye.fill",
        "avoid": "arrow.uturn.left",
        "approach": "arrow.right",
        "escape": "door.right.hand.open",
        "enter": "door.left.hand.open",
        "leave": "door.right.hand.open",
        "arrive": "location.fill",
        "depart": "airplane.departure",
        "return": "arrow.uturn.backward",
        "stay": "house.fill",
        "move": "arrow.right",
        "carry": "shippingbox.fill",
        "drop": "arrow.down",
        "throw": "figure.throw",
        "catch": "hand.raised.fill",
        "push": "arrow.right.to.line",
        "pull": "arrow.left.to.line",
        "turn": "arrow.turn.right.up",
        "twist": "arrow.triangle.2.circlepath",
        "pour": "drop.fill",
        "mix": "arrow.triangle.2.circlepath",
        "cut": "scissors",
        "paste": "doc.on.clipboard.fill",
        "copy": "doc.on.doc.fill",
        "print": "printer.fill",
        "scan": "doc.viewfinder.fill",
        "search": "magnifyingglass",
        "find": "magnifyingglass",
        "navigate": "location.fill",
        "guide": "signpost.right.fill",
        "direct": "arrow.right",
        "point": "hand.point.right.fill",
        "show": "eye.fill",
        "hide": "eye.slash.fill",
        "reveal": "eye.fill",
        "cover": "rectangle.fill",
        "protect": "shield.fill",
        "secure": "lock.fill",
        "lock": "lock.fill",
        "unlock": "lock.open.fill",
        "download": "arrow.down.circle.fill",
        "upload": "arrow.up.circle.fill",
        "install": "arrow.down.app.fill",
        "remove": "minus.circle.fill",
        "add": "plus.circle.fill",
        "make": "wrench.fill",
        "destroy": "trash.fill",
        "dirty": "xmark.circle.fill",
        "sort": "arrow.up.arrow.down",
        "filter": "line.3.horizontal.decrease",
        "arrange": "square.grid.2x2.fill",
        "stack": "square.stack.fill",
        "group": "rectangle.3.group.fill",
        "separate": "arrow.left.and.right",
        "combine": "arrow.triangle.merge",
        "merge": "arrow.triangle.merge",
        "split": "arrow.triangle.branch",
        "divide": "divide",
        "multiply": "multiply",
        "count": "number",
        "compare": "arrow.left.and.right.righttriangle.left.righttriangle.right.fill",
        "verify": "checkmark.seal.fill",
        "confirm": "checkmark.circle.fill",
        "approve": "hand.thumbsup.fill",
        "deny": "hand.thumbsdown.fill",
        "allow": "checkmark.circle.fill",
        "enable": "checkmark.circle.fill",
        "disable": "xmark.circle.fill",
        "activate": "bolt.fill",
        "deactivate": "bolt.slash.fill"
    ]

    // Check for exact word matches first
    let words = name.components(separatedBy: CharacterSet.alphanumerics.inverted)
    for word in words {
        if let icon = iconMap[word] {
            return icon
        }
    }

    // Check for partial matches (word contained in habit name)
    for (keyword, icon) in iconMap {
        if name.contains(keyword) {
            return icon
        }
    }

    return "circle.fill"
}

