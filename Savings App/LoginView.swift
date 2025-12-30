//
//  LoginView.swift
//  Habit Stacking App
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @State private var showResetPassword: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var borderRotation: Double = 0

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    // TEMP: Bypass login button
                    Button(action: {
                        authManager.authenticationState = .authenticated
                    }) {
                        Text("Skip Login (Dev)")
                            .font(.caption)
                            .foregroundColor(.nebulaCyan)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.cardBackground.opacity(0.5))
                            .cornerRadius(20)
                    }

                    // Logo
                    logoSection

                    // Email/Password Form
                    emailPasswordSection

                    // Social Sign-In Options
                    socialSignInSection

                    // Toggle Sign Up / Sign In
                    toggleAuthModeSection
                }
                .padding()
                .padding(.bottom, 20)
            }

            // Loading overlay
            if isLoading {
                loadingOverlay
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordView()
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
    }

    // MARK: - Logo Section

    var logoSection: some View {
        VStack(spacing: 16) {
            // App logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .shadow(color: .nebulaPurple.opacity(0.5), radius: 15)

            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(.subheadline)
                .foregroundColor(.nebulaLavender.opacity(0.7))
        }
    }

    // MARK: - Email/Password Section

    var emailPasswordSection: some View {
        VStack(spacing: 16) {
            // Email field
            CosmicTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )

            // Password field
            CosmicSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password
            )

            // Forgot password (only show on sign in)
            if !isSignUp {
                HStack {
                    Spacer()
                    Button(action: { showResetPassword = true }) {
                        Text("Forgot Password?")
                            .font(.caption)
                            .foregroundColor(.nebulaCyan)
                    }
                }
            }

            // Sign In / Sign Up button
            Button(action: performEmailAuth) {
                Text(isSignUp ? "Create Account" : "Sign In")
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
            .disabled(email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Social Sign-In Section

    var socialSignInSection: some View {
        VStack(spacing: 16) {
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.nebulaLavender.opacity(0.2))
                    .frame(height: 1)
                Text("or continue with")
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.5))
                Rectangle()
                    .fill(Color.nebulaLavender.opacity(0.2))
                    .frame(height: 1)
            }

            // Social buttons in a row
            HStack(spacing: 24) {
                // Sign in with Apple (icon only)
                Button(action: {
                    // Trigger Apple Sign In - we need to use the SignInWithAppleButton for the actual request
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                            .shadow(color: .white.opacity(0.2), radius: 8)

                        Image(systemName: "apple.logo")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .overlay(
                    SignInWithAppleButton(
                        onRequest: { request in
                            authManager.handleSignInWithAppleRequest(request)
                        },
                        onCompletion: { result in
                            Task {
                                isLoading = true
                                do {
                                    try await authManager.handleSignInWithAppleCompletion(result)
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                                isLoading = false
                            }
                        }
                    )
                    .blendMode(.overlay)
                    .opacity(0.02)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                )

                // Sign in with Google (icon only)
                Button(action: performGoogleSignIn) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                            .shadow(color: .white.opacity(0.2), radius: 8)

                        Text("G")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .yellow, .green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Toggle Auth Mode Section

    var toggleAuthModeSection: some View {
        HStack {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(.subheadline)
                .foregroundColor(.nebulaLavender.opacity(0.6))

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSignUp.toggle()
                }
            }) {
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .font(.subheadline.bold())
                    .foregroundColor(.nebulaCyan)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Loading Overlay

    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .nebulaCyan))
                    .scaleEffect(1.5)
                Text("Signing in...")
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
            )
        }
    }

    // MARK: - Actions

    func performEmailAuth() {
        isLoading = true
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, password: password)
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }

    func performGoogleSignIn() {
        isLoading = true
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

// MARK: - Cosmic Text Field

struct CosmicTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.nebulaLavender.opacity(0.6))
                .frame(width: 24)

            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .textContentType(keyboardType == .emailAddress ? .emailAddress : nil)
        }
        .padding()
        .background(Color.cardBackground.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Cosmic Secure Field

struct CosmicSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.nebulaLavender.opacity(0.6))
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.nebulaLavender.opacity(0.4))
            }
        }
        .padding()
        .background(Color.cardBackground.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.nebulaLavender.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Reset Password View

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                    }
                    Spacer()
                }

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.nebulaCyan.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)

                        Image(systemName: "key.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.nebulaCyan)
                            .shadow(color: .nebulaCyan.opacity(0.5), radius: 10)
                    }

                    Text("Reset Password")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundColor(.nebulaLavender.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 24)

                CosmicTextField(
                    icon: "envelope.fill",
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress
                )

                Button(action: resetPassword) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Send Reset Link")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.nebulaCyan)
                    )
                    .shadow(color: .nebulaCyan.opacity(0.4), radius: 8)
                }
                .disabled(email.isEmpty || isLoading)
                .opacity(email.isEmpty ? 0.6 : 1)

                Spacer()
            }
            .padding()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Password reset email sent. Check your inbox.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    func resetPassword() {
        isLoading = true
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: email)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}
