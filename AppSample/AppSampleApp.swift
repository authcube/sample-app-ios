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
    
    var body: some Scene {
        WindowGroup {
//            ContentView(appDelegate: appDelegate)
            let viewModel = AppSampleViewModel(appDelegate: appDelegate)
//            ContentView(viewModel: viewModel)
            RootView(viewModel: viewModel)
        }
    }
    
}

class AppSampleViewModel: ObservableObject {
    @Published var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
}




