//
//  NetworkConnectivityRepositoryImpl.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import Combine

class NetworkConnectivityRepositoryImpl: NetworkConnectivityRepository {
    private let networkConnectivityDataSource: NetworkConnectivityDataSource
    
    init(networkConnectivityDataSource: NetworkConnectivityDataSource) {
        self.networkConnectivityDataSource = networkConnectivityDataSource
    }
    
    func observeNetworkConnectivity() -> AnyPublisher<Bool, Never> {
        return networkConnectivityDataSource.connectivityPublisher
    }
}
