//
//  ConnectTabView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct ConnectTabView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    
    var body: some View {
        
        NavigationView {
            
            
            VStack {
                HeaderView()
                
                Spacer()
                
                ScrollView {
                    NavigationLink(destination: TokensView(viewModel: viewModel)) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#333333")!)
                            .frame(height: 150)
                            .overlay(
                                HStack {

                                    Image(systemName: "person.badge.key")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Tokens")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                
                            )// -- RoundedRectangle overlay
                    }
                }// -- ScrollView
                
                Spacer()
                
            } // -- VStack
            .padding()
            
            
        } // -- NavigationView
        
        
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    ConnectTabView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
