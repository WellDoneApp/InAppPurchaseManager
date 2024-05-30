//
//  PaywallModel.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import Foundation
import struct StoreKit.Product
import class ApphudSDK.ApphudPaywall

public struct PaywallModel {
    public var paywallID: String { apphudPaywall.identifier }
    public let apphudPaywall: ApphudPaywall
    public let products: [Product]
    public let introOfferEligiblities: [String: Bool]
    public let config: Config?
    
    public struct Config {
        public let title: String?
        public let subtitle: String?
        public let best_offer_text: String?
        public let purchase_button_title: String?
        public let purchase_button_title_trial: String?
        public let close_button_color: String?
        public let is_close_button_hidden: Bool
        public let is_underlined_limited_version: Bool
        public internal(set) var rawJson: [String: Any] = [:]
    }
    
    init(apphudPaywall: ApphudPaywall, products: [Product]) async {
        self.apphudPaywall = apphudPaywall
        self.products = products
        
        var introOfferEligiblities: [String: Bool] = [:]
        for product in products {
            
            introOfferEligiblities[product.id] = await product.subscription?.isEligibleForIntroOffer
        }
        self.introOfferEligiblities = introOfferEligiblities
        
        if let configJSON = apphudPaywall.json,
           let configData = try? JSONSerialization.data(withJSONObject: configJSON),
           var config = try? JSONDecoder().decode(Config.self, from: configData) {
            config.rawJson = configJSON
            self.config = config
        } else {
            self.config = nil
        }
    }
}

public extension PaywallModel {
    
    var bestOfferProduct: Product? {
        guard !products.isEmpty else { return nil }
        if let bestOfferProductId = config?.rawJson["best_offer_product_id"] as? String, let product = products.first(where: {$0.id == bestOfferProductId}) {
            return product
            
        } else {
            let sortedProducts = products.sorted {($0.dailyPrice ?? 0) < ($1.dailyPrice ?? 0)}
            return sortedProducts.first
        }
    }
    
}

extension PaywallModel.Config: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case title, subtitle, is_close_button_hidden, purchase_button_title, best_offer_text,
             purchase_button_title_trial, close_button_color, is_underlined_limited_version
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try? container.decodeIfPresent(String.self, forKey: .subtitle)
        self.purchase_button_title = try? container.decodeIfPresent(String.self, forKey: .purchase_button_title)
        self.purchase_button_title_trial = (try? container.decodeIfPresent(String.self, forKey: .purchase_button_title_trial)) ?? self.purchase_button_title
        self.close_button_color = try? container.decodeIfPresent(String.self, forKey: .close_button_color)
        self.is_close_button_hidden = (try? container.decodeIfPresent(Bool.self, forKey: .is_close_button_hidden)) ?? false
        self.is_underlined_limited_version = (try? container.decodeIfPresent(Bool.self, forKey: .is_underlined_limited_version)) ?? false
        if let best_offer_text = try? container.decodeIfPresent(String.self, forKey: .best_offer_text) {
            self.best_offer_text = best_offer_text
        } else {
            self.best_offer_text = String(localized: "Best offer")
        }
    }
    
}
