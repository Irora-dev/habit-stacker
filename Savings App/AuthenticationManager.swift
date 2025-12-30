//
//  AuthenticationManager.swift
//  Habit Stacking App
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published var user: User?
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String?

    // For Sign in with Apple
    private var currentNonce: String?

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private init() {
        registerAuthStateHandler()
    }

    // MARK: - Auth State Listener

    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                Task { @MainActor in
                    self?.user = user
                    self?.authenticationState = user != nil ? .authenticated : .unauthenticated
                }
            }
        }
    }

    // MARK: - Email/Password Authentication

    func signUp(email: String, password: String) async throws {
        authenticationState = .authenticating
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            user = result.user
            authenticationState = .authenticated
        } catch let error as NSError {
            authenticationState = .unauthenticated
            throw mapFirebaseError(error)
        }
    }

    func signIn(email: String, password: String) async throws {
        authenticationState = .authenticating
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            user = result.user
            authenticationState = .authenticated
        } catch let error as NSError {
            authenticationState = .unauthenticated
            throw mapFirebaseError(error)
        }
    }

    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign in with Apple

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    throw AuthenticationError.unknown("Invalid state: nonce not set")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AuthenticationError.unknown("Unable to fetch identity token")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthenticationError.unknown("Unable to serialize token string")
                }

                let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName
                )

                authenticationState = .authenticating
                let authResult = try await Auth.auth().signIn(with: credential)
                user = authResult.user
                authenticationState = .authenticated
            }
        case .failure(let error):
            authenticationState = .unauthenticated
            throw AuthenticationError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationError.unknown("Firebase client ID not found")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthenticationError.unknown("No root view controller found")
        }

        authenticationState = .authenticating

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthenticationError.unknown("Unable to get ID token")
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            user = authResult.user
            authenticationState = .authenticated
        } catch {
            authenticationState = .unauthenticated
            throw AuthenticationError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            user = nil
            authenticationState = .unauthenticated
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Helper Functions

    private func mapFirebaseError(_ error: NSError) -> AuthenticationError {
        switch error.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }

    // Nonce generation for Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
