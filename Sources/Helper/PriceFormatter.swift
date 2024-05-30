//
//  PriceFormatter.swift
//  ApphudSDKDemo
//
//  Created by Artur Radziukhin on 3.04.24.
//  Copyright © 2024 softeam. All rights reserved.
//

import Foundation
import class StoreKit.SKPaymentQueue

public struct PriceFormatter {
    
    public static func localFormatter(price: Decimal?, currencyCode: String? = nil) -> String? {
        guard let price else { return nil }
        return localFormatter(price: NSDecimalNumber(decimal: price).doubleValue, currencyCode: currencyCode)
    }
    
    public static func localFormatter(price: Double?, currencyCode: String? = nil) -> String? {
        guard let price else { return nil }
        return localFormatter(price: NSNumber(value: price), currencyCode: currencyCode)
    }
    
    public static func localFormatter(price: NSNumber?, currencyCode: String? = nil) -> String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.roundingMode = .halfEven
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = currencyCode
        formatter.currencyGroupingSeparator = "."
        formatter.currencyDecimalSeparator = ","
        return formatter.string(from: price)
    }
    
    public static var storefrontLocale: Locale? {
        guard let storefront = SKPaymentQueue.default().storefront else { return nil }
        let countryCode = storefront.countryCode
        let components = [NSLocale.Key.countryCode.rawValue: countryCode]
        let identifier = NSLocale.localeIdentifier(fromComponents: components)
        let locale = Locale(identifier: identifier)
        return locale
    }
}
