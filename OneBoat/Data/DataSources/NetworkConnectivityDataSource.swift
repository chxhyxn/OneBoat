//
//  NetworkConnectivityDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//


import Network
import Combine
import SwiftUI

class NetworkConnectivityDataSource {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let connectivitySubject = CurrentValueSubject<Bool, Never>(true)
    
    var connectivityPublisher: AnyPublisher<Bool, Never> {
        return connectivitySubject.eraseToAnyPublisher()
    }
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectivitySubject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
