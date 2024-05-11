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
    
    @State private var showingDetail = false
    
    // state
    @State private var userInfo: [String: Any] = [:]
    @State private var isLoading = false
    
    @State private var seconds = 0
    @State private var countdown = 30
//    @State private var codeNumber = Int.random(in: 100000...999999)
    @State private var codeNumber: String = "No seed"
    
    @State private var progressValue: Float = 1.0
    
    // timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    // --
    func fetchUserInfo() {
        let userinfoEndpoint = URL(string:"https://newpst.authfy.tech/demo/connect/userinfo")!
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
                //                Text("Username: \(self.appDelegate.getUsername())")
                
                if isLoading {
                    ProgressView("Carregando...")
                } else {
                    if let name = userInfo["uid"] as? String {
                        Text("Username: \(name)")
                    } else {
                        Text("Informação não disponível")
                    }
                    // Você pode adicionar mais campos conforme necessário
                }
                
                FeatureItem(title: "ID Tokens") {
                    showingDetail = true
                }
                
                FeatureItem(title: "Access Token") {}
                FeatureItem(title: "Refresh Token") {}
                FeatureItem(title: "Seeds") {
                    showingDetail = true
                }.sheet(isPresented: $showingDetail) {
                    SeedsDetailView(appDelegate: appDelegate, changeAuthenticationState: changeAuthenticationState, isPresented: $showingDetail)
                }
            }
            
            Text("\(countdown)")
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    
                    if self.codeNumber == "No seed" && appDelegate.authfySdk.hasSeed() {
                        do {
                            self.codeNumber = try appDelegate.authfySdk.generateTOTP()
                        } catch {
                            self.codeNumber = "Error generating TOTP"
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
                        } catch {
                            self.codeNumber = "Error generating TOTP"
                            print("Error generating TOTP")
                        }
                    }
                    self.progressValue = Float(countdown) / 30.0
                    
                }
                .padding()
                .background(self.countdown < 10 ? Color.red : Color.clear)
                .animation(.default, value: countdown)
                .clipShape(Circle())
            
            
            if appDelegate.authfySdk.hasSeed() {
                
                Text("Code: \(codeNumber)")
                    .font(.title)
                    .padding()
                
            } else {
            
                Text("Code: No Seed")
                    .font(.title)
                    .padding()
            }
            
            ProgressBarView(value: $progressValue)
                .frame(height: 20)
                .padding()
            
            Button {
                
                appDelegate.deleteAuthStateFromKeychain()
                changeAuthenticationState(false)
                
            } label: {
                Text("Logout")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(Color(#colorLiteral(red: 0.82, green: 0.18, blue: 0.18, alpha: 1)))
            .foregroundColor(.white)
            .cornerRadius(10)
            
        } // VStack
        .onAppear{
            fetchUserInfo()
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    
    class MockAppDelegate: UIResponder, UIApplicationDelegate {
        // Add any necessary mock properties here
    }
    
    static var previews: some View {
        Dashboard(appDelegate: UIApplication.shared.delegate as! AppDelegate, changeAuthenticationState: { _ in })
    }
}
