//
//  StrongTabView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 02/01/25.
//

import SwiftUI

struct StrongTabView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var countdown: Int = 10
    @State private var progressValue: Float = 1.0
    
    @State private var otpType: String = ""
    
    // Naviagation
    @State private var showTotpView: Bool = false
    @State private var showHotpView: Bool = false
    
    // for the Grid Layout
    let columns: [GridItem] = [
        GridItem(.flexible()), // First column
        //        GridItem(.flexible())  // Second column (adjust as needed)
    ]
    
    var body: some View {
        
        NavigationView {

            VStack {

                // -- begin NavigationLink
                NavigationLink(
                    destination: TotpView(viewModel: viewModel, otpType: $otpType),
                    isActive: $showTotpView)
                {
                        EmptyView()
                }

//                NavigationLink(
//                    destination: HotpView(viewModel: viewModel, otpType: $otpType),
//                    isActive: $showHotpView)
//                {
//                        EmptyView()
//                }
                // -- end NavigationLink
                
                HeaderView()
                
                Spacer()
                
                
                // Grid Section (Top)
                ScrollView { // Make the grid scrollable
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        // TOTP View
                        Button(action: {
                            // Handle TOTP button tap
                            showTotpView = true
                            showHotpView = false
                            
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 150)
                                .overlay(
                                    HStack {
                                        Image(systemName: "clock")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding(.leading, 20)
                                        
                                        VStack(alignment: .leading) {
                                            Text("TOTP")
                                                .font(.title2)
                                                .bold()
                                            Text("TIME BASED ONE TIME PASSWORD")
                                                .font(.system(size: 14))
                                        }
                                        .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                        .foregroundColor(Color(hex: "#F4F6F8"))
                                    
                                )// -- RoundedRectangle overlay
                        } // -- TOTP Button
                        
                    }
                } // -- LazyGrid
                .padding()
            } // -- ScrollView
            
        } // -- NavigationView
        
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    StrongTabView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
