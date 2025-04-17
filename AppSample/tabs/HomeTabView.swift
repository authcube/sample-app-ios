//
//  HomeTabView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import SwiftUI

struct HomeTabView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    var changeAuthenticationState: (Bool) -> Void
    
    var body: some View {
        VStack {
            
            HeaderView()
            
            Spacer()
            
            Button {
                
                changeAuthenticationState(false)
                viewModel.appDelegate.deleteAuthStateFromKeychain()
                
            } label: {
                Text("Logout")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            

            Text("")
                .padding(.vertical, 25)
        }
        .padding()
    }
}

#Preview {
    let _appDelegate = AppDelegate()
    HomeTabView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), changeAuthenticationState: {_ in })
}
