//
//  InAppPurchaseManager.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import StoreKit
import SwiftUI
import ApphudSDK

public class InAppPurchaseManager {
    
    // - Singleton
    public static let shared = InAppPurchaseManager()
    
    // - Delegate
    public weak var delegate: ApphudInterceptorDelegate?
    
    // - Data
    @MainActor public static var isPremium: Bool { Apphud.hasActiveSubscription() }
    
    // - Init
    private init() {}
    
    // - Configure
    @MainActor public static func start(apphudApiKey: String, userID: String, debugLogs: Bool = false, callback: ((ApphudUser) -> Void)? = nil) {
        Apphud.start(apiKey: apphudApiKey, userID: userID, observerMode: false, callback: callback)
        Apphud.setDelegate(InAppPurchaseManager.shared)
        NetworkMonitor.shared.startMonitoring()
        if debugLogs {
            Apphud.enableDebugLogs()
        }
    }
    
}

// MARK: -
// MARK: - Interface

public extension InAppPurchaseManager {
    
    @MainActor
    static func purchase(_ product: Product, isPurchasing: Binding<Bool>? = nil) async -> ApphudAsyncPurchaseResult {
        return await Apphud.purchase(product, isPurchasing: isPurchasing)
    }
    
    @MainActor
    static func restorePurchases() async -> Error? {
        return await Apphud.restorePurchases()
    }
    
    static func getPaywallData(identifier: PaywallID) async -> PaywallModel? {
        guard let paywall = await Apphud.paywall(identifier.rawValue) else { return nil }
        let structProducts = await paywall.products.asyncCompactMap { try? await $0.product() }
        let paywallModel = await PaywallModel(apphudPaywall: paywall, products: structProducts)
        return paywallModel
    }
    
}
