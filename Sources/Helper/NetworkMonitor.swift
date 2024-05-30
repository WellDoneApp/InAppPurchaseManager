//
//  NetworkMonitor.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

import Foundation
import Network

public extension Notification.Name {
    static let connectivityStatusChanged = Notification.Name(rawValue: "connectivityStatusChanged")
}

public final class NetworkMonitor {
    public static let shared = NetworkMonitor()

    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor: NWPathMonitor

    public private(set) var isConnected = false
    public private(set) var isExpensive = false
    public private(set) var currentConnectionType: NWInterface.InterfaceType?

    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.isExpensive = path.isExpensive
            self?.currentConnectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
            
            NotificationCenter.default.post(name: .connectivityStatusChanged, object: nil)
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}
