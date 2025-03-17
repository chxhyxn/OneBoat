//
//  NetworkConnectivityViewModel.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import Combine
import SwiftUI

class NetworkConnectivityViewModel: ObservableObject {
    private let networkConnectivityUseCase: NetworkConnectivityUseCase
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected: Bool = true
    
    init(networkConnectivityUseCase: NetworkConnectivityUseCase) {
        self.networkConnectivityUseCase = networkConnectivityUseCase
        
        networkConnectivityUseCase.observeNetworkConnectivity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
            }
            .store(in: &cancellables)
    }
}
