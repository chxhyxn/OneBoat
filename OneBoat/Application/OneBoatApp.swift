//
//  LearnLoginApp.swift
//  LearnLogin
//
//  Created by SeanCho on 3/15/25.
//

import SwiftUI
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore

@main
struct OneBoatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var networkViewModel = DependencyContainer.shared.networkConnectivityViewModel

    var body: some Scene {
        WindowGroup {
            ContentView()
                .networkAlert(viewModel: networkViewModel)
                .onOpenURL { url in
                    // 구글 로그인 처리
                    if GIDSignIn.sharedInstance.handle(url) {
                        return
                    }
                    
                    // 카카오 로그인 처리
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 구글 Firebase 설정
        FirebaseApp.configure()
        
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: "14cc558eb727ffc16dd3f5f82ea72668")
        
        return true
    }
}



