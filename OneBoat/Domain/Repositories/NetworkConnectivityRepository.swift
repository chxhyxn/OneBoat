//
//  NetworkConnectivityRepository.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import Combine

protocol NetworkConnectivityRepository {
    func observeNetworkConnectivity() -> AnyPublisher<Bool, Never>
}
