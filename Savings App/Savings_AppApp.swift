//
//  Savings_AppApp.swift
//  Savings App
//
//  Created by Colby Mort on 30/12/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

// Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // Handle Google Sign-In URL
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct Savings_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [HabitStack.self, Habit.self, SessionLog.self, HabitLog.self])
    }
}

// MARK: - Root View
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasRequestedNotifications") private var hasRequestedNotifications: Bool = false
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showMainApp: Bool = false

    var body: some View {
        ZStack {
            // Flow: Onboarding -> Login -> HomeScreen -> MainApp
            if !hasCompletedOnboarding {
                // First time user - show onboarding
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else if authManager.authenticationState != .authenticated {
                // Not logged in - show login
                LoginView()
                    .transition(.opacity)
            } else if showMainApp {
                // Logged in and in main app
                ContentView()
                    .transition(.opacity)
            } else {
                // Logged in but at home screen
                HomeScreenView(showMainApp: $showMainApp)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: authManager.authenticationState)
        .animation(.easeInOut(duration: 0.3), value: showMainApp)
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            // Request notification permission after onboarding completes
            if newValue && !hasRequestedNotifications {
                Task {
                    _ = await NotificationManager.shared.requestAuthorization()
                    hasRequestedNotifications = true
                }
            }
        }
        .onChange(of: authManager.authenticationState) { _, newValue in
            // Reset showMainApp when user signs out
            if newValue != .authenticated {
                showMainApp = false
            }
        }
    }
}
