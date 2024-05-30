//
//  AdIdsRequester.swift
//
//  Created by Artur on 8.04.24.
//

import ApphudSDK
import AppTrackingTransparency
import AdSupport
import AdServices

public struct AdIdsRequester {
    
    static public func requestIDFA(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
        ATTrackingManager.requestTrackingAuthorization { [self] status in
            guard status == .notDetermined else {
                completion?(status)
                return
            }
            
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            Apphud.setAdvertisingIdentifier(idfa)
            
            trackAppleSearchAds()
            
            completion?(status)
        }
    }
    
    static public func trackAppleSearchAds() {
        Task.detached(priority: .utility) {
            guard let token = try? AAAttribution.attributionToken() else { return }
            await MainActor.run {
                Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: token, callback: nil)
            }
        }
    }
    
}

// MARK: -
// MARK: - Structured Concurrency

public extension AdIdsRequester {
    
    static func requestIDFA() async -> ATTrackingManager.AuthorizationStatus {
        return await withCheckedContinuation { continuation in
            requestIDFA { status in
                continuation.resume(returning: status)
            }
        }
    }
    
}
