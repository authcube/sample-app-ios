//
//  StrongTabView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 02/01/25.
//

import SwiftUI

struct StrongTabView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    var changeAuthenticationState: (Bool) -> Void
    
    @State private var countdown: Int = 10
    @State private var progressValue: Float = 1.0
    
    @State private var otpType: String = "TOTP"
    
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

                NavigationLink(
                    destination: TotpView(viewModel: viewModel, otpType: otpType, isActive: showTotpView),
                    isActive: $showTotpView)
                {
                        EmptyView()
                }

                
                HeaderView()
                
                Spacer()
                
                
                // Grid Section (Top)
                ScrollView { // Make the grid scrollable
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        // TOTP View
                        Button(action: {
                            // Handle TOTP button tap
                            showTotpView = true
                            
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
                        
                        
                        // HOTP View
                        Button(action: {
                            // Handle HOTP button tap
                            print("HOTP Button Tapped")
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 150)
                                .overlay(
                                    HStack {
                                        ZStack {
                                            Image(systemName: "ellipsis.rectangle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.leading, 20)
                                        
                                        VStack(alignment: .leading) {
                                            Text("HOTP")
                                                .font(.title2)
                                                .bold()
                                            Text("HMAC ONE TIME PASSWORD")
                                                .font(.system(size: 14))
                                        }
                                        .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                        .foregroundColor(.white)
                                ) // -- RoundedRectangle overlay
                        }
                        
                        // --
                        // VStack Section (Bottom)
                        VStack {
                            
                            HStack() {
                                Text("Token Type: ")
                                    .font(.title2)
                                
                                Text("\(otpType)")
                                    .font(.title2)
                                
                                Spacer()
                            }.padding(.horizontal)
                            
                            HStack {
                                Text("Token Name: ")
                                    .font(.title2)
                                
                                Text("\(countdown)")
                                    .font(.largeTitle)
                                    .padding()
                                    .background(self.countdown < 10 ? Color.red : Color.clear)
                                    .animation(.default, value: countdown)
                                    .clipShape(Circle())
                                
                                Spacer()
                            }.padding(.horizontal)
                            
                            
                            HStack {
                                Text("Code: 123456")
                                    .font(.title2)
                                
                                Spacer()
                                
                                Button(action: {
                                    /*
                                     UIPasteboard.general.string = codeNumber
                                     showCopySuccess = true
                                     
                                     DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                     showCopySuccess = false
                                     }
                                     */
                                }) {
                                    Image(systemName: "doc.on.doc") // Ícone de copiar
                                        .font(.title2) // Ajuste o tamanho conforme necessário
                                        .foregroundColor(Color(hex: "#333333"))
                                        .accessibility(label: Text("Copy to Clipboard"))
                                }
                                
                                /*
                                 if showCopySuccess {
                                 Text("Copied!")
                                 .foregroundColor(.green)
                                 }
                                 */
                            }.padding(.horizontal)
                            
                            //                        ProgressBarView(value: $progressValue)
                            //                            .frame(height: 20)
                            //                            .padding()
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 150) // Make the VStack take up the full width
                        .padding(.vertical)
                        .background(Color.gray.opacity(0.2))
                    } // -- VStack
                    
                }
                .padding()
            } // -- ScrollView
            
        } // -- NavigationView
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    StrongTabView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), changeAuthenticationState: {_ in })
}
