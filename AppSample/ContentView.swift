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
    
    @State private var isAuthorized: Bool = true
    
    @State private var showingSettings = false

    
    // callback
    func changeAuthenticationState(_ authorized: Bool) {
        self.isAuthorized = authorized
    }
    
    var body: some View {
        
        NavigationView {
            // --
            VStack {
                
                Group {
                    if isAuthorized {
                        Dashboard(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)
                    } else {
                        
                        VStack {
                            OAuthView(appDelegate: viewModel.appDelegate, changeAuthenticationState: changeAuthenticationState)

                            NavigationLink(destination: SettingsView()) {
                                Text("Settings")
                                    .frame(width: 200, height: 50)
                                    .foregroundColor(.white)
                                    .background(Color.indigo)
                                    .cornerRadius(8)
                            }.padding(.vertical)
                            
                        } // -- VStack
                        .navigationBarTitle("", displayMode: .inline)
                        .padding(.vertical)
                        
                    } // -- else
                }
                
            }.navigationBarTitle("Back", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                changeAuthenticationState(viewModel.appDelegate.isAuthorized())
            }
            
            // --
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
