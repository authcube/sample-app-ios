//
//  TokensView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct TokensView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    
    //
    @State private var tokenValue: String = ""
    
    var body: some View {
        
        
        VStack {
            
            HeaderView()
            Spacer()
            
            Button{
                let accessToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.accessToken ?? ""
                self.tokenValue = accessToken
            } label: {
                HStack {
                    Text("Access Token")
                        .padding()
                        .frame(width: 200, height: 50)
                }
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
            Button{
                let refreshToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.refreshToken ?? ""
                self.tokenValue = refreshToken
            } label: {
                HStack {
                    Text("Refresh Token")
                        .padding()
                        .frame(width: 200, height: 50)
                }
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
            Button{
                let idToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.idToken ?? ""
                self.tokenValue = idToken
            } label: {
                HStack {
                    Text("Id Token")
                        .padding()
                        .frame(width: 200, height: 50)
                }
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
            Spacer()
            
            ScrollView {
                Text("\(tokenValue)")
                // If you want to allow text selection (so users can copy)
                // .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding()
            
        } // -- VStack
        .navigationTitle("Tokens")
        
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    TokensView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
