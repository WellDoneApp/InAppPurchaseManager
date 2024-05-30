//
//  ApphudInterceptorDelegate.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import class StoreKit.SKProduct
import class StoreKit.SKPaymentTransaction
import ApphudSDK

public protocol ApphudInterceptorDelegate: AnyObject {
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription])
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase])
    func apphudDidChangeUserID(_ userID: String)
    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)?
    func apphudDidObservePurchase(result: ApphudPurchaseResult) -> Bool
    func handleDeferredTransaction(transaction: SKPaymentTransaction)
    func userDidLoad(user: ApphudUser)
    func paywallsDidFullyLoad(paywalls: [ApphudPaywall])
    func placementsDidFullyLoad(placements: [ApphudPlacement])
}

public extension ApphudInterceptorDelegate {
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {}
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {}
    func apphudDidChangeUserID(_ userID: String) {}
    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? { nil }
    func apphudDidObservePurchase(result: ApphudPurchaseResult) -> Bool { false }
    func handleDeferredTransaction(transaction: SKPaymentTransaction) {}
    func userDidLoad(user: ApphudUser) {}
    func paywallsDidFullyLoad(paywalls: [ApphudPaywall]) {}
    func placementsDidFullyLoad(placements: [ApphudPlacement]) {}
}

// MARK: -
// MARK: - InAppPurchaseManager ApphudDelegate

extension InAppPurchaseManager: ApphudDelegate {
    
    public func paywallsDidFullyLoad(paywalls: [ApphudPaywall]) {
        Task { try? await Apphud.fetchProducts() }
        
        delegate?.paywallsDidFullyLoad(paywalls: paywalls)
    }
    
    public func userDidLoad(user: ApphudUser) {
        delegate?.userDidLoad(user: user)
    }
    
    public func placementsDidFullyLoad(placements: [ApphudPlacement]) {
        delegate?.placementsDidFullyLoad(placements: placements)
    }
    
    public func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        delegate?.apphudSubscriptionsUpdated(subscriptions)
    }
    
    public func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        delegate?.apphudNonRenewingPurchasesUpdated(purchases)
    }
    
    public func apphudDidChangeUserID(_ userID: String) {
        delegate?.apphudDidChangeUserID(userID)
    }
    
    public func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? {
        delegate?.apphudShouldStartAppStoreDirectPurchase(product)
     }
    
    public func apphudDidObservePurchase(result: ApphudPurchaseResult) -> Bool {
        delegate?.apphudDidObservePurchase(result: result) ?? false
     }
    
    public func handleDeferredTransaction(transaction: SKPaymentTransaction) {
        delegate?.handleDeferredTransaction(transaction: transaction)
    }
    
}
