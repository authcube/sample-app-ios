//
//  ContentView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI
import AuthenticationServices
import AppAuthCore


struct ContentView: View {
    //    var appDelegate: AppDelegate
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var isAuthorized: Bool = false
    
    @State private var showingSettings = false
    
    @State private var username = ""
    
    
    // callback
    func changeAuthenticationState(_ authorized: Bool) {
        self.isAuthorized = authorized
        
        if !authorized {
            return
        }
        
        self.username = viewModel.appDelegate.getUsername()
        
//        let backendTools = BackendTools()
//        backendTools.fetchUserInfo(viewModel.appDelegate) { username in
//            // Use the username here
//            print("Username: \(username)")
//            
//            // If you need to update UI, make sure to dispatch to main thread
//            DispatchQueue.main.async {
//                // Update UI here
//                self.username = username
//            }
//        }
    }
    
    var body: some View {
        
        NavigationView {
            // --
            VStack {

                Group {

                    if isAuthorized {
                        
                        VStack {
                            Spacer()
                            
                            Text("Welcome back, \(username)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            NavigationLink(destination: Dashboard(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)) {
                                
                                Text("Enter")
                                    .frame(width: 200, height: 50)
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                    .background(Color(hex: "#333333"))
                                    .cornerRadius(8)
                                
                            }
                        }
                        
                        //                        Dashboard(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)
                        
                        
                    } else {
                        
                        HStack() {
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(hex: "#333333"))

                                    .padding()
                            }
                        } // -- HStack
                        
                        
                        VStack {
                            LoginScreenHeaderView()
                            
                            Spacer()
                            
                            OAuthView(appDelegate: viewModel.appDelegate, changeAuthenticationState: changeAuthenticationState)
                                                        
                        } // -- VStack
                        .navigationBarTitle("", displayMode: .inline)
                        .padding(.vertical)
                        
                    } // -- else
                    
                } // -- Group
                
                FooterView()

                
            }.navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .onAppear{
                    changeAuthenticationState(viewModel.appDelegate.isAuthorized())
                }
            
            // -- VStack
        } // -- NavigationView
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let _appDelegate = AppDelegate()
        ContentView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
    }
}

//
func decodeJWT(_ token: String) -> [String: Any]? {
    let segments = token.components(separatedBy: ".")
    guard segments.count > 1 else { return nil }
    
    var base64String = segments[1]
    let requiredLength = Int(4 * ceil(Float(base64String.count) / 4.0))
    let paddingLength = requiredLength - base64String.count
    if paddingLength > 0 {
        let padding = String(repeating: "=", count: paddingLength)
        base64String += padding
    }
    
    guard let data = Data(base64Encoded: base64String) else { return nil }
    
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject as? [String: Any]
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}
