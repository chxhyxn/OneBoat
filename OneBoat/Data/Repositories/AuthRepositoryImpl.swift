//
//  AuthRepositoryImpl.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import OSLog

class AuthRepositoryImpl: AuthRepository {
    private let appleAuthDataSource: AppleAuthDataSource
    private let googleAuthDataSource: GoogleAuthDataSource
    private let kakaoAuthDataSource: KakaoAuthDataSource
    private let keychainDataSource: KeychainDataSource
    private let firestoreDataSource: UserFirestoreDataSource
    private var currentUser: User?
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "AuthRepository")
    
    init(
        appleAuthDataSource: AppleAuthDataSource,
        googleAuthDataSource: GoogleAuthDataSource,
        kakaoAuthDataSource: KakaoAuthDataSource,
        keychainDataSource: KeychainDataSource,
        firestoreDataSource: UserFirestoreDataSource
    ) {
        self.appleAuthDataSource = appleAuthDataSource
        self.googleAuthDataSource = googleAuthDataSource
        self.kakaoAuthDataSource = kakaoAuthDataSource
        self.keychainDataSource = keychainDataSource
        self.firestoreDataSource = firestoreDataSource
    }
    
    func signInWithApple() async throws -> User {
        logger.info("Signing in with Apple")
        let userDTO = try await appleAuthDataSource.signIn()
        
        // Firestore에 사용자 데이터 저장
        try await firestoreDataSource.saveUser(userDTO)
        
        // Keychain에 사용자 데이터 저장
        keychainDataSource.saveUser(userDTO)
        
        let user = userDTO.toDomain()
        currentUser = user
        return user
    }
    
    func signInWithGoogle() async throws -> User {
        logger.info("Signing in with Google")
        let userDTO = try await googleAuthDataSource.signIn()
        
        // Firestore에 사용자 데이터 저장
        try await firestoreDataSource.saveUser(userDTO)
        
        // Keychain에 사용자 데이터 저장
        keychainDataSource.saveUser(userDTO)
        
        let user = userDTO.toDomain()
        currentUser = user
        return user
    }
    
    func signInWithKakao() async throws -> User {
        logger.info("Signing in with Kakao")
        let userDTO = try await kakaoAuthDataSource.signIn()
        
        // Firestore에 사용자 데이터 저장
        try await firestoreDataSource.saveUser(userDTO)
        
        // Keychain에 사용자 데이터 저장
        keychainDataSource.saveUser(userDTO)
        
        let user = userDTO.toDomain()
        currentUser = user
        return user
    }
    
    func signOut() async throws {
        logger.info("Signing out user")
        // 현재 로그인된 제공자에 따라 로그아웃
        if let user = currentUser {
            switch user.provider {
            case .google:
                googleAuthDataSource.signOut()
            case .kakao:
                try await kakaoAuthDataSource.signOut()
            case .apple:
                // Apple은 별도의 로그아웃 처리가 필요 없음
                break
            }
        }
        
        // 키체인에서 사용자 정보 삭제
        keychainDataSource.deleteUser()
        currentUser = nil
    }
    
    func getCurrentUser() async -> User? {
        return currentUser
    }
    
    func loadSavedUser() async -> User? {
        logger.info("Loading saved user from Keychain")
        
        // 이미 메모리에 로드된 사용자가 있는지 확인
        if let currentUser = currentUser {
            logger.info("Using already loaded user: \(currentUser.id)")
            return currentUser
        }
        
        // Keychain에서 사용자 정보 로드
        if let userDTO = keychainDataSource.getUser() {
            logger.info("Loaded user from Keychain: \(userDTO.id)")
            
            // 사용자 정보를 메모리에 저장
            let user = userDTO.toDomain()
            currentUser = user
            return user
        }
        
        logger.info("No saved user found")
        return nil
    }
    
    // Firestore에서 사용자 프로필 정보 업데이트
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?) async throws {
        logger.info("Updating user profile for \(userId)")
        var updateData: [String: Any] = [:]
        
        if let name = name {
            updateData["name"] = name
        }
        
        if let profileImageUrl = profileImageUrl {
            updateData["profileImageUrl"] = profileImageUrl
        }
        
        if !updateData.isEmpty {
            try await firestoreDataSource.updateUserInfo(id: userId, additionalInfo: updateData)
            
            // 현재 사용자 객체도 업데이트
            if var user = currentUser, user.id == userId {
                if let name = name {
                    user = User(
                        id: user.id,
                        name: name,
                        email: user.email,
                        profileImageUrl: user.profileImageUrl,
                        provider: user.provider
                    )
                }
                currentUser = user
                
                // 키체인에 저장된 사용자 정보도 업데이트
                if let userDTO = keychainDataSource.getUser() {
                    let updatedUserDTO = UserDTO(
                        id: userDTO.id,
                        name: name ?? userDTO.name,
                        email: userDTO.email,
                        profileImageUrl: profileImageUrl ?? userDTO.profileImageUrl,
                        provider: userDTO.provider
                    )
                    keychainDataSource.saveUser(updatedUserDTO)
                }
            }
        }
    }
}
