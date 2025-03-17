//
//  ContentView.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView(viewModel: DependencyContainer.shared.loginViewModel)
    }
}
