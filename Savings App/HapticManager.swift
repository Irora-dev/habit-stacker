//
//  HapticManager.swift
//  Habit Stacking App
//

import SwiftUI
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light tap - for button presses
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Medium impact - for completing a habit
    func habitComplete() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Heavy impact - for emphasis
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Success - for completing a stack
    func stackComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Double tap celebration
    func celebration() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
}
