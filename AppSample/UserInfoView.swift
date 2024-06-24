//
//  UserInfoView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 31/05/24.
//

import SwiftUI

struct UserInfoView: View {
    
    // parameters
    var viewModel: AppSampleViewModel
    
    // State
    @State private var isLoading: Bool = false
    @State private var userInfo: [String: Any] = [:]
    
    var body: some View {
        
        VStack {
            Button {
                
                fetchUserInfo()
                
            } label: {
                Text("Get User Info")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if isLoading {
                Text("Carregando...")
            } else {
                if let name = userInfo["uid"] as? String {
                    Text("Username: \(name)")
                } else {
                    Text("Click 'Get User Info', to fetch the 'username'")
                }
            }
        }
        
    }
    
    // --
    func fetchUserInfo() {
        
        // if you are not using discovery, use this instead
        //        let userinfoEndpoint = URL(string: "\(urlIdp)/userinfo")!
        
        let userinfoEndpoint =  viewModel.appDelegate.getAuthState()!.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint!
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                //                changeAuthenticationState(false)
                return
            }
            guard let accessToken = accessToken else {
                print("Error, accessToken is invalid, aborting")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: userinfoEndpoint!)
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
    //
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let _appDelegate = AppDelegate()
        UserInfoView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
    }
}
