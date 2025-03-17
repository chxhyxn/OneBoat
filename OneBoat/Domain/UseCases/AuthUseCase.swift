//
//  AuthUseCase.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

protocol AuthUseCase {
    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithKakao() async throws -> User
    func signOut() async throws
    func getCurrentUser() async -> User?
    func loadSavedUser() async -> User?
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?) async throws
}

class AuthUseCaseImpl: AuthUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func signInWithApple() async throws -> User {
        return try await authRepository.signInWithApple()
    }
    
    func signInWithGoogle() async throws -> User {
        return try await authRepository.signInWithGoogle()
    }
    
    func signInWithKakao() async throws -> User {
        return try await authRepository.signInWithKakao()
    }
    
    func signOut() async throws {
        try await authRepository.signOut()
    }
    
    func getCurrentUser() async -> User? {
        return await authRepository.getCurrentUser()
    }
    
    func loadSavedUser() async -> User? {
        return await authRepository.loadSavedUser()
    }
    
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?) async throws {
        try await authRepository.updateUserProfile(userId: userId, name: name, profileImageUrl: profileImageUrl)
    }
}
