//
//  GoogleAuthDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import GoogleSignIn
import OSLog

class GoogleAuthDataSource {
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "GoogleAuth")
    
    func signIn() async throws -> UserDTO {
        logger.info("Starting Google sign-in process")
        
        return try await withCheckedThrowingContinuation { [self] continuation in
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
                self.logger.error("Failed to get root view controller: \(error.localizedDescription)")
                continuation.resume(throwing: error)
                return
            }
            
            self.logger.debug("Presenting Google sign-in UI with root view controller")
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [self] result, error in
                if let error = error {
                    self.logger.error("Google sign-in failed with error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                self.logger.info("Google sign-in completed, processing user data")
                
                guard let user = result?.user else {
                    let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user result returned"])
                    self.logger.error("Google sign-in failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let userId = user.userID else {
                    let error = NSError(domain: "GoogleSignIn", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing user ID"])
                    self.logger.error("Google sign-in failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let profile = user.profile else {
                    let error = NSError(domain: "GoogleSignIn", code: -3, userInfo: [NSLocalizedDescriptionKey: "Missing user profile"])
                    self.logger.error("Google sign-in failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                self.logger.debug("Creating UserDTO with Google user data")
                
                let userDTO = UserDTO(
                    id: userId,
                    name: profile.name,
                    email: profile.email,
                    profileImageUrl: profile.imageURL(withDimension: 100)?.absoluteString,
                    provider: "google"
                )
                
                self.logger.info("Google sign-in successful for user \(userId)")
                
                if let email = userDTO.email {
                    self.logger.debug("User email: \(email)")
                } else {
                    self.logger.debug("No email provided in Google profile")
                }
                
                if profile.imageURL(withDimension: 100) != nil {
                    self.logger.debug("Profile image URL available")
                } else {
                    self.logger.debug("No profile image URL available")
                }
                
                continuation.resume(returning: userDTO)
            }
        }
    }
    
    func signOut() {
        logger.info("Signing out from Google")
        GIDSignIn.sharedInstance.signOut()
        logger.info("Successfully signed out from Google")
    }
}
