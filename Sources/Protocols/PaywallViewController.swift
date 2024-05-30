//
//  PaywallViewController.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import class UIKit.UIViewController
import class UIKit.UIApplication

public protocol PaywallViewController: UIViewController {
    func setPaywallData(paywallModel: PaywallModel)

    func configure(paywallId: PaywallID, presentationController: UIViewController?) async throws
    func configureAndPresent(paywallId: PaywallID, presentationController: UIViewController?) async throws
}

public extension PaywallViewController {
    
    func configure(paywallId: PaywallID, presentationController: UIViewController?) async throws {
        var presentationController = presentationController
        if presentationController == nil {
            presentationController = await UIApplication.shared.currentViewController
        }
        
        guard NetworkMonitor.shared.isConnected else {
            throw InAppPurchaseError.plainError("No internet connection")
        }
        guard await InAppPurchaseManager.isPremium else {
            throw InAppPurchaseError.plainError("User has already got premium")
        }
        guard !(presentationController is PaywallViewController) else {
            throw InAppPurchaseError.plainError("Paywall has already been presented")
        }
        guard !(presentationController is isForbiddenPaywallPresentation) else {
            throw InAppPurchaseError.plainError("Presentation controller isn't allowed to present paywall")
        }
        guard let paywall = await InAppPurchaseManager.getPaywallData(identifier: paywallId) else {
            throw InAppPurchaseError.plainError("No paywall found")
        }
        self.setPaywallData(paywallModel: paywall)
    }
    
    func configureAndPresent(paywallId: PaywallID, presentationController: UIViewController?) async throws {
        try await self.configure(paywallId: paywallId, presentationController: presentationController)
        await MainActor.run { [presentationController] in
            presentationController?.present(self, animated: true)
        }
    }
}
