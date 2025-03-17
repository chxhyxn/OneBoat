//
//  KeychainDataSource.swift
//  LearnLogin
//
//  Created by SeanCho on 3/17/25.
//

import Foundation
import Security
import OSLog

class KeychainDataSource {
    private let logger = Logger(subsystem: "com.yourapp.LearnLogin", category: "KeychainDataSource")
    private let service = "com.seancho.LearnLogin"
    
    // MARK: - Save User to Keychain
    func saveUser(_ userDTO: UserDTO) {
        logger.info("Saving user to Keychain: \(userDTO.id)")
        
        // Convert UserDTO to Data
        guard let userData = try? JSONEncoder().encode(userDTO) else {
            logger.error("Failed to encode user data for Keychain")
            return
        }
        
        // Set query attributes
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "currentUser",
            kSecValueData as String: userData
        ] as [String: Any]
        
        // Delete existing data before saving
        SecItemDelete(query as CFDictionary)
        
        // Add new data
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            logger.info("User data saved to Keychain successfully")
        } else {
            logger.error("Failed to save user data to Keychain: \(status)")
        }
    }
    
    // MARK: - Retrieve User from Keychain
    func getUser() -> UserDTO? {
        logger.info("Retrieving user from Keychain")
        
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "currentUser",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ] as [String: Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let userData = result as? Data,
              let userDTO = try? JSONDecoder().decode(UserDTO.self, from: userData) else {
            if status != errSecItemNotFound {
                logger.error("Failed to retrieve user from Keychain: \(status)")
            } else {
                logger.info("No user found in Keychain")
            }
            return nil
        }
        
        logger.info("Successfully retrieved user from Keychain: \(userDTO.id)")
        return userDTO
    }
    
    // MARK: - Delete User from Keychain
    func deleteUser() {
        logger.info("Deleting user from Keychain")
        
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "currentUser"
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            logger.info("User data deleted from Keychain successfully")
        } else {
            logger.error("Failed to delete user data from Keychain: \(status)")
        }
    }
}
