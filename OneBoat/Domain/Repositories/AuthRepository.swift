//
//  AuthRepository.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

protocol AuthRepository {
    func signInWithApple() async throws -> (User, Bool) // Returns (user, isNewUser)
    func signInWithGoogle() async throws -> (User, Bool)
    func signInWithKakao() async throws -> (User, Bool)
    func signOut() async throws
    func getCurrentUser() async -> User?
    func loadSavedUser() async -> User?
    
    // Firestore 관련 기능 추가
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?) async throws

    // 자동 로그인 관련 기능
    func saveUserForAutoLogin(user: User) async throws
    func disableAutoLogin() async throws
    func saveUserToFirestore(user: User) async throws
    func saveUserComplete(user: User, enableAutoLogin: Bool) async throws
}
