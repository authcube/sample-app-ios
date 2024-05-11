//
//  SeedsDetailView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 10/05/24.
//

import SwiftUI

struct SeedsDetailView: View {
    
    func doEnrollment() {
        errorMessage = ""
        
        let enrollmentEndpoint = URL(string:"https://newpst.authfy.tech/demo/mfa/totp/enrollment")!
        appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                changeAuthenticationState(false)
                isPresented = false
                return
            }
            guard let accessToken = accessToken else {
                isPresented = false
                return
            }
            
            
            let jsonString = "{\"verbose\": false}"
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("Erro ao criar dados JSON")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: enrollmentEndpoint)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            urlRequest.httpBody = jsonData
            
            // Perform request...
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                // Verifique se houve algum erro
                if let error = error {
                    print("Erro ao fazer a solicitação: \(error)")
                    return
                }
                
                // Verificar a resposta HTTP e status code
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    // Tratar a resposta com sucesso
                    if let data = data {
                        // Supondo que a resposta seja um JSON
                        do {
                            // Tentar decodificar a resposta JSON, supondo uma estrutura básica
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Resposta JSON: \(responseObject)")
                            
                            if let r = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let contents = r["contents"] as? [[String: Any]] {
                                
                                // Procurando pelo objeto correto no array 'contents'
                                for content in contents {
                                    if let rel = content["rel"] as? [String],
                                       rel.contains("urn:mfao:totp:enrollment:data"),
                                       let values = content["values"] as? [String],
                                       let totpURL = values.first {
                                        // Agora 'totpURL' contém o valor desejado
                                        enrollmentInfo = totpURL
                                        print("TOTP URL: \(totpURL)")
                                        try appDelegate.authfySdk.setSeed(data: totpURL)
                                        hasSeed = appDelegate.authfySdk.hasSeed()
                                    }
                                }
                            }
                            
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                            enrollmentInfo = ""
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        enrollmentInfo = ""
                        errorMessage = "Status Code: \(httpResponse.statusCode)"
                        
                        if httpResponse.statusCode == 409 {
                            errorMessage = "Enrollment already completed, delete the existing enrollment before try to enroll again"
                        }
                        
                    }
                }
                
                hasSeed = appDelegate.authfySdk.hasSeed()
            }
            
            // Iniciar a tarefa
            task.resume()
            
        }
        
    }
    
    func doDeleteEnrollment() {
        errorMessage = ""
        
        let edeleteEndpoint = URL(string:"https://newpst.authfy.tech/demo/mfa/totp/delete")!
        appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                changeAuthenticationState(false)
                isPresented = false
                return
            }
            guard let accessToken = accessToken else {
                isPresented = false
                return
            }
            
            
            let jsonString = "{\"verbose\": false}"
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("Erro ao criar dados JSON")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: edeleteEndpoint)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            urlRequest.httpBody = jsonData
            
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
                    
                    do {
                        try appDelegate.authfySdk.deleteSeed()
                        hasSeed = appDelegate.authfySdk.hasSeed()
                    } catch {
                        print("Error deleting Seed")
                    }
                    
                    if let data = data {
                        // Supondo que a resposta seja um JSON
                        do {
                            // Tentar decodificar a resposta JSON, supondo uma estrutura básica
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Resposta JSON: \(responseObject)")
                            enrollmentInfo = ""
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                            enrollmentInfo = ""
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        enrollmentInfo = ""
                        errorMessage = "Status Code: \(httpResponse.statusCode)"
                    }
                }
                
                hasSeed = appDelegate.authfySdk.hasSeed()
            }
            
            // Iniciar a tarefa
            task.resume()
            
        }
        
    }
    
    // ---
    
    var appDelegate: AppDelegate
    var changeAuthenticationState: (Bool) -> Void
    @Binding var isPresented: Bool
    
    @State private var enrollmentInfo = ""
    @State private var errorMessage: String = ""
    @State private var hasSeed = false
    
    var body: some View {
        
        VStack {
            
            Text("Seeds")
            
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            if !enrollmentInfo.isEmpty {
                Text("Seed Registered: \(enrollmentInfo)")
                    .foregroundColor(.black)
            }
            
            if !hasSeed {
                Button {
                    
                    doEnrollment()
                    
                } label: {
                    Text("Cadastrar Seed")
                        .padding()
                        .frame(width: 200, height: 50)
                }
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            else {
                Button {
                    
                    doDeleteEnrollment()
                    
                } label: {
                    Text("Delete Enrollment")
                        .padding()
                        .frame(width: 200, height: 50)
                }
                .background(Color(#colorLiteral(red: 0.82, green: 0.18, blue: 0.18, alpha: 1)))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button {
                
                isPresented = false
                
            } label: {
                Text("Close")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(Color(#colorLiteral(red: 0.82, green: 0.18, blue: 0.18, alpha: 1)))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear{
            hasSeed = appDelegate.authfySdk.hasSeed()
        }
    }
}

//struct SeedsDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeedsDetailView()
//    }
//}
