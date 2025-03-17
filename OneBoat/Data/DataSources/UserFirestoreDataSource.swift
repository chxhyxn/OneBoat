//
//  UserFirestoreDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/16/25.
//

import FirebaseFirestore
import OSLog

class UserFirestoreDataSource {
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "UserFirestore")
    private let userCollection = "users"
    
    // 사용자 저장 또는 업데이트
    func saveUser(_ userDTO: UserDTO) async throws {
        logger.info("Saving user: \(userDTO.id)")
        
        let userRef = db.collection(userCollection).document(userDTO.id)
        
        // Firestore에 저장할 데이터 변환
        let userData: [String: Any] = [
            "id": userDTO.id,
            "name": userDTO.name,
            "email": userDTO.email ?? NSNull(),
            "profileImageUrl": userDTO.profileImageUrl ?? NSNull(),
            "provider": userDTO.provider,
            "lastLogin": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        do {
            try await userRef.setData(userData, merge: true)
            logger.info("Successfully saved user data for \(userDTO.id)")
        } catch {
            logger.error("Error saving user data: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 사용자 가져오기
    func getUser(id: String) async throws -> UserDTO? {
        logger.info("Fetching user: \(id)")
        
        do {
            let document = try await db.collection(userCollection).document(id).getDocument()
            
            guard document.exists, let data = document.data() else {
                logger.info("User \(id) not found in Firestore")
                return nil
            }
            
            // Firestore 데이터에서 UserDTO로 변환
            let userDTO = UserDTO(
                id: id,
                name: data["name"] as? String ?? "Unknown User",
                email: data["email"] as? String,
                profileImageUrl: data["profileImageUrl"] as? String,
                provider: data["provider"] as? String ?? "unknown"
            )
            
            logger.info("Successfully fetched user \(id)")
            return userDTO
            
        } catch {
            logger.error("Error fetching user: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 사용자 추가 정보 업데이트 (예: 프로필 정보 업데이트)
    func updateUserInfo(id: String, additionalInfo: [String: Any]) async throws {
        logger.info("Updating user info for: \(id)")
        
        let userRef = db.collection(userCollection).document(id)
        
        // 업데이트할 데이터에 타임스탬프 추가
        var updateData = additionalInfo
        updateData["updatedAt"] = Timestamp()
        
        do {
            try await userRef.updateData(updateData)
            logger.info("Successfully updated user info for \(id)")
        } catch {
            logger.error("Error updating user info: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 사용자 데이터 삭제 (탈퇴 등의 경우)
    func deleteUser(id: String) async throws {
        logger.info("Deleting user: \(id)")
        
        do {
            try await db.collection(userCollection).document(id).delete()
            logger.info("Successfully deleted user \(id)")
        } catch {
            logger.error("Error deleting user: \(error.localizedDescription)")
            throw error
        }
    }
}
