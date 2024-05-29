//
//  OAuthView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 06/05/24.
//

import SwiftUI
import AppAuthCore

struct OAuthView: View {
    // parameters
    var appDelegate: AppDelegate
    var changeAuthenticationState: (Bool) -> Void
    
    // state
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""
    
    var body: some View {
        
        VStack {
            
            Button {
                
//                let issuer = URL(string: "https://newpst.authfy.tech/demo/connect")!
                let issuer = URL(string: urlIdp)!
                
                // discovers endpoints
                OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
                    guard let _ = configuration else {
                        print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // perform the auth request...
                    
//                clientSecret: "utxd79fCKdm0hKaQQDJzSo7nn3eYyKWpviadd6WnGv66JABY",
//                clientId: "ObYHVcSYqPfhBIsOU6hjWOO0",
                    // builds authentication request
                    let request = OIDAuthorizationRequest(configuration: configuration! ,
                                                          clientId: clientSecret,
                                                          clientSecret: nil,
                                                          scopes: [OIDScopeOpenID, OIDScopeProfile, "roles"],
                                                          redirectURL: NSURL(string:  "br.com.sec4you.authfy.app.AppSample:/oauth2redirect")! as URL,
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
                Text("Auth")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        } // VStack
        
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
