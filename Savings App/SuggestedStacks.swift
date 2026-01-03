//
//  SuggestedStacks.swift
//  Habit Stacking App
//

import SwiftUI

// MARK: - Suggested Stack Model

struct SuggestedStack: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let timeBlock: TimeBlock
    let anchorHabit: String
    let habits: [String] // Habit names - icons will be auto-detected
    let category: StackCategory

    enum StackCategory: String, CaseIterable {
        case wellness = "Wellness"
        case fitness = "Fitness"
        case productivity = "Productivity"
        case mindfulness = "Mindfulness"
        case selfCare = "Self Care"
        case health = "Health"
        case learning = "Learning"
        case social = "Social"
        case creative = "Creative"
        case finance = "Finance"
    }
}

// MARK: - Pre-built Stacks Data

struct SuggestedStacksData {

    static let allStacks: [SuggestedStack] = [
        // ============================================
        // MORNING STACKS (7am - 11am)
        // ============================================

        // Mindfulness & Meditation
        SuggestedStack(
            name: "Morning Meditation",
            icon: "brain.head.profile",
            timeBlock: .morning,
            anchorHabit: "Wake up",
            habits: ["Drink water", "Stretch for 5 minutes", "Meditate for 10 minutes", "Set daily intention"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Gratitude Morning",
            icon: "heart.fill",
            timeBlock: .morning,
            anchorHabit: "Wake up",
            habits: ["Write 3 gratitudes", "Affirmations", "Visualize successful day", "Smile in mirror"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Mindful Start",
            icon: "leaf.fill",
            timeBlock: .morning,
            anchorHabit: "Open eyes",
            habits: ["Take 5 deep breaths", "Body scan meditation", "Set intention", "Gentle stretch"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Breathwork Morning",
            icon: "wind",
            timeBlock: .morning,
            anchorHabit: "Sit up in bed",
            habits: ["Box breathing 4 rounds", "Stretch arms", "Hydrate", "Journal one page"],
            category: .mindfulness
        ),

        // Skincare & Self Care
        SuggestedStack(
            name: "Morning Skincare",
            icon: "sparkles",
            timeBlock: .morning,
            anchorHabit: "Wash face",
            habits: ["Apply toner", "Apply serum", "Moisturizer", "Sunscreen SPF"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Full Morning Routine",
            icon: "face.smiling",
            timeBlock: .morning,
            anchorHabit: "Shower",
            habits: ["Skincare routine", "Brush teeth", "Floss", "Style hair", "Get dressed"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Quick Freshen Up",
            icon: "drop.fill",
            timeBlock: .morning,
            anchorHabit: "Get out of bed",
            habits: ["Splash face with water", "Brush teeth", "Deodorant", "Comb hair"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Grooming Routine",
            icon: "scissors",
            timeBlock: .morning,
            anchorHabit: "After shower",
            habits: ["Shave or trim", "Apply aftershave", "Style hair", "Check outfit"],
            category: .selfCare
        ),

        // Fitness
        SuggestedStack(
            name: "Morning Workout",
            icon: "figure.run",
            timeBlock: .morning,
            anchorHabit: "Put on workout clothes",
            habits: ["Dynamic warmup", "30 min exercise", "Cool down stretch", "Protein shake"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Sunrise Run",
            icon: "figure.run",
            timeBlock: .morning,
            anchorHabit: "Lace up shoes",
            habits: ["5 min warmup walk", "20-30 min run", "Cool down walk", "Stretch"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Home HIIT",
            icon: "bolt.heart.fill",
            timeBlock: .morning,
            anchorHabit: "Roll out yoga mat",
            habits: ["Jumping jacks warmup", "20 min HIIT", "Core work", "Stretch and breathe"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Morning Yoga Flow",
            icon: "figure.yoga",
            timeBlock: .morning,
            anchorHabit: "Unroll yoga mat",
            habits: ["Sun salutations", "Standing poses", "Floor poses", "Savasana"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Strength Training AM",
            icon: "dumbbell.fill",
            timeBlock: .morning,
            anchorHabit: "Enter gym",
            habits: ["Warmup 5 min", "Compound lifts", "Accessory work", "Stretch"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Quick Morning Stretch",
            icon: "figure.flexibility",
            timeBlock: .morning,
            anchorHabit: "Get out of bed",
            habits: ["Neck rolls", "Shoulder stretch", "Forward fold", "Cat-cow stretch"],
            category: .fitness
        ),

        // Productivity
        SuggestedStack(
            name: "Productive Morning",
            icon: "checkmark.circle.fill",
            timeBlock: .morning,
            anchorHabit: "Sit at desk",
            habits: ["Review calendar", "Set 3 priorities", "Clear inbox to zero", "Start deep work"],
            category: .productivity
        ),
        SuggestedStack(
            name: "CEO Morning",
            icon: "briefcase.fill",
            timeBlock: .morning,
            anchorHabit: "Coffee ready",
            habits: ["Review goals", "Check key metrics", "Plan top 3 tasks", "Block focus time"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Creative Morning",
            icon: "paintbrush.fill",
            timeBlock: .morning,
            anchorHabit: "Open notebook",
            habits: ["Morning pages journaling", "Brainstorm ideas", "Sketch or doodle", "Plan creative project"],
            category: .creative
        ),
        SuggestedStack(
            name: "Student Morning",
            icon: "book.fill",
            timeBlock: .morning,
            anchorHabit: "Open laptop",
            habits: ["Review class schedule", "Check assignments", "30 min study session", "Prepare materials"],
            category: .learning
        ),

        // Health & Nutrition
        SuggestedStack(
            name: "Healthy Breakfast",
            icon: "fork.knife",
            timeBlock: .morning,
            anchorHabit: "Enter kitchen",
            habits: ["Drink lemon water", "Prepare healthy breakfast", "Take vitamins", "Eat mindfully"],
            category: .health
        ),
        SuggestedStack(
            name: "Supplement Stack",
            icon: "pill.fill",
            timeBlock: .morning,
            anchorHabit: "After breakfast",
            habits: ["Multivitamin", "Omega-3", "Vitamin D", "Probiotic"],
            category: .health
        ),
        SuggestedStack(
            name: "Hydration Start",
            icon: "drop.fill",
            timeBlock: .morning,
            anchorHabit: "Wake up",
            habits: ["Drink full glass water", "Add electrolytes", "Prepare water bottle", "Set hydration reminder"],
            category: .health
        ),

        // Learning
        SuggestedStack(
            name: "Morning Learning",
            icon: "graduationcap.fill",
            timeBlock: .morning,
            anchorHabit: "Coffee in hand",
            habits: ["Read for 20 minutes", "Take notes", "Review flashcards", "Listen to podcast"],
            category: .learning
        ),
        SuggestedStack(
            name: "Language Learning AM",
            icon: "globe",
            timeBlock: .morning,
            anchorHabit: "Breakfast ready",
            habits: ["Duolingo lesson", "Vocabulary review", "Listen to foreign podcast", "Practice speaking"],
            category: .learning
        ),
        SuggestedStack(
            name: "News & Knowledge",
            icon: "newspaper.fill",
            timeBlock: .morning,
            anchorHabit: "Sit down with coffee",
            habits: ["Read news headlines", "Industry newsletter", "Save articles to read", "Share one insight"],
            category: .learning
        ),

        // ============================================
        // MIDDAY STACKS (11am - 3pm)
        // ============================================

        // Wellness & Energy
        SuggestedStack(
            name: "Midday Reset",
            icon: "arrow.clockwise",
            timeBlock: .midday,
            anchorHabit: "Lunch break starts",
            habits: ["Step outside", "5 min walk", "Deep breathing", "Refill water"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Energy Boost",
            icon: "bolt.fill",
            timeBlock: .midday,
            anchorHabit: "Feeling afternoon slump",
            habits: ["Drink water", "10 jumping jacks", "Wash face", "Healthy snack"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Desk Stretch Break",
            icon: "figure.stand",
            timeBlock: .midday,
            anchorHabit: "Set timer for 2 hours",
            habits: ["Stand and stretch", "Neck rolls", "Wrist stretches", "Eye break 20-20-20"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Mindful Lunch",
            icon: "fork.knife",
            timeBlock: .midday,
            anchorHabit: "Food is ready",
            habits: ["Put away phone", "Take 3 breaths", "Eat slowly", "Chew thoroughly"],
            category: .mindfulness
        ),

        // Productivity
        SuggestedStack(
            name: "Post-Lunch Focus",
            icon: "scope",
            timeBlock: .midday,
            anchorHabit: "Return to desk",
            habits: ["Clear desk", "Review afternoon tasks", "Set 90-min focus block", "Put phone away"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Meeting Prep",
            icon: "person.3.fill",
            timeBlock: .midday,
            anchorHabit: "15 min before meeting",
            habits: ["Review agenda", "Prepare questions", "Close unnecessary tabs", "Get water"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Email Power Hour",
            icon: "envelope.fill",
            timeBlock: .midday,
            anchorHabit: "After lunch",
            habits: ["Sort by priority", "Reply to urgent", "Archive or delete", "Unsubscribe from junk"],
            category: .productivity
        ),

        // Fitness
        SuggestedStack(
            name: "Lunch Workout",
            icon: "figure.walk",
            timeBlock: .midday,
            anchorHabit: "Lunch break",
            habits: ["Quick change", "20 min workout", "Freshen up", "Healthy lunch"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Walking Meeting",
            icon: "figure.walk",
            timeBlock: .midday,
            anchorHabit: "Meeting scheduled",
            habits: ["Grab phone/earbuds", "Start walking", "Take notes after", "Log steps"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Midday Movement",
            icon: "figure.stand",
            timeBlock: .midday,
            anchorHabit: "Set 2-hour timer",
            habits: ["50 squats", "20 pushups", "30 sec plank", "Drink water"],
            category: .fitness
        ),

        // Social
        SuggestedStack(
            name: "Social Lunch",
            icon: "person.2.fill",
            timeBlock: .midday,
            anchorHabit: "Lunch time",
            habits: ["Invite colleague", "Put phone away", "Ask questions", "Share something positive"],
            category: .social
        ),
        SuggestedStack(
            name: "Connection Call",
            icon: "phone.fill",
            timeBlock: .midday,
            anchorHabit: "Break time",
            habits: ["Call family member", "Or text a friend", "Share gratitude", "Make plans"],
            category: .social
        ),

        // ============================================
        // EVENING STACKS (3pm - 7pm)
        // ============================================

        // Work Transition
        SuggestedStack(
            name: "Work Shutdown",
            icon: "power",
            timeBlock: .evening,
            anchorHabit: "End of work day",
            habits: ["Review completed tasks", "Plan tomorrow's top 3", "Clear desk", "Close work apps"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Commute Decompress",
            icon: "car.fill",
            timeBlock: .evening,
            anchorHabit: "Leave work",
            habits: ["Deep breath", "Listen to podcast/music", "No work thoughts", "Plan evening"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Home Transition",
            icon: "house.fill",
            timeBlock: .evening,
            anchorHabit: "Walk through door",
            habits: ["Change clothes", "Put away bag", "Wash hands/face", "5 min decompress"],
            category: .wellness
        ),

        // Fitness
        SuggestedStack(
            name: "After Work Gym",
            icon: "dumbbell.fill",
            timeBlock: .evening,
            anchorHabit: "Arrive at gym",
            habits: ["Cardio warmup", "Weight training", "Core work", "Stretch"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Evening Run",
            icon: "figure.run",
            timeBlock: .evening,
            anchorHabit: "Change into running gear",
            habits: ["Dynamic warmup", "30 min run", "Cool down walk", "Stretch and foam roll"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Sunset Yoga",
            icon: "figure.yoga",
            timeBlock: .evening,
            anchorHabit: "Roll out mat",
            habits: ["Gentle warmup", "Flow sequence", "Hip openers", "Relaxation pose"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Evening Swim",
            icon: "figure.pool.swim",
            timeBlock: .evening,
            anchorHabit: "Arrive at pool",
            habits: ["Warmup laps", "Main set", "Cool down", "Stretch poolside"],
            category: .fitness
        ),

        // Family & Social
        SuggestedStack(
            name: "Family Dinner",
            icon: "figure.2.and.child.holdinghands",
            timeBlock: .evening,
            anchorHabit: "Dinner time",
            habits: ["Set table together", "No phones at table", "Share highs and lows", "Clean up together"],
            category: .social
        ),
        SuggestedStack(
            name: "Quality Time",
            icon: "heart.fill",
            timeBlock: .evening,
            anchorHabit: "After dinner",
            habits: ["Put phones away", "Play game or activity", "Have real conversation", "Express appreciation"],
            category: .social
        ),
        SuggestedStack(
            name: "Kids Bedtime",
            icon: "moon.stars.fill",
            timeBlock: .evening,
            anchorHabit: "Bath time done",
            habits: ["Brush teeth together", "Put on pajamas", "Read bedtime story", "Goodnight routine"],
            category: .social
        ),

        // Self Care
        SuggestedStack(
            name: "Evening Skincare",
            icon: "sparkles",
            timeBlock: .evening,
            anchorHabit: "After dinner",
            habits: ["Remove makeup", "Double cleanse", "Apply treatments", "Night moisturizer"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Pamper Evening",
            icon: "bathtub.fill",
            timeBlock: .evening,
            anchorHabit: "Run bath",
            habits: ["Add bath salts", "Face mask", "Relax 20 min", "Full skincare routine"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Self Care Sunday",
            icon: "heart.circle.fill",
            timeBlock: .evening,
            anchorHabit: "Sunday evening",
            habits: ["Face mask", "Manicure", "Hair treatment", "Plan self care for week"],
            category: .selfCare
        ),

        // Meal Prep & Cooking
        SuggestedStack(
            name: "Healthy Cooking",
            icon: "frying.pan.fill",
            timeBlock: .evening,
            anchorHabit: "Enter kitchen",
            habits: ["Choose recipe", "Prep ingredients", "Cook mindfully", "Plate beautifully"],
            category: .health
        ),
        SuggestedStack(
            name: "Meal Prep Session",
            icon: "takeoutbag.and.cup.and.straw.fill",
            timeBlock: .evening,
            anchorHabit: "Sunday evening",
            habits: ["Plan week's meals", "Prep vegetables", "Cook proteins", "Portion into containers"],
            category: .health
        ),

        // ============================================
        // NIGHT STACKS (7pm - 11pm)
        // ============================================

        // Wind Down & Relaxation
        SuggestedStack(
            name: "Wind Down",
            icon: "moon.fill",
            timeBlock: .night,
            anchorHabit: "2 hours before bed",
            habits: ["Dim lights", "No screens", "Herbal tea", "Light reading"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Digital Sunset",
            icon: "iphone.slash",
            timeBlock: .night,
            anchorHabit: "8 PM",
            habits: ["Put phone in another room", "Turn off TV", "Dim all screens", "Switch to book"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Evening Meditation",
            icon: "brain.head.profile",
            timeBlock: .night,
            anchorHabit: "After dinner",
            habits: ["Find quiet space", "10 min meditation", "Body scan", "Gratitude reflection"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Stress Relief",
            icon: "leaf.fill",
            timeBlock: .night,
            anchorHabit: "Feeling stressed",
            habits: ["Progressive relaxation", "Deep breathing", "Journal worries", "Release and let go"],
            category: .mindfulness
        ),

        // Reading & Learning
        SuggestedStack(
            name: "Reading Hour",
            icon: "book.fill",
            timeBlock: .night,
            anchorHabit: "After dinner",
            habits: ["Make tea", "Find cozy spot", "Read for 30-60 min", "Note key insights"],
            category: .learning
        ),
        SuggestedStack(
            name: "Book Club Prep",
            icon: "books.vertical.fill",
            timeBlock: .night,
            anchorHabit: "Evening free time",
            habits: ["Read assigned chapters", "Take notes", "Write questions", "Prepare discussion points"],
            category: .learning
        ),

        // Journaling & Reflection
        SuggestedStack(
            name: "Evening Journal",
            icon: "book.fill",
            timeBlock: .night,
            anchorHabit: "Before bed",
            habits: ["Write 3 wins", "Lessons learned", "Tomorrow's intention", "Gratitude list"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Weekly Review",
            icon: "calendar",
            timeBlock: .night,
            anchorHabit: "Sunday night",
            habits: ["Review week's goals", "Celebrate wins", "Learn from challenges", "Plan next week"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Reflection Practice",
            icon: "sparkles",
            timeBlock: .night,
            anchorHabit: "Quiet evening",
            habits: ["5 min silence", "Review the day", "Forgive yourself", "Set tomorrow's intention"],
            category: .mindfulness
        ),

        // Sleep Preparation
        SuggestedStack(
            name: "Sleep Prep",
            icon: "bed.double.fill",
            timeBlock: .night,
            anchorHabit: "1 hour before bed",
            habits: ["Set room to 65-68°F", "Put on pajamas", "Prepare bed", "No caffeine check"],
            category: .health
        ),
        SuggestedStack(
            name: "Bedtime Routine",
            icon: "moon.zzz.fill",
            timeBlock: .night,
            anchorHabit: "Bedtime",
            habits: ["Brush teeth", "Wash face", "Skincare routine", "Get into bed"],
            category: .selfCare
        ),
        SuggestedStack(
            name: "Sleep Hygiene",
            icon: "zzz",
            timeBlock: .night,
            anchorHabit: "30 min before sleep",
            habits: ["Blackout curtains", "White noise on", "Phone on charger away", "Relaxation breathing"],
            category: .health
        ),
        SuggestedStack(
            name: "Sleepy Time Yoga",
            icon: "figure.yoga",
            timeBlock: .night,
            anchorHabit: "Before bed",
            habits: ["Child's pose", "Legs up wall", "Gentle twist", "Corpse pose"],
            category: .fitness
        ),

        // Creative & Hobbies
        SuggestedStack(
            name: "Creative Hour",
            icon: "paintbrush.fill",
            timeBlock: .night,
            anchorHabit: "After dinner",
            habits: ["Set up materials", "Create for 45 min", "Clean workspace", "Document progress"],
            category: .creative
        ),
        SuggestedStack(
            name: "Music Practice",
            icon: "music.note",
            timeBlock: .night,
            anchorHabit: "Pick up instrument",
            habits: ["Warm up exercises", "Practice scales", "Work on piece", "Cool down improvisation"],
            category: .creative
        ),
        SuggestedStack(
            name: "Writing Session",
            icon: "pencil",
            timeBlock: .night,
            anchorHabit: "Open document",
            habits: ["Review last session", "Free write 5 min", "Work on main project", "Set tomorrow's goal"],
            category: .creative
        ),

        // Finance
        SuggestedStack(
            name: "Daily Money Check",
            icon: "dollarsign.circle.fill",
            timeBlock: .night,
            anchorHabit: "After dinner",
            habits: ["Check accounts", "Log expenses", "Review budget", "Plan tomorrow's spending"],
            category: .finance
        ),
        SuggestedStack(
            name: "Weekly Finance Review",
            icon: "chart.bar.fill",
            timeBlock: .night,
            anchorHabit: "Sunday night",
            habits: ["Review spending", "Check investments", "Pay pending bills", "Adjust budget"],
            category: .finance
        ),

        // Preparation for Tomorrow
        SuggestedStack(
            name: "Tomorrow Prep",
            icon: "sunrise.fill",
            timeBlock: .night,
            anchorHabit: "Before bed",
            habits: ["Pick outfit", "Pack bag", "Prep breakfast", "Set alarm"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Kitchen Reset",
            icon: "sparkles",
            timeBlock: .night,
            anchorHabit: "After dinner",
            habits: ["Load dishwasher", "Wipe counters", "Set up coffee maker", "Prep tomorrow's lunch"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Living Space Reset",
            icon: "house.fill",
            timeBlock: .night,
            anchorHabit: "Before bed",
            habits: ["Quick tidy", "Put items away", "Fluff pillows", "Prep for morning"],
            category: .productivity
        ),

        // ============================================
        // ANYTIME STACKS (Work for multiple times)
        // ============================================

        // Quick Wellness
        SuggestedStack(
            name: "5-Minute Calm",
            icon: "leaf.fill",
            timeBlock: .midday,
            anchorHabit: "Feeling stressed",
            habits: ["Stop and pause", "5 deep breaths", "Body scan", "Set intention"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Anxiety Relief",
            icon: "wind",
            timeBlock: .midday,
            anchorHabit: "Notice anxiety",
            habits: ["Name the feeling", "Box breathing", "Ground with 5 senses", "Reassuring self-talk"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Quick Meditation",
            icon: "brain.head.profile",
            timeBlock: .midday,
            anchorHabit: "Need a break",
            habits: ["Find quiet spot", "Set 5 min timer", "Focus on breath", "Return refreshed"],
            category: .mindfulness
        ),

        // Quick Fitness
        SuggestedStack(
            name: "7-Minute Workout",
            icon: "bolt.heart.fill",
            timeBlock: .midday,
            anchorHabit: "Have 10 minutes",
            habits: ["Jumping jacks", "Wall sit", "Push-ups", "Plank"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Desk Exercise",
            icon: "figure.stand",
            timeBlock: .midday,
            anchorHabit: "Set hourly timer",
            habits: ["Chair squats", "Desk pushups", "Seated leg raises", "Standing calf raises"],
            category: .fitness
        ),
        SuggestedStack(
            name: "Posture Reset",
            icon: "figure.stand",
            timeBlock: .midday,
            anchorHabit: "Notice slouching",
            habits: ["Stand tall", "Shoulder rolls", "Chin tucks", "Core engagement"],
            category: .fitness
        ),

        // Focus & Productivity
        SuggestedStack(
            name: "Deep Work Session",
            icon: "scope",
            timeBlock: .midday,
            anchorHabit: "Ready to focus",
            habits: ["Clear workspace", "Phone on DND", "Set 90-min timer", "Single task only"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Pomodoro Session",
            icon: "timer",
            timeBlock: .midday,
            anchorHabit: "Start work block",
            habits: ["Set 25 min timer", "Work focused", "5 min break", "Repeat 4 times"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Brain Dump",
            icon: "brain.head.profile",
            timeBlock: .midday,
            anchorHabit: "Feeling overwhelmed",
            habits: ["Get paper", "Write everything down", "Categorize tasks", "Pick top 3"],
            category: .productivity
        ),

        // Social Connection
        SuggestedStack(
            name: "Reach Out",
            icon: "message.fill",
            timeBlock: .midday,
            anchorHabit: "Think of someone",
            habits: ["Send thoughtful text", "Share appreciation", "Make plans", "Follow through"],
            category: .social
        ),
        SuggestedStack(
            name: "Acts of Kindness",
            icon: "heart.fill",
            timeBlock: .midday,
            anchorHabit: "See opportunity",
            habits: ["Compliment someone", "Help with task", "Buy someone coffee", "Leave kind note"],
            category: .social
        ),

        // Health Checks
        SuggestedStack(
            name: "Hydration Check",
            icon: "drop.fill",
            timeBlock: .midday,
            anchorHabit: "Hourly alarm",
            habits: ["Drink full glass", "Refill bottle", "Check urine color", "Set next reminder"],
            category: .health
        ),
        SuggestedStack(
            name: "Posture Check",
            icon: "figure.stand",
            timeBlock: .midday,
            anchorHabit: "Hourly reminder",
            habits: ["Feet flat", "Back straight", "Shoulders back", "Screen at eye level"],
            category: .health
        ),
        SuggestedStack(
            name: "Eye Care",
            icon: "eye.fill",
            timeBlock: .midday,
            anchorHabit: "20 min screen time",
            habits: ["Look away 20 feet", "Hold for 20 seconds", "Blink 20 times", "Return to work"],
            category: .health
        ),

        // Learning Micro-sessions
        SuggestedStack(
            name: "10-Min Learning",
            icon: "graduationcap.fill",
            timeBlock: .midday,
            anchorHabit: "Have 10 minutes",
            habits: ["Open learning app", "Complete one lesson", "Take quick note", "Apply one thing"],
            category: .learning
        ),
        SuggestedStack(
            name: "Podcast Walk",
            icon: "headphones",
            timeBlock: .midday,
            anchorHabit: "Going for walk",
            habits: ["Choose episode", "Listen actively", "Note key insight", "Share with someone"],
            category: .learning
        ),

        // Mindset & Motivation
        SuggestedStack(
            name: "Motivation Boost",
            icon: "flame.fill",
            timeBlock: .midday,
            anchorHabit: "Feeling unmotivated",
            habits: ["Watch inspiring video", "Review your why", "Small win action", "Celebrate progress"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Confidence Builder",
            icon: "star.fill",
            timeBlock: .morning,
            anchorHabit: "Before important event",
            habits: ["Power pose 2 min", "Positive affirmations", "Visualize success", "Take action"],
            category: .mindfulness
        ),

        // Digital Wellness
        SuggestedStack(
            name: "Social Media Detox",
            icon: "iphone.slash",
            timeBlock: .evening,
            anchorHabit: "Want to scroll",
            habits: ["Put phone down", "Take 3 breaths", "Do something else", "Notice how you feel"],
            category: .wellness
        ),
        SuggestedStack(
            name: "Inbox Zero",
            icon: "tray.fill",
            timeBlock: .midday,
            anchorHabit: "Open email",
            habits: ["Delete/archive obvious", "Quick replies first", "Schedule longer ones", "Unsubscribe ruthlessly"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Phone Cleanup",
            icon: "iphone",
            timeBlock: .evening,
            anchorHabit: "Have 15 minutes",
            habits: ["Delete unused apps", "Organize home screen", "Clear notifications", "Check storage"],
            category: .productivity
        ),

        // Specific Goals
        SuggestedStack(
            name: "Weight Loss Stack",
            icon: "scalemass.fill",
            timeBlock: .morning,
            anchorHabit: "Wake up",
            habits: ["Weigh yourself", "Log weight", "Drink water", "Plan healthy meals"],
            category: .health
        ),
        SuggestedStack(
            name: "Habit Tracker",
            icon: "checklist",
            timeBlock: .night,
            anchorHabit: "Before bed",
            habits: ["Review today's habits", "Mark completions", "Note blockers", "Plan tomorrow"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Gratitude Practice",
            icon: "heart.fill",
            timeBlock: .night,
            anchorHabit: "In bed",
            habits: ["3 things grateful for", "Why each matters", "Feel the gratitude", "Smile and sleep"],
            category: .mindfulness
        ),
        SuggestedStack(
            name: "Side Hustle Hour",
            icon: "dollarsign.circle.fill",
            timeBlock: .evening,
            anchorHabit: "After dinner",
            habits: ["Review goals", "1 hour focused work", "Track progress", "Plan next session"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Networking Session",
            icon: "person.3.sequence.fill",
            timeBlock: .evening,
            anchorHabit: "Weekly schedule",
            habits: ["Update LinkedIn", "Comment on 3 posts", "Send 2 connection requests", "Follow up on messages"],
            category: .social
        ),
        SuggestedStack(
            name: "Interview Prep",
            icon: "person.fill.questionmark",
            timeBlock: .evening,
            anchorHabit: "Before interview day",
            habits: ["Research company", "Practice answers", "Prepare questions", "Plan outfit"],
            category: .productivity
        ),
        SuggestedStack(
            name: "Public Speaking Prep",
            icon: "person.wave.2.fill",
            timeBlock: .evening,
            anchorHabit: "Before presentation",
            habits: ["Review slides", "Practice out loud", "Time yourself", "Visualize success"],
            category: .productivity
        )
    ]

    // MARK: - Get stacks sorted by current time relevance

    static func getRelevantStacks() -> [SuggestedStack] {
        let hour = Calendar.current.component(.hour, from: Date())

        // Determine current and adjacent time blocks
        let (primary, secondary): (TimeBlock, TimeBlock) = {
            switch hour {
            case 5...10:
                return (.morning, .midday)
            case 11...14:
                return (.midday, .morning)
            case 15...18:
                return (.evening, .midday)
            case 19...23, 0...4:
                return (.night, .evening)
            default:
                return (.morning, .midday)
            }
        }()

        // Sort: primary time first, then secondary, then others
        return allStacks.sorted { stack1, stack2 in
            let score1 = stack1.timeBlock == primary ? 0 : (stack1.timeBlock == secondary ? 1 : 2)
            let score2 = stack2.timeBlock == primary ? 0 : (stack2.timeBlock == secondary ? 1 : 2)

            if score1 != score2 {
                return score1 < score2
            }

            // Within same priority, sort by category for variety
            return stack1.category.rawValue < stack2.category.rawValue
        }
    }
}

// MARK: - Make SuggestedStack Identifiable for sheets
extension SuggestedStack: Equatable {
    static func == (lhs: SuggestedStack, rhs: SuggestedStack) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Suggested Stacks Section View

struct SuggestedStacksSection: View {
    let onStackTap: (SuggestedStack) -> Void
    var isMinimalist: Bool = ThemeManager.shared.isMinimalist
    @State private var isExpanded: Bool = false

    private var relevantStacks: [SuggestedStack] {
        SuggestedStacksData.getRelevantStacks()
    }

    // Theme colors
    private var accentGold: Color {
        isMinimalist ? .minWarning : .nebulaGold
    }

    private var textPrimary: Color {
        isMinimalist ? .minTextPrimary : .white
    }

    private var textSecondary: Color {
        isMinimalist ? .minTextTertiary : .nebulaLavender.opacity(0.5)
    }

    private var textTertiary: Color {
        isMinimalist ? .minTextTertiary : .nebulaLavender.opacity(0.6)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header (tappable to toggle)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.lightTap()
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(accentGold)
                        .font(.subheadline)

                    Text("Suggested Stacks")
                        .font(.headline)
                        .foregroundColor(textPrimary)

                    Spacer()

                    if isExpanded {
                        Text("Swipe for more")
                            .font(.caption)
                            .foregroundColor(textSecondary)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .padding(.horizontal, 4)

            // Horizontal Scroll (collapsible)
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(relevantStacks) { stack in
                            SuggestedStackCard(stack: stack, isMinimalist: isMinimalist)
                                .onTapGesture {
                                    HapticManager.shared.lightTap()
                                    onStackTap(stack)
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Suggested Stack Card

struct SuggestedStackCard: View {
    let stack: SuggestedStack
    var isMinimalist: Bool = ThemeManager.shared.isMinimalist

    // Theme colors
    private var accentColor: Color {
        isMinimalist ? .white : stack.timeBlock.color
    }

    private var textPrimary: Color {
        isMinimalist ? .minTextPrimary : .white
    }

    private var textSecondary: Color {
        isMinimalist ? .minTextSecondary : .nebulaLavender.opacity(0.6)
    }

    private var textTertiary: Color {
        isMinimalist ? .minTextTertiary : .nebulaLavender.opacity(0.8)
    }

    private var cardBg: Color {
        isMinimalist ? .minCard : .cardBackground
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon and Time Badge
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: stack.icon)
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }

                Spacer()

                // Time block badge
                HStack(spacing: 4) {
                    Image(systemName: stack.timeBlock.icon)
                        .font(.system(size: 10))
                    Text(stack.timeBlock.rawValue)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(accentColor.opacity(0.15))
                .cornerRadius(8)
            }

            // Stack Name
            Text(stack.name)
                .font(.subheadline.bold())
                .foregroundColor(textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Habit count
            HStack(spacing: 4) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 10))
                Text("\(stack.habits.count + 1) habits")
                    .font(.caption)
            }
            .foregroundColor(textSecondary)

            // Category tag
            Text(stack.category.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(textTertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(isMinimalist ? Color.minSubtle : Color.white.opacity(0.08))
                .cornerRadius(6)
        }
        .padding(12)
        .frame(width: 150, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isMinimalist ? Color.minSubtle.opacity(0.2) : stack.timeBlock.color.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Suggested Stack Detail Sheet

struct SuggestedStackDetailSheet: View {
    let suggestedStack: SuggestedStack
    let onAddToStacks: (HabitStack) -> Void
    let onStartNow: (HabitStack) -> Void

    @Environment(\.dismiss) private var dismiss

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

                    // Time block badge
                    HStack(spacing: 6) {
                        Image(systemName: suggestedStack.timeBlock.icon)
                        Text(suggestedStack.timeBlock.rawValue)
                    }
                    .font(.subheadline)
                    .foregroundColor(suggestedStack.timeBlock.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(suggestedStack.timeBlock.color.opacity(0.15))
                    .cornerRadius(12)

                    Spacer()

                    // Invisible balance
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)

                // Stack Info
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(suggestedStack.timeBlock.color.opacity(0.2))
                            .frame(width: 60, height: 60)

                        Image(systemName: suggestedStack.icon)
                            .font(.system(size: 28))
                            .foregroundColor(suggestedStack.timeBlock.color)
                    }

                    Text(suggestedStack.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(suggestedStack.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                }

                // Habits List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Habits in this stack")
                        .font(.subheadline.bold())
                        .foregroundColor(.nebulaLavender.opacity(0.8))
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 8) {
                            // Anchor habit
                            HabitPreviewRow(
                                name: suggestedStack.anchorHabit,
                                icon: suggestedStack.timeBlock.icon,
                                index: 0,
                                isAnchor: true,
                                color: suggestedStack.timeBlock.color
                            )

                            // Other habits
                            ForEach(Array(suggestedStack.habits.enumerated()), id: \.offset) { index, habitName in
                                HabitPreviewRow(
                                    name: habitName,
                                    icon: detectIcon(for: habitName),
                                    index: index + 1,
                                    isAnchor: false,
                                    color: suggestedStack.timeBlock.color
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxHeight: 280)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        let stack = createHabitStack()
                        onStartNow(stack)
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Now")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(suggestedStack.timeBlock.color)
                        )
                        .shadow(color: suggestedStack.timeBlock.color.opacity(0.4), radius: 8)
                    }

                    Button(action: {
                        let stack = createHabitStack()
                        onAddToStacks(stack)
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add to My Stacks")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(suggestedStack.timeBlock.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func createHabitStack() -> HabitStack {
        // Create anchor habit
        let anchorHabit = Habit(
            name: suggestedStack.anchorHabit,
            icon: suggestedStack.timeBlock.icon,
            order: 0
        )

        // Create other habits
        var habits: [Habit] = [anchorHabit]
        for (index, habitName) in suggestedStack.habits.enumerated() {
            let habit = Habit(
                name: habitName,
                icon: detectIcon(for: habitName),
                order: index + 1
            )
            habits.append(habit)
        }

        // Create the stack (defaults to every day)
        return HabitStack(
            name: suggestedStack.name,
            timeBlock: suggestedStack.timeBlock,
            anchorHabit: suggestedStack.anchorHabit,
            reminderTime: getDefaultReminderTime(),
            habits: habits,
            color: suggestedStack.timeBlock.color,
            streak: 0,
            scheduledDays: Set(1...7)
        )
    }

    private func getDefaultReminderTime() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())

        switch suggestedStack.timeBlock {
        case .morning:
            components.hour = 7
            components.minute = 0
        case .midday:
            components.hour = 12
            components.minute = 0
        case .evening:
            components.hour = 18
            components.minute = 0
        case .night:
            components.hour = 21
            components.minute = 0
        }

        return calendar.date(from: components) ?? Date()
    }
}

// MARK: - Habit Preview Row

struct HabitPreviewRow: View {
    let name: String
    let icon: String
    let index: Int
    let isAnchor: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Index number
            Text("\(index + 1)")
                .font(.caption.bold())
                .foregroundColor(.nebulaLavender.opacity(0.5))
                .frame(width: 20)

            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.white)

                if isAnchor {
                    Text("Anchor habit")
                        .font(.caption2)
                        .foregroundColor(color.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isAnchor ? 0.08 : 0.04))
        )
    }
}
