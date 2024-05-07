//
//  AppSampleApp.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI
import AppAuthCore

@main
struct AppSampleApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var authState: OIDAuthState?
    
    var body: some Scene {
        WindowGroup {
            ContentView(appDelegate: appDelegate)
        }
    }
    
}

////@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    var window: UIWindow?
//    
//    // property of the app's AppDelegate
//    var currentAuthorizationFlow: OIDExternalUserAgentSession?
//    private var authState: OIDAuthState?
//    private var tokenDecoded: [String: Any]?
//
//    override init() {
//        super.init()
//        print("*** AppDelegate INIT ***")
//    }
//    
//    func setAuthState(_ _authState: OIDAuthState?) {
//        self.authState = _authState
//        decodeToken()
//    }
//    
//    func getAuthState() -> OIDAuthState? {
//        return self.authState
//    }
//    
//    func getUsername() -> String {
//        
//        guard let tk = self.tokenDecoded else {
//            print("Token vazio")
//            return ""
//        }
//        
//        if let uid: String = AppSample.value(from: tk, forKey: "uid") {
//            return uid
//        } else {
//            return ""
//        }
//    }
//    
//    func decodeToken() {
//        if let _accessToken = self.getAuthState() {
//            
//            let atk = _accessToken.lastTokenResponse!.accessToken!
//            
//            if let decoded = decodeJWT(atk) {
//                self.tokenDecoded = decoded
//                //                print("decoded: \(decoded)")
//            } else {
//                // Tratar caso em que o token não pode ser decodificado
//                print("Failed to decode JWT")
//                self.tokenDecoded = [:]
//            }
//        } else {
//            // Tratar caso em que o accessToken não está disponível
//            self.tokenDecoded = [:]
//        }
//    }
//    
//    func viewWillDisappear(_: Bool) {
//        print("func viewWillDisappear(Bool)")
//    }
//
//    
//    func application(_ app: UIApplication,
//                              open url: URL,
//                              options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        // Sends the URL to the current authorization flow (if any) which will
//        // process it if it relates to an authorization response.
//        if let authorizationFlow = self.currentAuthorizationFlow,
//           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
//            self.currentAuthorizationFlow = nil
//            return true
//        }
//        
//        // Your additional URL handling (if any)
//        
//        return false
//    }
//}
//
//func value<T>(from dictionary: [String: Any], forKey key: String) -> T? {
//    return dictionary[key] as? T
//}
