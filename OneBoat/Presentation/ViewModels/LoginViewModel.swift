//
//  LoginViewModel.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI
import Combine
import OSLog

class LoginViewModel: ObservableObject {
    private let authUseCase: AuthUseCase
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "LoginViewModel")
    
    @Published var isLoading = false
    @Published var error: String?
    @Published var user: User?
    @Published var isAuthenticated = false
    
    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        Task {
            await checkCurrentUser()
        }
    }
    
    func checkCurrentUser() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        // 현재 메모리에 로드된 사용자 확인
        if let user = await authUseCase.getCurrentUser() {
            logger.info("User already in memory: \(user.id)")
            await MainActor.run {
                self.user = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            return
        }
        
        // 키체인에서 저장된 사용자 정보 로드
        logger.info("Attempting to load user from Keychain")
        if let savedUser = await authUseCase.loadSavedUser() {
            logger.info("Successfully loaded user from Keychain: \(savedUser.id)")
            await MainActor.run {
                self.user = savedUser
                self.isAuthenticated = true
                self.isLoading = false
            }
            return
        }
        
        // 사용자 정보가 없는 경우
        logger.info("No user found - not authenticated")
        await MainActor.run {
            self.user = nil
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
    
    func signInWithApple() {
        signIn {
            try await self.authUseCase.signInWithApple()
        }
    }
    
    func signInWithGoogle() {
        signIn {
            try await self.authUseCase.signInWithGoogle()
        }
    }
    
    func signInWithKakao() {
        signIn {
            try await self.authUseCase.signInWithKakao()
        }
    }
    
    private func signIn(authMethod: @escaping () async throws -> User) {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.error = nil
            }
            
            do {
                let user = try await authMethod()
                await MainActor.run {
                    self.user = user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
