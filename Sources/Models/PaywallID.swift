//
//  PaywallID.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

/// Extendable PaywallID struct of paywall identifiers
public struct PaywallID : RawRepresentable, Equatable, Hashable {
    public static let main = PaywallID(rawValue: "main_paywall")!
    public static let onboarding = PaywallID(rawValue: "onboarding_paywall")!
    
    public var rawValue: String
    public typealias RawValue = String
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Example of PaywallID extension for custom paywall identifiers
public extension PaywallID {
    
    static let limitedOffer = PaywallID(rawValue: "limited_offer")!

}
