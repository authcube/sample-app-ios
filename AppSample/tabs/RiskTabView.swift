//
//  RiskTabView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct RiskTabView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                HeaderView()
                Spacer()
                
                ScrollView {
                    NavigationLink(destination: DeviceInformationView(viewModel: viewModel)) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#333333")!)
                            .frame(height: 150)
                            .overlay(
                                HStack {
                                    
                                    Image(systemName: "info.bubble")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Device Information")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                
                            )// -- RoundedRectangle overlay
                    } // -- DeviceInformation
                    
                    NavigationLink(destination: TransactionsView(viewModel: viewModel)) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#333333")!)
                            .frame(height: 150)
                            .overlay(
                                HStack {

                                    Image(systemName: "list.clipboard")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Transactions")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                
                            )// -- RoundedRectangle overlay
                    } // -- Transactions
                    
                    NavigationLink(destination: ToolkitView(viewModel: viewModel)) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#333333")!)
                            .frame(height: 150)
                            .overlay(
                                HStack {

                                    Image(systemName: "screwdriver")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Toolkit")
                                            .font(.title2)
                                            .bold()
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                
                            )// -- RoundedRectangle overlay
                    } // -- Toolkit
                }// -- ScrollView
                
                
                Spacer()
                
            } // -- VStack
            
        } // -- NavigationView
        .padding()
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    RiskTabView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
