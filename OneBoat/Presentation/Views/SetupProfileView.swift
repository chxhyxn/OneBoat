//
//  SetupProfileView.swift
//  OneBoat
//
//  Created by SeanCho on 3/18/25.
//


//
//  SetupProfileView.swift
//  OneBoat
//

import SwiftUI

struct SetupProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var name: String = ""
    @State private var navigateToProfile = false
    @State private var showNameError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Text("프로필 설정")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                Text("환영합니다! 사용할 이름을 설정해주세요.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("이름", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                if showNameError {
                    Text("이름을 입력해주세요")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                Button {
                    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showNameError = true
                    } else {
                        showNameError = false
                        saveProfile()
                    }
                } label: {
                    Text("계속하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                UserProfileView(viewModel: viewModel)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func saveProfile() {
        Task {
            guard let user = viewModel.user else { return }
            
            // 먼저 이름 업데이트
            await viewModel.updateProfile(name: name)
            
            if viewModel.errorMessage == nil {
                // 이름 업데이트 성공 후 사용자를 Firestore에 저장
                do {
                    let authUseCase = DependencyContainer.shared.authUseCase
                    
                    // AuthRepository 구현체에 접근
                    if let authRepo = Mirror(reflecting: authUseCase).children.first(where: { $0.label == "authRepository" })?.value as? AuthRepositoryImpl,
                       let updatedUser = await authUseCase.getCurrentUser() {
                        try await authRepo.saveUserToFirestore(user: updatedUser)
                    }
                    
                    navigateToProfile = true
                } catch {
                    // 에러 처리
                    viewModel.errorMessage = "사용자 정보 저장 실패: \(error.localizedDescription)"
                }
            }
        }
    }
}
