//
//  UserDTO.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct UserDTO: Codable {
    let id: String
    let name: String
    let email: String?
    let profileImageUrl: String?
    let provider: String
    
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            profileImageUrl: profileImageUrl != nil ? URL(string: profileImageUrl!) : nil,
            provider: mapProvider(provider)
        )
    }
    
    private func mapProvider(_ provider: String) -> AuthProvider {
        switch provider {
        case "apple": return .apple
        case "google": return .google
        case "kakao": return .kakao
        default: return .apple
        }
    }
}
