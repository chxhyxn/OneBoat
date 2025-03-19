//
//  LoginView.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var navigateToProfile = false
    @State private var navigateToSetupProfile = false
    @State private var autoLogin = true  // Default to true for better UX
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("소셜 로그인")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Apple 로그인 버튼
                    Button {
                        viewModel.signInWithApple(enableAutoLogin: autoLogin)
                    } label: {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.title2)
                            Text("Apple로 로그인")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Google 로그인 버튼
                    Button {
                        viewModel.signInWithGoogle(enableAutoLogin: autoLogin)
                    } label: {
                        HStack {
                            Text("G")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.red)
                                .clipShape(Circle())
                            
                            Text("Google로 로그인")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // 카카오 로그인 버튼
                    Button {
                        viewModel.signInWithKakao(enableAutoLogin: autoLogin)
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.title2)
                            Text("카카오로 로그인")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                
                // 자동 로그인 체크박스
                Toggle(isOn: $autoLogin) {
                    Text("자동 로그인")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
            .task {
                await viewModel.checkCurrentUser()
            }
            .onChange(of: viewModel.isAuthenticated) { newValue in
                if viewModel.isNewUser {
                    navigateToSetupProfile = true
                } else {
                    navigateToProfile = true
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                UserProfileView(viewModel: UserProfileViewModel(authUseCase: DependencyContainer.shared.authUseCase))
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSetupProfile) {
                SetupProfileView(viewModel: UserProfileViewModel(authUseCase: DependencyContainer.shared.authUseCase))
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// CheckboxToggleStyle for the auto-login toggle
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20, weight: .bold))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}
