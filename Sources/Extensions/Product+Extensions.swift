//
//  Product+Extension.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import Foundation
import struct StoreKit.Product

// MARK: -
// MARK: - Free Trial

public extension Product {
    
    func isFreeTrialAvailable(isEligible: Bool) -> Bool {
        guard self.subscription?.introductoryOffer?.paymentMode == .freeTrial,
              isEligible == true
        else {
            return false
        }
        
        return true
    }
    
    var isFreeTrialAvailable: Bool  {
        get async {
            guard self.subscription?.introductoryOffer?.paymentMode == .freeTrial,
                  await self.subscription?.isEligibleForIntroOffer == true
            else {
                return false
            }
            
            return true
        }
    }
    
    var freeTrialUnitValue: Int? {
        guard let value = self.subscription?.introductoryOffer?.period.value else { return nil }
        return value
    }

}

// MARK: -
// MARK: - Period Localization

public extension Product {
    
    var localizedPeriod: String? {
        return trueUnit?.localizedPeriod
    }
    
    var localizedPeriodUnit: String? {
        return trueUnit?.localizedPeriodUnit
    }
    
}

// MARK: -
// MARK: - Localized Price

public extension Product {
    
    var localizedPrice: String? {
        return PriceFormatter.localFormatter(price: self.price, currencyCode: self.priceFormatStyle.currencyCode)
    }
    
    var localizedDailyPrice: String? {
        return PriceFormatter.localFormatter(price: self.dailyPrice, currencyCode: self.priceFormatStyle.currencyCode)
    }
    
    var localizedWeeklyPrice: String? {
        return PriceFormatter.localFormatter(price: self.weeklyPrice, currencyCode: self.priceFormatStyle.currencyCode)
    }
    
    var localizedMonthlyPrice: String? {
        return PriceFormatter.localFormatter(price: self.monthlyPrice, currencyCode: self.priceFormatStyle.currencyCode)
    }
    
    var localizedYearlyPrice: String? {
        return PriceFormatter.localFormatter(price: self.yearlyPrice, currencyCode: self.priceFormatStyle.currencyCode)
    }
    
}

// MARK: -
// MARK: - Converting price to smaller unit

public extension Product {
    
    var dailyPrice: Decimal? {
        guard let unit = self.trueUnit else { return nil }
        switch unit {
            case .day:
                return self.price
            case .week:
                return self.price / 7
            case .month:
                return self.price / 30
            case .year:
                return self.price / 365
            @unknown default:
                return nil
        }
    }
    
    var weeklyPrice: Decimal? {
        guard let unit = self.trueUnit else { return nil }
        switch unit {
            case .day:
                return nil
            case .week:
                return self.price
            case .month:
                return self.price / 4
            case .year:
                return self.price / 52
            @unknown default:
                return nil
        }
    }
    
    var monthlyPrice: Decimal? {
        guard let unit = self.trueUnit else { return nil }
        switch unit {
            case .day:
                return nil
            case .week:
                return nil
            case .month:
                return self.price
            case .year:
                return self.price / 12
            @unknown default:
                return nil
        }
    }
    
    var yearlyPrice: Decimal? {
        guard let unit = self.trueUnit else { return nil }
        switch unit {
            case .day:
                return nil
            case .week:
                return nil
            case .month:
                return nil
            case .year:
                return self.price
            @unknown default:
                return nil
        }
    }
    
}

// MARK: -
// MARK: - Predefined Strings

public extension Product {
    
    /// Format: "3 days free trial then $4.99 per week" or  "$4.99 per week"
    func introOfferIfAvailableThenPrice() async -> String? {
        if self.subscription?.introductoryOffer != nil, await subscription?.isEligibleForIntroOffer == true {
            return introOfferPeriodDescriptionThenPrice
        } else {
            return pricePerPeriodUnitString()
        }
    }
    
    /// Format: "3 days free trial then $4.99 per week" or  "$4.99 per week"
    func introOfferIfAvailableThenPrice(isEligible: Bool) -> String? {
        if self.subscription?.introductoryOffer != nil, isEligible {
            return introOfferPeriodDescriptionThenPrice
        } else {
            return pricePerPeriodUnitString()
        }
    }
    
    /// Format: "3 days free, trial then $4.99 per week"
    var introOfferPeriodDescriptionThenPrice: String? {
        guard let introOffer = self.subscription?.introductoryOffer,
              let pricePerPeriodUnitString = pricePerPeriodUnitString()
        else { return nil }
        let then = String(localized: "then")
        
        switch introOffer.paymentMode {
            case .freeTrial:
                guard let freeTrialPeriodString else { return nil }
                return "\(freeTrialPeriodString) \(then) \(pricePerPeriodUnitString)"
                
            case .payUpFront, .payAsYouGo:
                guard let paidIntroOfferPeriodString else { return nil }
                return "\(paidIntroOfferPeriodString) \(then) \(pricePerPeriodUnitString)"
                
            default: return nil
        }
    }
    
    /// Format: "3 days free trial" or "9.99 $ for the 1st month"
    var introOfferPeriodDescription: String? {
        guard let introOffer = self.subscription?.introductoryOffer else { return nil }
        switch introOffer.paymentMode {
            case .freeTrial:
                return freeTrialPeriodString
                
            case .payUpFront, .payAsYouGo:
                return paidIntroOfferPeriodString
                
            default: return nil
        }
    }
    
    /// Format: "3 days free trial"
    var freeTrialPeriodString: String? {
        guard let introOffer = self.subscription?.introductoryOffer,
              introOffer.paymentMode == .freeTrial,
              let introPeriodString = introPeriodString
        else { return nil }
        
        return String(localized: "N periods free trial", defaultValue: "\(introPeriodString) free trial", comment: "Format: \"3 days free trial")
    }
    
    /// Format: "3 days" or "1 month"
    var introPeriodString: String? {
        guard let introOffer = self.subscription?.introductoryOffer else { return nil }
        
        let periodValue = introOffer.period.value
        var introString = introOffer.period.unit.localizedPeriodUnit(periodValue: periodValue)
        if periodValue == 1 && introOffer.period.unit == .week {
            introString = Product.SubscriptionPeriod.Unit.day.localizedPeriodUnit(periodValue: 7)
        }
        return introString
    }
    
    /// Format: "9.99 $ for the 1st month" or "6.99 $ for the first 2 weeks"
    private var paidIntroOfferPeriodString: String? {
        guard let introOffer = self.subscription?.introductoryOffer,
              let formattedPrice = PriceFormatter.localFormatter(price: introOffer.price, currencyCode: self.priceFormatStyle.currencyCode)
        else { return nil }
        
        switch introOffer.paymentMode {
            case .payAsYouGo, .payUpFront:
                return String(
                    format: String(localized: "Paid intro offer period string", defaultValue: "%@ for the %lld %@", comment: "Format: \"9.99 $ for the first 2 weeks)"),
                    formattedPrice,
                    introOffer.periodCount,
                    introOffer.period.unit.localizedPeriodUnit(periodValue: introOffer.periodCount)
                )
                
            default: return nil
        }
    }
    
    /// Format: "per week" or "per month"
    func perPeriodUnitString(unit: Product.SubscriptionPeriod.Unit? = nil) -> String? {
        guard let unit = unit ?? self.trueUnit else { return nil }
        let per = String(localized: "\"per\" period preposition", defaultValue: "per", comment: "Format: \"per month\"")
        return "\(per) \(unit.localizedPeriodUnit.lowercased())"
    }
    
    /// Format: "9.99 $ per week" or  "9.99 $/week" if set perText = "/"
    func pricePerPeriodUnitString(unit: Product.SubscriptionPeriod.Unit? = nil, perText: String? = nil) -> String? {
        guard let unit = unit ?? self.trueUnit else { return nil }
        var price: String?
        switch unit {
            case .day:
                price = localizedDailyPrice
            case .week:
                price = localizedWeeklyPrice
            case .month:
                price = localizedMonthlyPrice
            case .year:
                price = localizedYearlyPrice
            @unknown default:
                return nil
        }
        guard let price else { return nil }
        if let perText {
            return "\(price)\(perText)\(unit.localizedPeriodUnit.lowercased())"
            
        } else if let perPeriodUnitString = perPeriodUnitString() {
            return "\(price) \(perPeriodUnitString)"
            
        } else {
            return nil
        }
    }
    
    private var trueUnit: Product.SubscriptionPeriod.Unit? {
        guard let unit = self.subscription?.subscriptionPeriod.unit else { return nil }
        
        switch unit {
            case .day:
                if let value = self.subscription?.subscriptionPeriod.value, value == 7 {
                    return .week
                } else {
                    return .day
                }
            case .week:
                return .week
            case .month:
                return .month
            case .year:
                return .year
            @unknown default:
                return nil
        }
    }
    
}

public extension Product.SubscriptionPeriod.Unit {
    
    /// Format: "Daily", "Weekly", "Monthly", "Yearly"
    var localizedPeriod: String {
        switch self {
            case .day:
                return String(localized: "Daily")
            case .week:
                return String(localized: "Weekly")
            case .month:
                return String(localized: "Monthly")
            case .year:
                return String(localized: "Yearly")
            @unknown default:
                return ""
        }
    }
    
    /// Format: "Day", "Week", "Month", "Year"
    var localizedPeriodUnit: String {
        switch self {
            case .day:
                return String(localized: "Day")
            case .week:
                return String(localized: "Week")
            case .month:
                return String(localized: "Month")
            case .year:
                return String(localized: "Year")
            @unknown default:
                return ""
        }
    }
    
    
    func localizedPeriodUnit(periodValue: Int) -> String {
        switch self {
            case .day:
                return String(localized: "\(periodValue) day", comment: "Format: \"3 days\"")
            case .week:
                return String(localized: "\(periodValue) week", comment: "Format: \"3 weeks\"")
            case .month:
                return String(localized: "\(periodValue) month", comment: "Format: \"3 months")
            case .year:
                return String(localized: "\(periodValue) year", comment: "Format: \"3 years\"")
            @unknown default:
                return ""
        }
    }
    
}
