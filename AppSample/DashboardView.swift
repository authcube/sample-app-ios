//
//  DashboardView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import SwiftUI

struct DashboardView: View {
    // parameters
    @ObservedObject var viewModel: AppSampleViewModel
    var changeAuthenticationState: (Bool) -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            HomeTabView(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }.tag(0)

            Text("Risk")
                .tabItem{
                    Label("Risk", systemImage: "exclamationmark.triangle.fill")
                }.tag(1)
            
            StrongTabView(viewModel: viewModel)
                .tabItem{
                    Label("Strong", systemImage: "key.fill")
                }.tag(2)
            
            Text("Home")
                .tabItem{
                    Label("Connect", systemImage: "person.fill")
                }.tag(3)
            
        } // -- tab
        .accentColor(Color(hex: "#333333")) // Set the tab bar's accent color
//        .overlay(alignment: .top) {
//            HeaderView()
//        }
        .navigationBarBackButtonHidden(true)
        
    } // -- body
}

struct DashboardView_Previews: PreviewProvider {

    static var previews: some View {
        let _appDelegate = AppDelegate()
        DashboardView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), changeAuthenticationState: {_ in })
    }
}
