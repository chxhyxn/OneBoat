//
//  KakaoAuthDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import KakaoSDKAuth
import KakaoSDKUser
import SwiftUI
import OSLog

class KakaoAuthDataSource {
    // 로깅을 위한 Logger 인스턴스 생성
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app.LearnLogin", category: "KakaoAuth")
    
    func signIn() async throws -> UserDTO {
        logger.info("카카오 로그인 시도 시작")
        return try await withCheckedThrowingContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                logger.info("카카오톡 앱으로 로그인 시도")
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        self.logger.error("카카오톡 로그인 실패: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    self.logger.info("카카오톡 로그인 성공, 토큰: \(oauthToken?.accessToken ?? "없음")")
                    self.getUserInfo { result in
                        switch result {
                        case .success(let userDTO):
                            self.logger.info("사용자 정보 조회 성공: ID \(userDTO.id)")
                            continuation.resume(returning: userDTO)
                        case .failure(let error):
                            self.logger.error("사용자 정보 조회 실패: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } else {
                logger.info("카카오 계정으로 로그인 시도 (카카오톡 앱 없음)")
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        self.logger.error("카카오 계정 로그인 실패: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    self.logger.info("카카오 계정 로그인 성공, 토큰: \(oauthToken?.accessToken ?? "없음")")
                    self.getUserInfo { result in
                        switch result {
                        case .success(let userDTO):
                            self.logger.info("사용자 정보 조회 성공: ID \(userDTO.id)")
                            continuation.resume(returning: userDTO)
                        case .failure(let error):
                            self.logger.error("사용자 정보 조회 실패: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
    }
    
    func signOut() async throws {
        logger.info("카카오 로그아웃 시도")
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.logout { error in
                if let error = error {
                    self.logger.error("카카오 로그아웃 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    self.logger.info("카카오 로그아웃 성공")
                    continuation.resume()
                }
            }
        }
    }
    
    private func getUserInfo(completion: @escaping (Result<UserDTO, Error>) -> Void) {
        logger.info("카카오 사용자 정보 요청 시작")
        UserApi.shared.me { user, error in
            if let error = error {
                self.logger.error("카카오 API 사용자 정보 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = user,
                  let id = user.id else {
                let errorMsg = "필수 사용자 데이터 누락"
                self.logger.error("\(errorMsg)")
                completion(.failure(NSError(domain: "KakaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                return
            }
            
            let name = user.properties?["nickname"] ?? "Kakao User"
            let email = user.kakaoAccount?.email
            let profileImageUrl = user.properties?["profile_image"]
            
            self.logger.info("사용자 정보 수신 완료: ID \(id), 이름: \(name), 이메일: \(email ?? "없음")")
            
            let userDTO = UserDTO(
                id: "\(id)",
                name: name,
                email: email,
                profileImageUrl: profileImageUrl,
                provider: "kakao"
            )
            
            completion(.success(userDTO))
        }
    }
}
