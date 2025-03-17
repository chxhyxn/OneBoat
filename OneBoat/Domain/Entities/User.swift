//
//  User.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI

struct User: Identifiable {
    let id: String
    let name: String
    let email: String?
    let profileImageUrl: URL?
    let provider: AuthProvider
}

enum AuthProvider {
    case apple
    case google
    case kakao
}
