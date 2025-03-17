//
//  NetworkAlertViewModifier.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct NetworkAlertModifier: ViewModifier {
    @ObservedObject var viewModel: NetworkConnectivityViewModel
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            NetworkAlertView(isConnected: viewModel.isConnected)
                .animation(.easeInOut, value: viewModel.isConnected)
        }
    }
}

extension View {
    func networkAlert(viewModel: NetworkConnectivityViewModel) -> some View {
        self.modifier(NetworkAlertModifier(viewModel: viewModel))
    }
}
