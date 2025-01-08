//
//  OAuthView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 06/05/24.
//

import SwiftUI
import AppAuth

struct OAuthView: View {
    // parameters
    var appDelegate: AppDelegate
    var changeAuthenticationState: (Bool) -> Void
    
    // state
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""
    
    var body: some View {
        
        VStack {
            
            Button {

                guard !urlIdp.isEmpty, let _ = URL(string: urlIdp) else {
                    
                    alertMessage = "You must provide an URL for the IDP"
                    showAlert = true
                    return
                    
                }
                
//                let issuer = URL(string: "https://demo.authfy.tech/sample-app/connect")!
                let issuer = URL(string: urlIdp)!
                
                // discovers endpoints
                OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
                    guard let _ = configuration else {
                        print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // perform the auth request...
                    
//                https://demo.authfy.tech/authenticator/connect/.well-known/openid-configuration
//                clientSecret: "utxd79fCKdm0hKaQQDJzSo7nn3eYyKWpviadd6WnGv66JABY",
//                clientId: "ObYHVcSYqPfhBIsOU6hjWOO0",
                    // builds authentication request
                    let request = OIDAuthorizationRequest(configuration: configuration! ,
                                                          clientId: clientSecret,
                                                          clientSecret: nil,
                                                          scopes: [OIDScopeOpenID, OIDScopeProfile, "roles"],
//                                                          redirectURL: NSURL(string:  "br.com.sec4you.authfy.app.AppSample:/oauth2redirect")! as URL,
                                                          redirectURL: NSURL(string:"br.com.sec4you.authfy.app.appsample:/oauth2redirect")! as URL,
                                                          responseType: OIDResponseTypeCode,
                                                          additionalParameters: nil)
                    
                    // performs authentication request
                    print("Initiating authorization request with scope: \(request.scope ?? "nil")")
                                       
                    appDelegate.currentAuthorizationFlow =
                    OIDAuthState.authState(byPresenting: request, presenting: UIApplication.shared.windows.first!.rootViewController!, prefersEphemeralSession: true) { authState, error in
                        
                        if let authState = authState {
                            self.appDelegate.setAuthState(authState)
                            
                            changeAuthenticationState(true)
                            
                            print("Got authorization tokens. Access token: " +
                                  "\(authState.lastTokenResponse?.accessToken ?? "nil")")
//
//                            print("-----")
//                            print("Got authorization tokens. Access token: " + "\(String(describing: authState))")
//                            print("-----")

                            
                            // chamar userinfo
                            
                            
                        } else {
                            print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                            
                            print("-----")
                            print("DOUBLE CHECK YOUR SERVER TIMEZONE CONFIG")
                            print("-----")
                            //                            self.setAuthState(nil)
                            self.appDelegate.setAuthState(nil)
                            
                            changeAuthenticationState(false)
                        }
                    }
                    
                    
                    
                }
            } label: {
                Text("Login")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
        } // VStack
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
        
    }
}

//struct OAuthView_Previews: PreviewProvider {
//    class MockAppDelegate: UIResponder, UIApplicationDelegate {
//        // Add any necessary mock properties here
//    }
//
//    static var previews: some View {
//        OAuthView(appDelegate: UIApplication.shared.delegate as! AppDelegate, changeAuthenticationState: { _ in })
//    }
//}
