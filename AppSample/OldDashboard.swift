//
//  Dashboard.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 06/05/24.
//

import SwiftUI

class PopupState: ObservableObject {
    @Published var shouldRefreshView: Bool = false
}


struct OldDashboard: View {
    // parameters
    @ObservedObject var viewModel: AppSampleViewModel
    var changeAuthenticationState: (Bool) -> Void
    
    
    // special state
    @StateObject private var popupState = PopupState()
    
    // state
    @State private var showVerifyTOTP = false
    @State private var showingDetail = false

    @State private var seconds = 0
    @State private var countdown = 30
    @State private var codeNumber: String = "No seed"
    
    @State private var progressValue: Float = 1.0

    // copy button for TOTP
    @State private var showCopySuccess = false
    
    // timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""

    
    // -- generateTOTP
    func generateTOTP() {
        do {
            codeNumber = try viewModel.appDelegate.authfySdk.generateTOTP()
            print("TOTP Generated: \(codeNumber)")
        } catch {
            codeNumber = "No Seed"
            print("Error generating TOTP")
        }
    }
    //
    
    
    // -- getIdToken
    func getIdToken() -> String {
        
        let idToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.idToken ?? ""
        print("ID Token: [\(idToken)]")
        
        return idToken
    }
    //-
    
    // -- getAccessToken
    func getAccessToken() -> String {
        
        let accessToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.accessToken ?? ""
        print("Access Token: [\(accessToken)]")
        
        return accessToken
    }
    //-
    
    // -- getAccessToken
    func getRefreshToken() -> String {
        
        let refreshToken: String = viewModel.appDelegate.getAuthState()?.lastTokenResponse?.refreshToken ?? ""
        print("Access Token: [\(refreshToken)]")
        
        return refreshToken
    }
    //-
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                UserInfoView(viewModel: viewModel)
                
                VStack {
                    
                    // ID Tokens
                    FeatureItem(title: "ID Tokens", action: {}, copyAction: {
                        
                        let id_token = getIdToken()
                        
                        if id_token.isEmpty {
                            print("no id token")
                        } else {
                            UIPasteboard.general.string = id_token
                        }
                    })
                    
                    // Access Tokens
                    FeatureItem(title: "Access Token", action: {}, copyAction: {
                        let access_token = getAccessToken()
                        
                        if access_token.isEmpty {
                            print("no access token")
                        } else {
                            UIPasteboard.general.string = access_token
                        }
                    })
                    
                    // Refresh Token
                    FeatureItem(title: "Refresh Token", action: {}, copyAction: {
                        let refresh_token = getRefreshToken()
                        
                        if refresh_token.isEmpty {
                            print("no refresh token")
                        } else {
                            UIPasteboard.general.string = refresh_token
                        }
                    })
                                       
                    // Seed
                    FeatureItem(title: "Seeds", action:  {
                        showingDetail = true
                    }, showCopyButton: false, copyAction: {})
                    .sheet(isPresented: $showingDetail, onDismiss: {

                        self.codeNumber = "No seed"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if viewModel.appDelegate.authfySdk.hasSeed() {
                                generateTOTP()
                            }
                        }

                    }) {
                        SeedsDetailView(appDelegate: viewModel.appDelegate, changeAuthenticationState: changeAuthenticationState, isPresented: $showingDetail, popupState: popupState)
                    }
                    
                } // VStack
                
                if !viewModel.appDelegate.authfySdk.hasSeed() {
                    
                    Text("\(countdown)")
                        .font(.largeTitle)
                        .padding()
                        .background(self.countdown < 10 ? Color.red : Color.clear)
                        .animation(.default, value: countdown)
                        .clipShape(Circle())
                    
                    
                    HStack {
                        Text("Code: \(codeNumber)")
                            .font(.title)
                        
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
                                .accessibility(label: Text("Copy to Clipboard"))
                        }
                        
                        if showCopySuccess {
                            Text("Copied!")
                                .foregroundColor(.green)
                        }
                    }.padding(.horizontal)
                    
                    ProgressBarView(value: $progressValue)
                        .frame(height: 20)
                        .padding()
                    
                    
                    VerifyTOTP(appDelegate: viewModel.appDelegate)
                    
                } else {
                    
                    Text("Code: No Seed")
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                Button {
                    
                    changeAuthenticationState(false)
                    viewModel.appDelegate.deleteAuthStateFromKeychain()
                    
                } label: {
                    Text("Logout")
                        .padding()
                        .frame(width: 200, height: 50)
                }
                .background(Color(#colorLiteral(red: 0.82, green: 0.18, blue: 0.18, alpha: 1)))
                .foregroundColor(.white)
                .cornerRadius(10)
                
            } // VStack
            .onAppear {
                self.codeNumber = "No seed"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if viewModel.appDelegate.authfySdk.hasSeed() {
                        generateTOTP()
                    }
                }
                
            }
            .onReceive(timer) { _ in
                
                if self.showingDetail {
                    self.codeNumber = "No seed"
                }
                
                if self.codeNumber == "No seed" && viewModel.appDelegate.authfySdk.hasSeed() {
                    generateTOTP()
                }
                
                // let seconds = Calendar.current.component(.second, from: Date())
                seconds = Calendar.current.component(.second, from: Date())
                let nextReset = (seconds >= 30 ? 60 : 30)
                self.countdown = nextReset - seconds
                
                if countdown == 30 || countdown == 60 {
                    generateTOTP()
                }
                self.progressValue = Float(countdown) / 30.0
                
            }
        }

    }
}

struct OldDashboard_Previews: PreviewProvider {

    static var previews: some View {
        let _appDelegate = AppDelegate()
        OldDashboard(viewModel: AppSampleViewModel(appDelegate: _appDelegate), changeAuthenticationState: {_ in })
    }
}
