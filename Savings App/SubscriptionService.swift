//
//  SubscriptionService.swift
//  Cosmos Productivity Suite - Stakk
//
//  Subscription management following SUBSCRIPTION_MODEL.md
//

import SwiftUI
import StoreKit

// MARK: - Product IDs
enum SubscriptionProductID: String {
    case monthlyPremium = "com.cosmos.stakk.premium.monthly"
    case yearlyPremium = "com.cosmos.stakk.premium.yearly"
    case lifetimePremium = "com.cosmos.stakk.premium.lifetime"

    var displayName: String {
        switch self {
        case .monthlyPremium: return "Monthly"
        case .yearlyPremium: return "Yearly"
        case .lifetimePremium: return "Lifetime"
        }
    }

    var displayPrice: String {
        switch self {
        case .monthlyPremium: return "$4.99/mo"
        case .yearlyPremium: return "$49.99/yr"
        case .lifetimePremium: return "$149.99"
        }
    }
}

// MARK: - Subscription Service
@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?

    // MARK: - Dev Mode
    @Published var isDevModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDevModeEnabled, forKey: "devModeEnabled")
        }
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        self.isDevModeEnabled = UserDefaults.standard.bool(forKey: "devModeEnabled")
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Premium Status
    var isPremium: Bool {
        isDevModeEnabled || !purchasedProductIDs.isEmpty
    }

    var hasLifetime: Bool {
        purchasedProductIDs.contains(SubscriptionProductID.lifetimePremium.rawValue)
    }

    // MARK: - Feature Access
    func canAccess(_ feature: PremiumFeature) -> Bool {
        isPremium
    }

    func canCreateStack(inTimeBlock timeBlock: String, currentCount: Int) -> Bool {
        isPremium || currentCount < FeatureLimits.freeStacksPerTimeBlock
    }

    func canAddHabitToStack() -> Bool {
        // Habits per stack are unlimited in free tier
        true
    }

    func maxCalendarWeeks() -> Int {
        isPremium ? 52 : FeatureLimits.freeCalendarWeeks
    }

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        error = nil

        do {
            let productIDs: Set<String> = [
                SubscriptionProductID.monthlyPremium.rawValue,
                SubscriptionProductID.yearlyPremium.rawValue,
                SubscriptionProductID.lifetimePremium.rawValue
            ]

            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            self.error = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            HapticManager.shared.play(.success)
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        error = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            self.error = "Failed to restore purchases: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Update Purchased Products
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {
                // Invalid transaction, skip
            }
        }

        purchasedProductIDs = purchasedIDs
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    // Invalid transaction
                }
            }
        }
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Error
enum StoreError: Error {
    case failedVerification
}

// MARK: - Ecosystem App Model
struct EcosystemApp: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let tagline: String
    let color: Color

    static let allApps: [EcosystemApp] = [
        EcosystemApp(name: "Stakk", icon: "square.stack.3d.up.fill", tagline: "Habits", color: .nebulaMagenta),
        EcosystemApp(name: "Pulse", icon: "checkmark.circle.fill", tagline: "Tasks", color: .nebulaCyan),
        EcosystemApp(name: "Orbit", icon: "calendar.circle.fill", tagline: "Time Blocking", color: .nebulaPurple),
        EcosystemApp(name: "Reflect", icon: "book.fill", tagline: "Journaling", color: .nebulaGold),
        EcosystemApp(name: "Summit", icon: "mountain.2.fill", tagline: "Goals", color: .nebulaLavender),
        EcosystemApp(name: "Flow", icon: "timer", tagline: "Focus", color: .nebulaGold),
        EcosystemApp(name: "Signal", icon: "chart.bar.fill", tagline: "Analytics", color: .nebulaCyan),
        EcosystemApp(name: "Hub", icon: "square.grid.2x2.fill", tagline: "Dashboard", color: .nebulaPurple)
    ]
}

// MARK: - Paywall View
struct CosmosPaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.cosmicBlack, .cosmicDeep, .cosmicBlack],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CosmosSpacing.xl) {
                    // Header
                    VStack(spacing: CosmosSpacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.nebulaGold, .nebulaMagenta],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .nebulaGold.opacity(0.4), radius: 20)

                        Text("Cosmos Premium")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("One subscription. Unlimited productivity.")
                            .font(.subheadline)
                            .foregroundColor(.nebulaLavender.opacity(0.7))
                    }
                    .padding(.top, CosmosSpacing.xxl)

                    // Ecosystem Apps Section
                    VStack(spacing: CosmosSpacing.md) {
                        Text("UNLOCK THE ENTIRE ECOSYSTEM")
                            .font(.caption.bold())
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                            .tracking(1.5)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: CosmosSpacing.md) {
                            ForEach(EcosystemApp.allApps) { app in
                                EcosystemAppIcon(app: app)
                            }
                        }
                        .padding(.horizontal)

                        Text("8 apps designed to work together seamlessly")
                            .font(.caption)
                            .foregroundColor(.nebulaLavender.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CosmosRadius.lg)
                            .fill(Color.cardBackground.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmosRadius.lg)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.nebulaMagenta.opacity(0.3), .nebulaCyan.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .padding(.horizontal)

                    // Premium Benefits Section
                    VStack(alignment: .leading, spacing: CosmosSpacing.md) {
                        Text("PREMIUM BENEFITS")
                            .font(.caption.bold())
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                            .tracking(1.5)
                            .padding(.horizontal)

                        ForEach(PremiumFeature.allCases, id: \.rawValue) { feature in
                            PremiumFeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal)

                    // Products
                    if subscriptionService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .nebulaCyan))
                    } else if let error = subscriptionService.error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.nebulaMagenta)
                    } else {
                        VStack(spacing: CosmosSpacing.md) {
                            ForEach(subscriptionService.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id
                                ) {
                                    selectedProduct = product
                                    HapticManager.shared.play(.selection)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Purchase Button
                    if let product = selectedProduct {
                        CosmosPrimaryButton(
                            isPurchasing ? "Processing..." : "Subscribe - \(product.displayPrice)",
                            color: .nebulaPurple,
                            isLoading: isPurchasing
                        ) {
                            Task {
                                await purchase(product)
                            }
                        }
                        .padding(.horizontal, CosmosSpacing.xxl)
                    }

                    // Restore
                    Button(action: {
                        Task {
                            await subscriptionService.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.nebulaLavender.opacity(0.7))
                    }

                    // Terms
                    Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                        .font(.caption2)
                        .foregroundColor(.nebulaLavender.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, CosmosSpacing.xxl)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.nebulaLavender.opacity(0.6))
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        do {
            let success = try await subscriptionService.purchase(product)
            if success {
                dismiss()
            }
        } catch {
            // Handle error
        }
        isPurchasing = false
    }
}

// MARK: - Ecosystem App Icon
struct EcosystemAppIcon: View {
    let app: EcosystemApp

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(app.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: app.icon)
                    .font(.system(size: 22))
                    .foregroundColor(app.color)
            }

            Text(app.name)
                .font(.caption2.bold())
                .foregroundColor(.white)

            Text(app.tagline)
                .font(.system(size: 9))
                .foregroundColor(.nebulaLavender.opacity(0.5))
        }
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let feature: PremiumFeature

    var body: some View {
        HStack(spacing: CosmosSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.nebulaCyan)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.nebulaLavender.opacity(0.6))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CosmosRadius.md)
                .fill(Color.cardBackground.opacity(0.5))
        )
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    var isBestValue: Bool {
        product.id == SubscriptionProductID.yearlyPremium.rawValue
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(.white)

                        if isBestValue {
                            Text("Best Value")
                                .font(.caption2.bold())
                                .foregroundColor(.cosmicBlack)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.nebulaGold)
                                .cornerRadius(4)
                        }
                    }

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.nebulaLavender.opacity(0.6))
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.headline)
                    .foregroundColor(isSelected ? .nebulaCyan : .white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CosmosRadius.md)
                    .fill(Color.cardBackground.opacity(isSelected ? 0.9 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmosRadius.md)
                            .stroke(
                                isSelected ? Color.nebulaCyan : Color.nebulaLavender.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .accessibilityLabel("\(product.displayName), \(product.displayPrice)")
    }
}

// MARK: - Premium Gate Modifier
struct PremiumGateModifier: ViewModifier {
    @StateObject private var subscriptionService = SubscriptionService.shared
    let feature: PremiumFeature
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if subscriptionService.canAccess(feature) {
                    // Allow action - this modifier is for gating taps
                } else {
                    showPaywall = true
                }
            }
            .sheet(isPresented: $showPaywall) {
                CosmosPaywallView()
            }
    }
}

extension View {
    func premiumGate(_ feature: PremiumFeature) -> some View {
        modifier(PremiumGateModifier(feature: feature))
    }
}
