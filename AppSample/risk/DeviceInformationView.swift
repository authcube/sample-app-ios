//
//  DeviceInformationView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct Key: Codable {
    let alg: String
    let e: String
    let kid: String
    let kty: String
    let n: String
    let use: String
}

struct KeysResponse: Codable {
    let keys: [Key]
}

extension KeysResponse {
    /// Returns the JSON string of the key whose `use` field matches the given value.
    func keyJSON(forUse desiredUse: String) -> String? {
        // Find the key with the desired `use` value.
        guard let matchingKey = keys.first(where: { $0.use == desiredUse }) else {
            return nil
        }
        
        // Encode the key back into JSON.
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]  // Optional formatting
        do {
            let data = try encoder.encode(matchingKey)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding key: \(error)")
            return nil
        }
    }
}


struct DeviceInformationView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var deviceInformation: String = ""
    @State private var generateJWE: Bool = false
    
    @State private var jwksKeys: KeysResponse? = nil
    
    @State private var errorMessage: String = ""
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    
    var body: some View {
        
        VStack {
            
            HeaderView()
            
            HStack {
                
                Spacer()
                
                Button {
                    
                    if ( generateJWE ) {
                        
                        if let keysResponse = jwksKeys {
                            
                            let jwks = keysResponse.keyJSON(forUse: "enc")
                            
                            if let encryptedInfo = try? viewModel.appDelegate.authfySdk.getEncryptedDeviceInfo(withJWKS: jwks!) {
                                self.deviceInformation = encryptedInfo
                            } else {
                                print("Failed to get encrypted device info")
                            }
                        }
                        
                    } else {
                        
                        self.deviceInformation = viewModel.appDelegate.authfySdk.getDeviceInfo()
                        
                    }
                    
                } label: {
                    Text("Collect Device Information")
                        .padding()
                        .frame(width: 250, height: 50)
                }
                .foregroundColor(Color(hex: "#F4F6F8"))
                .background(Color(hex: "#333333"))
                .cornerRadius(10)
                
                Spacer()
                                
                VStack {
                    
                    Text("Use JWE")
                    
                    Toggle("", isOn: $generateJWE)
                        .tint(Color(hex: "#333333"))
                        .padding(.horizontal)
                        
                } .frame(width: 80) // Ensure enough width so both elements stay aligned
                    .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] } // Align to baseline
                    .padding(.horizontal)
                
                Spacer()
            }
           
            
            
            ScrollView {
                Text("\(deviceInformation)")
                // If you want to allow text selection (so users can copy)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding()
        }// -- VStack
        .navigationTitle("Device Information")
        .onAppear {
            loadJwks()
        }
    } // end body
    
    
    // #functions
    func loadJwks() {
        
        
//        let fixedUrl = urlIdp.components(separatedBy: "/").dropLast().joined(separator: "/")
        let jwksEndpoint = URL(string: "\(urlIdp)/jwks")!
        
        let authState = viewModel.appDelegate.getAuthState()
        
        authState?.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: jwksEndpoint)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
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
                            let decoder = JSONDecoder()
                            jwksKeys = try decoder.decode(KeysResponse.self, from: data)
                            errorMessage = ""
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                            errorMessage = ""
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        errorMessage = "Status Code: \(httpResponse.statusCode)"
                    }
                }
            }
            
            // Iniciar a tarefa
            task.resume()
            
        }
    } // end loadJwks
}

#Preview {
    let _appDelegate = AppDelegate()
    DeviceInformationView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
