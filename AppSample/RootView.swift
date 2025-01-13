//
//  RootView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 13/01/25.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var showSplash = true
    
    var body: some View {
        
        ZStack {
            
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            }
            
            ContentView(viewModel: viewModel)
            // Hide the main view when the splash is showing
                .opacity(showSplash ? 0 : 1)
            
            
        } // -- ZStack
        .onAppear {
//            Simulate a short delay, e.g., 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        
    }
}

#Preview {
    let _appDelegate = AppDelegate()
    RootView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
