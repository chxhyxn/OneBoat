//
//  DependencyContainer.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {
        // 초기화 필요한 경우 여기에 추가
    }
    
    // 데이터 소스
    lazy var appleAuthDataSource: AppleAuthDataSource = {
        return AppleAuthDataSource()
    }()
    
    lazy var googleAuthDataSource: GoogleAuthDataSource = {
        return GoogleAuthDataSource()
    }()
    
    lazy var kakaoAuthDataSource: KakaoAuthDataSource = {
        return KakaoAuthDataSource()
    }()
    
    lazy var keychainDataSource: KeychainDataSource = {
        return KeychainDataSource()
    }()
    
    lazy var networkConnectivityDataSource: NetworkConnectivityDataSource = {
        return NetworkConnectivityDataSource()
    }()
    
    lazy var userFirestoreDataSource: UserFirestoreDataSource = {
        return UserFirestoreDataSource()
    }()
    
    // 리포지토리
    lazy var authRepository: AuthRepository = {
        return AuthRepositoryImpl(
            appleAuthDataSource: appleAuthDataSource,
            googleAuthDataSource: googleAuthDataSource,
            kakaoAuthDataSource: kakaoAuthDataSource,
            keychainDataSource: keychainDataSource,
            firestoreDataSource: userFirestoreDataSource
        )
    }()
    
    lazy var networkConnectivityRepository: NetworkConnectivityRepository = {
        return NetworkConnectivityRepositoryImpl(networkConnectivityDataSource: networkConnectivityDataSource)
    }()
    
    // 유스케이스
    lazy var authUseCase: AuthUseCase = {
        return AuthUseCaseImpl(authRepository: authRepository)
    }()
    
    lazy var networkConnectivityUseCase: NetworkConnectivityUseCase = {
        return NetworkConnectivityUseCaseImpl(networkConnectivityRepository: networkConnectivityRepository)
    }()
    
    // 뷰모델
    lazy var networkConnectivityViewModel: NetworkConnectivityViewModel = {
        return NetworkConnectivityViewModel(networkConnectivityUseCase: networkConnectivityUseCase)
    }()
    
    lazy var loginViewModel: LoginViewModel = {
        return LoginViewModel(authUseCase: authUseCase)
    }()
    
    lazy var userProfileViewModel: UserProfileViewModel = {
        return UserProfileViewModel(authUseCase: authUseCase)
    }()
}
