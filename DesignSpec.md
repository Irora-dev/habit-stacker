# HabitStacker Design Specification

A comprehensive design system for cosmic-themed iOS applications.

---

## Color Palette

### Base Colors (Backgrounds)

| Name | RGB | Hex | Usage |
|------|-----|-----|-------|
| **Cosmic Black** | `(0.04, 0.04, 0.08)` | `#0A0A14` | Primary background, darkest layer |
| **Cosmic Deep** | `(0.08, 0.06, 0.14)` | `#140F24` | Secondary background, gradient stops |
| **Card Background** | `(0.12, 0.10, 0.20)` | `#1F1A33` | Cards, containers, elevated surfaces |

### Accent Colors

| Name | RGB | Hex | Usage |
|------|-----|-----|-------|
| **Nebula Cyan** | `(0.25, 0.85, 0.95)` | `#40D9F2` | Success, completion, highlights |
| **Nebula Magenta** | `(0.95, 0.35, 0.75)` | `#F259BF` | Alerts, evening theme, decorative |
| **Nebula Lavender** | `(0.70, 0.55, 0.95)` | `#B38CF2` | Secondary text, muted elements |
| **Nebula Purple** | `(0.55, 0.30, 0.85)` | `#8C4DD9` | Primary buttons, main actions |
| **Nebula Gold** | `(1.0, 0.80, 0.40)` | `#FFCC66` | Morning theme, warnings, stars |

### Time Block Colors

| Time | Color | Usage |
|------|-------|-------|
| Morning | `nebulaGold` | Sunrise, energy, new beginnings |
| Midday | `nebulaCyan` | Peak productivity, focus |
| Evening | `nebulaMagenta` | Wind down, transition |
| Night | `nebulaLavender` | Rest, calm, reflection |

---

## Typography

### Font Sizes

| Purpose | Size | Weight | Example |
|---------|------|--------|---------|
| Large Title | 32pt | Bold | Main headers |
| Title | 28pt | Bold | Section headers |
| Title 2 | 24pt | Bold | Subsection headers |
| Headline | 17pt | Semibold | Card titles |
| Subheadline | 15-16pt | Regular | Descriptions |
| Body | 17pt | Regular | Main content |
| Caption | 13pt | Regular | Secondary info |
| Caption 2 | 11-12pt | Regular | Tertiary info |

### Font Styles

```swift
// Headers
.font(.system(size: 32, weight: .bold))
.font(.system(size: 28, weight: .bold))
.font(.system(size: 24, weight: .bold))

// Body
.font(.headline)                           // 17pt semibold
.font(.subheadline)                        // 15pt regular
.font(.system(size: 17, weight: .semibold)) // Buttons

// Captions
.font(.caption)                            // 12pt
.font(.caption2)                           // 11pt
.font(.system(size: 13))                   // Custom caption
```

### Line Spacing

| Context | Value |
|---------|-------|
| Headers | 4-6pt |
| Body text | 5pt |
| Multi-line descriptions | 4-5pt |

---

## Spacing System

### Padding

| Size | Value | Usage |
|------|-------|-------|
| XS | 4pt | Icon gaps, tight spacing |
| S | 8pt | Internal element spacing |
| M | 12pt | Card internal padding |
| L | 16pt | Section spacing |
| XL | 24pt | Major section gaps |
| XXL | 32pt | Screen edge padding |
| XXXL | 40-50pt | Hero spacing |

### Common Patterns

```swift
// Screen padding
.padding(.horizontal, 32)
.padding(.bottom, 60)

// Card padding
.padding(12)
.padding(.horizontal, 14)
.padding(.vertical, 12)

// Section spacing
VStack(spacing: 12)   // Items within section
VStack(spacing: 16)   // Between elements
VStack(spacing: 24)   // Between sections

// Button spacing
.padding(.vertical, 18)
.padding(.horizontal, 32)
```

---

## Corner Radii

| Size | Value | Usage |
|------|-------|-------|
| Small | 8pt | Buttons, small elements |
| Medium | 12pt | Input fields, tags |
| Large | 14-16pt | Cards, containers |
| XL | 20pt | Large cards, sheets |
| Circle | 50% | Icons, avatars |

---

## Shadows

### Standard Shadow

```swift
.shadow(color: .color.opacity(0.4), radius: 8)
```

### Glow Effects

```swift
// Subtle glow
.shadow(color: .nebulaGold.opacity(0.4), radius: 4)

// Medium glow
.shadow(color: .nebulaPurple.opacity(0.4), radius: 8)

// Strong glow
.shadow(color: .nebulaMagenta.opacity(0.5), radius: 10)

// Hero glow
.shadow(color: .nebulaMagenta.opacity(0.4), radius: 20)
```

### Layered Shadows (Spotlight)

```swift
.shadow(color: .nebulaCyan.opacity(0.6), radius: 10)
.shadow(color: .nebulaCyan.opacity(0.3), radius: 20)
```

---

## Opacity Scale

| Level | Value | Usage |
|-------|-------|-------|
| Disabled | 0.2-0.3 | Disabled states |
| Muted | 0.4-0.5 | Secondary text, inactive |
| Subtle | 0.5-0.6 | Tertiary elements |
| Medium | 0.7-0.8 | Secondary active elements |
| Full | 1.0 | Primary elements |

### Common Patterns

```swift
// Text hierarchy
.foregroundColor(.white)                        // Primary
.foregroundColor(.nebulaLavender.opacity(0.8))  // Secondary
.foregroundColor(.nebulaLavender.opacity(0.6))  // Tertiary
.foregroundColor(.nebulaLavender.opacity(0.5))  // Muted
.foregroundColor(.nebulaLavender.opacity(0.4))  // Disabled

// Backgrounds
Color.cardBackground.opacity(0.7)   // Standard card
Color.cardBackground.opacity(0.5)   // Lighter card
Color.cardBackground.opacity(0.4)   // Faded card
Color.white.opacity(0.05)           // Subtle highlight
Color.white.opacity(0.03)           // Very subtle
```

---

## Stroke Widths

| Size | Value | Usage |
|------|-------|-------|
| Hairline | 1pt | Subtle borders |
| Thin | 1.5pt | Card borders |
| Regular | 2pt | Buttons, emphasis |
| Medium | 3pt | Focus rings |
| Thick | 12pt | Progress rings |

---

## Animation

### Durations

| Speed | Duration | Usage |
|-------|----------|-------|
| Fast | 0.2s | Micro-interactions |
| Medium | 0.25s | Toggles, state changes |
| Normal | 0.3s | Page transitions |
| Slow | 0.5s | Entrance animations |
| Hero | 0.6s | Welcome screens |

### Easing

```swift
// Standard
.animation(.easeInOut(duration: 0.25))
.animation(.easeOut(duration: 0.5))

// With delay (staggered)
.animation(.easeOut(duration: 0.6).delay(0.4))

// Repeating (pulse)
.animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false))
```

---

## Component Patterns

### Buttons

```swift
// Primary Button
Button(action: {}) {
    Text("Get Started")
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.nebulaPurple)
        )
        .shadow(color: .nebulaPurple.opacity(0.4), radius: 8)
}
.padding(.horizontal, 32)

// Icon Button
Button(action: {}) {
    Image(systemName: "plus.circle.fill")
        .foregroundColor(timeBlock.color)
        .font(.title2)
        .shadow(color: timeBlock.color.opacity(0.4), radius: 4)
}
```

### Cards

```swift
// Standard Card
VStack { ... }
    .padding(12)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.cardBackground.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
            )
    )
```

### Input Fields

```swift
TextField("", text: $text)
    .padding()
    .background(Color.cardBackground.opacity(0.7))
    .cornerRadius(12)
    .foregroundColor(.white)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
    )
```

### Icon Circles

```swift
// Small (status indicators)
Circle()
    .fill(color.opacity(0.2))
    .frame(width: 40, height: 40)
    .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))

// Medium (list items)
Circle()
    .fill(color.opacity(0.15))
    .frame(width: 46-48, height: 46-48)
    .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 1.5))

// Large (heroes)
Circle()
    .fill(color.opacity(0.2))
    .frame(width: 100, height: 100)
    .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 2))
```

---

## Background Gradient

```swift
// Cosmic Background
LinearGradient(
    stops: [
        .init(color: Color.cosmicBlack, location: 0),
        .init(color: Color.cosmicDeep, location: 0.3),
        .init(color: Color.cosmicDeep, location: 0.7),
        .init(color: Color.cosmicBlack, location: 1)
    ],
    startPoint: .top,
    endPoint: .bottom
)
.ignoresSafeArea()

// Decorative Orbs
Circle()
    .fill(Color.nebulaMagenta.opacity(0.15))
    .frame(width: 300, height: 300)
    .blur(radius: 80)

Circle()
    .fill(Color.nebulaPurple.opacity(0.12))
    .frame(width: 250, height: 250)
    .blur(radius: 60)

Circle()
    .fill(Color.nebulaCyan.opacity(0.08))
    .frame(width: 200, height: 200)
    .blur(radius: 50)
```

---

## Icon Sizes

| Context | Font Size | Frame |
|---------|-----------|-------|
| Navigation | .title2 | - |
| List items | 18-20pt | 40-48pt circle |
| Buttons | .title2 | - |
| Small indicators | 10-12pt | - |
| Chevrons | 13-14pt | 32pt frame |
| Hero icons | 44-48pt | 100pt circle |

---

## SwiftUI Color Extension

```swift
extension Color {
    // Base colors
    static let cosmicBlack = Color(red: 0.04, green: 0.04, blue: 0.08)
    static let cosmicDeep = Color(red: 0.08, green: 0.06, blue: 0.14)
    static let cardBackground = Color(red: 0.12, green: 0.10, blue: 0.20)

    // Accent colors
    static let nebulaCyan = Color(red: 0.25, green: 0.85, blue: 0.95)
    static let nebulaMagenta = Color(red: 0.95, green: 0.35, blue: 0.75)
    static let nebulaLavender = Color(red: 0.70, green: 0.55, blue: 0.95)
    static let nebulaPurple = Color(red: 0.55, green: 0.30, blue: 0.85)
    static let nebulaGold = Color(red: 1.0, green: 0.80, blue: 0.40)

    // Gradient
    static let nebulaGradient = LinearGradient(
        colors: [nebulaMagenta, nebulaPurple, nebulaCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
```

---

## Best Practices

1. **Dark Mode First** - Design for dark backgrounds with light text
2. **Glow Over Shadow** - Use colored shadows as glows for depth
3. **Consistent Opacity** - Follow the opacity scale for hierarchy
4. **Generous Spacing** - Use ample padding for touch targets (44pt min)
5. **Animated Feedback** - Add subtle animations for interactions
6. **Color Meaning** - Use consistent colors for states (cyan = success, gold = warning)
7. **Progressive Disclosure** - Use collapsible sections and sheets

---

*Generated from HabitStacker App - December 2025*
