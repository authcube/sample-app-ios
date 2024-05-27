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
