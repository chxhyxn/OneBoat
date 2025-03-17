//
//  NetworkConnectivityUseCase.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import Combine

protocol NetworkConnectivityUseCase {
    func observeNetworkConnectivity() -> AnyPublisher<Bool, Never>
}

class NetworkConnectivityUseCaseImpl: NetworkConnectivityUseCase {
    private let networkConnectivityRepository: NetworkConnectivityRepository
    
    init(networkConnectivityRepository: NetworkConnectivityRepository) {
        self.networkConnectivityRepository = networkConnectivityRepository
    }
    
    func observeNetworkConnectivity() -> AnyPublisher<Bool, Never> {
        return networkConnectivityRepository.observeNetworkConnectivity()
    }
}
