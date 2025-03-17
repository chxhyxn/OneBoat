//
//  NetworkAlertView.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct NetworkAlertView: View {
    var isConnected: Bool
    
    var body: some View {
        if !isConnected {
            VStack {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    
                    Text("네트워크 연결이 끊겼습니다")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.red)
                .transition(.move(edge: .top).combined(with: .opacity))
                
                Spacer()
            }
            .zIndex(100) // Ensure it stays on top
        }
    }
}
