//
//  Dashboard.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 06/05/24.
//

import SwiftUI

struct Dashboard: View {
    // parameters
    var appDelegate: AppDelegate
    var changeAuthenticationState: (Bool) -> Void
    
    
    // state
    @State private var userInfo: [String: Any] = [:]
    @State private var isLoading = false
    @State private var showVerifyTOTP = false
    @State private var showingDetail = false

    @State private var seconds = 0
    @State private var countdown = 30
//    @State private var codeNumber = Int.random(in: 100000...999999)
    @State private var codeNumber: String = "No seed"
    
    @State private var progressValue: Float = 1.0

    // copy button for TOTP
    @State private var showCopySuccess = false
    
    // timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""

    
    
    // --
    func fetchUserInfo() {
        let userinfoEndpoint = URL(string: "\(urlIdp)/userinfo")!
        appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                changeAuthenticationState(false)
                return
            }
            guard let accessToken = accessToken else {
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.httpMethod = "GET"
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            
            // Perform request...
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                // Verifique se houve algum erro
                if let error = error {
                    print("Erro ao fazer a solicitação: \(error)")
                    return
                }
                
                // Verificar a resposta HTTP e status code
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Tratar a resposta com sucesso
                    if let data = data {
                        // Supondo que a resposta seja um JSON
                        do {
                            // Tentar decodificar a resposta JSON, supondo uma estrutura básica
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Resposta JSON: \(responseObject)")
                            self.userInfo = responseObject as! [String : Any]
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                            self.userInfo = [:]
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        self.userInfo = [:]
                    }
                }
            }
            
            // Iniciar a tarefa
            task.resume()
            
        }
    }
    // --
    
    
    // -- getIdToken
    func getIdToken() -> String {
        
        let idToken: String = appDelegate.getAuthState()?.lastTokenResponse?.idToken ?? ""
        print("ID Token: [\(idToken)]")
        
        return idToken
    }
    //-
    
    // -- getAccessToken
    func getAccessToken() -> String {
        
        let accessToken: String = appDelegate.getAuthState()?.lastTokenResponse?.accessToken ?? ""
        print("Access Token: [\(accessToken)]")
        
        return accessToken
    }
    //-
    
    // -- getAccessToken
    func getRefreshToken() -> String {
        
        let refreshToken: String = appDelegate.getAuthState()?.lastTokenResponse?.refreshToken ?? ""
        print("Access Token: [\(refreshToken)]")
        
        return refreshToken
    }
    //-
    
    var body: some View {
        
        
        VStack {
            
            Button {
                
                print("get user info")
                fetchUserInfo()
                
                
            } label: {
                Text("Get User Info")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            VStack {

                if isLoading {
                    ProgressView("Carregando...")
                } else {
                    if let name = userInfo["uid"] as? String {
                        Text("Username: \(name)")
                    } else {
                        Text("Click 'Get User Info', to fetch the 'username'")
                    }
                    // Você pode adicionar mais campos conforme necessário
                }
                
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
                .sheet(isPresented: $showingDetail) {
                    SeedsDetailView(appDelegate: appDelegate, changeAuthenticationState: changeAuthenticationState, isPresented: $showingDetail)
                }
            }
            
            if appDelegate.authfySdk.hasSeed() {

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
                            .accessibility(label: Text("Copiar para Área de Transferência"))
                    }
                    
                    if showCopySuccess {
                        Text("Copiado!")
                            .foregroundColor(.green)
                    }
                }.padding(.horizontal)
                
                ProgressBarView(value: $progressValue)
                    .frame(height: 20)
                    .padding()
                
                
                VerifyTOTP(appDelegate: appDelegate)
                
            } else {
            
                Text("Code: No Seed")
                    .font(.title)
                    .padding()
            }
            
            Spacer()
            
            Button {
                
                changeAuthenticationState(false)
                appDelegate.deleteAuthStateFromKeychain()
                
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
//            fetchUserInfo()
            self.codeNumber = "No seed"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if appDelegate.authfySdk.hasSeed() {
                    do {
                        self.codeNumber = try appDelegate.authfySdk.generateTOTP()
                    } catch {
                        self.codeNumber = "No seed"
                        print("Error generating TOTP onAppear")
                    }
                }
            }
            
        }
        .onReceive(timer) { _ in
            
            if self.codeNumber == "No seed" && appDelegate.authfySdk.hasSeed() {
                do {
                    self.codeNumber = try appDelegate.authfySdk.generateTOTP()
                    print("code: \(self.codeNumber)")
                } catch {
                    self.codeNumber = "No seed"
                    print("Error generating TOTP")
                }
            }
            
            // let seconds = Calendar.current.component(.second, from: Date())
            seconds = Calendar.current.component(.second, from: Date())
            let nextReset = (seconds >= 30 ? 60 : 30)
            self.countdown = nextReset - seconds
            
            if countdown == 30 || countdown == 60 {
                //                        self.codeNumber = Int.random(in: 100000...999999)
                do {
                    self.codeNumber = try appDelegate.authfySdk.generateTOTP()
                    print("code: \(self.codeNumber)")
                } catch {
                    self.codeNumber = "No Seed"
                    print("Error generating TOTP")
                }
            }
            self.progressValue = Float(countdown) / 30.0
            
        }

    }
}

//struct Dashboard_Previews: PreviewProvider {
//
//    class MockAppDelegate: UIResponder, UIApplicationDelegate {
//        // Add any necessary mock properties here
//    }
//
//    static var previews: some View {
//        Dashboard(appDelegate: UIApplication.shared.delegate as! AppDelegate, changeAuthenticationState: { _ in })
//    }
//}
