//
//  UIApplication+Extensions.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    var currentViewController: UIViewController? {
        return worker(vc: keyWindow?.rootViewController)
    }
    
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    func worker(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return worker(vc: nc.visibleViewController)
        } else if let tbc = vc as? UITabBarController {
            return worker(vc: tbc.selectedViewController)
        } else if let presentedByVC = vc?.presentedViewController {
            return worker(vc: presentedByVC)
        } else {
            return vc
        }
    }
    
}
