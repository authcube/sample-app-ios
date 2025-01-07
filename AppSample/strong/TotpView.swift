//
//  TotpView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 07/01/25.
//

import SwiftUI

struct TotpView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    @State var otpType: String
    @State var isActive: Bool
    
    //
    // copy button for TOTP
    @State private var showCopySuccess = false
    
    @State private var codeNumber: String = "123456"
    
    @State private var seedAvailable: Bool = false
    
    
    /// -- functions

    private func hasSeed() -> Bool {
        return viewModel.appDelegate.authfySdk.hasSeed()
    }


    ///
    
    var body: some View {
        
        VStack {
            
            HeaderView()
            Spacer()
            
            // VStack 1
            VStack {
                
                HStack {
                    Text("Code:")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text(codeNumber)
                        .font(.title2)
                        .tracking(10)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        UIPasteboard.general.string = codeNumber
                        showCopySuccess = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopySuccess = false
                        }
                        
                    }) {
                        Image(systemName: "doc.on.doc") // Ícone de copiar
                            .font(.title2) // Ajuste o tamanho conforme necessário
                            .foregroundColor(Color(hex: "#333333"))
                            .accessibility(label: Text("Copy to Clipboard"))
                    }
                    
                    if showCopySuccess {
                        Text("Copied!")
                            .foregroundColor(.green)
                    }
                }
                    .padding(.horizontal)
                    .padding(.vertical)
                // -- HStack
                
                // VerifyTOTP
                Button(action: {
                    
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#333333")!)
                        .frame(height: 80)
                        .overlay(
                                VStack(alignment: .leading) {
                                    Text("Verify TOTP")
                                        .font(.title2)
                                        .bold()
                                }
                                .foregroundColor(Color(hex: "#F4F6F8"))
                            
                        )// -- RoundedRectangle overlay
                        .padding(.horizontal)

                } // -- Button Verify TOTP
                
                
                ZStack {
                    if !seedAvailable {
                        // Enroll Button
                        Button(action: {
                            
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 80)
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Text("Enroll TOTP")
                                            .font(.title2)
                                            .bold()
                                    }
                                        .foregroundColor(Color(hex: "#F4F6F8"))
                                    
                                )// -- RoundedRectangle overlay
                                .padding(.horizontal)
                            
                        }
                        // -- Button Verify TOTP
                        
                    } else {
                        // UnEnroll Button
                        Button(action: {
                            
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 80)
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Text("Unenroll TOTP")
                                            .font(.title2)
                                            .bold()
                                    }
                                        .foregroundColor(Color(hex: "#F4F6F8"))
                                    
                                )// -- RoundedRectangle overlay
                                .padding(.horizontal)
                            
                        }
                        // -- Button Verify TOTP

                    }
                    
                } // -- ZStack
                
                
            } // -- VStack 1
            
            Spacer()
            
        } // -- Top VStack
        .onAppear {
            self.seedAvailable = self.hasSeed()
        }
        
        
    } // -- body
}

#Preview {
    let _appDelegate = AppDelegate()
    TotpView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), otpType: "TOTP", isActive: true)
}
