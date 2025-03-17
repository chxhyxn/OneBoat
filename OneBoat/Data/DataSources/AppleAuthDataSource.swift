//
//  AppleAuthDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI
import AuthenticationServices
import os.log

class AppleAuthDataSource: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var continuation: CheckedContinuation<UserDTO, Error>?
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "AppleAuth")
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        logger.info("Presenting Apple login authorization controller")
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
    
    func signIn() async throws -> UserDTO {
        logger.info("Starting Apple sign-in process")
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            logger.info("Requesting scopes: full name and email")
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        logger.info("Apple authorization completed successfully")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            logger.info("User ID: \(userId)")
            
            // 이름 정보 로깅
            if let givenName = appleIDCredential.fullName?.givenName {
                logger.info("Given name: \(givenName)")
            } else {
                logger.info("Given name: nil")
            }
            
            if let familyName = appleIDCredential.fullName?.familyName {
                logger.info("Family name: \(familyName)")
            } else {
                logger.info("Family name: nil")
            }
            
            let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            logger.info("Full name: \(fullName.isEmpty ? "<empty>" : fullName)")
            
            // 이메일 정보 로깅
            if let email = appleIDCredential.email {
                logger.info("Email: \(email)")
            } else {
                logger.info("Email: nil")
            }
            
            // 실시간 인증 정보 로깅
            if let authorizationCode = appleIDCredential.authorizationCode {
                let authCode = String(data: authorizationCode, encoding: .utf8) ?? "<invalid encoding>"
                logger.info("Authorization code: \(authCode)")
            } else {
                logger.info("Authorization code: nil")
            }
            
            if let identityToken = appleIDCredential.identityToken {
                let token = String(data: identityToken, encoding: .utf8) ?? "<invalid encoding>"
                logger.info("Identity token: \(token)")
            } else {
                logger.info("Identity token: nil")
            }
            
            // UserDTO 생성
            let userDTO = UserDTO(
                id: userId,
                name: fullName.isEmpty ? "Apple User" : fullName,
                email: appleIDCredential.email,
                profileImageUrl: nil,
                provider: "apple"
            )
            
            logger.info("Created UserDTO - id: \(userDTO.id), name: \(userDTO.name), email: \(userDTO.email ?? "nil"), provider: \(userDTO.provider)")
            
            continuation?.resume(returning: userDTO)
            continuation = nil
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Apple authorization failed with error: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
