//
//  UserProfileViewModel.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI
import Combine
import OSLog

class UserProfileViewModel: ObservableObject {
    private let authUseCase: AuthUseCase
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "UserProfileViewModel")
    
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        Task {
            await loadUser()
        }
    }
    
    private func loadUser() async {
        await MainActor.run {
            isLoading = true
        }
        
        // 먼저 메모리에 있는 사용자 정보를 확인
        if let user = await authUseCase.getCurrentUser() {
            logger.info("Using current user from memory: \(user.id)")
            await MainActor.run {
                self.user = user
                self.isLoading = false
            }
            return
        }
        
        // 필요한 경우 키체인에서 사용자 정보 로드
        if let savedUser = await authUseCase.loadSavedUser() {
            logger.info("Loaded saved user from Keychain: \(savedUser.id)")
            await MainActor.run {
                self.user = savedUser
                self.isLoading = false
            }
            return
        }
        
        logger.warning("No user found")
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func updateProfile(name: String?) async {
        guard let user = user else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        
        do {
            try await authUseCase.updateUserProfile(
                userId: user.id,
                name: name,
                profileImageUrl: nil
            )
            
            // 사용자 정보를 다시 로드합니다
            await loadUser()
            
            await MainActor.run {
                successMessage = "프로필이 성공적으로 업데이트되었습니다"
                isLoading = false
            }
        } catch {
            logger.error("프로필 업데이트 실패: \(error.localizedDescription)")
            
            await MainActor.run {
                errorMessage = "프로필 업데이트 실패: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func signOut(completion: @escaping () -> Void) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                try await authUseCase.signOut()
                await MainActor.run {
                    isLoading = false
                    completion()
                }
            } catch {
                logger.error("로그아웃 실패: \(error.localizedDescription)")
                
                await MainActor.run {
                    errorMessage = "로그아웃 실패: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
