//
//  UserProfileView.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("사용자 프로필")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                if let user = viewModel.user {
                    // 프로필 이미지
                    Group {
                        if let profileImageUrl = user.profileImageUrl {
                            AsyncImage(url: profileImageUrl) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding(.top, 20)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                    }
                    
                    // 사용자 정보
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(icon: "person.fill", title: "이름", value: user.name)
                        
                        if let email = user.email {
                            InfoRow(icon: "envelope.fill", title: "이메일", value: email)
                        }
                        
                        InfoRow(icon: "link", title: "로그인 제공자", value: {
                            switch user.provider {
                            case .apple: return "Apple"
                            case .google: return "Google"
                            case .kakao: return "카카오"
                            }
                        }())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // 로그아웃 버튼
                    Button {
                        viewModel.signOut {
                            navigateToLogin = true
                        }
                    } label: {
                        Text("로그아웃")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                } else {
                    Text("사용자 정보를 불러올 수 없습니다")
                        .foregroundColor(.red)
                    
                    Button("로그인 화면으로 돌아가기") {
                        navigateToLogin = true
                    }
                    .padding()
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(viewModel: LoginViewModel(authUseCase: DependencyContainer.shared.authUseCase))
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
