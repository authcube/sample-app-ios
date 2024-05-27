//
//  VerifyTOTP.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 11/05/24.
//

import SwiftUI

struct VerifyTOTP: View {
    
    var appDelegate: AppDelegate
    
    @State private var numberInput: String = ""
    @State private var isLoading = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        
        HStack(alignment: .center) {
            TextField("Type the OTP", text: $numberInput)
                .keyboardType(.numberPad)
                .onReceive(numberInput.publisher.collect()) {
                    self.numberInput = String($0.prefix(while: { "0123456789".contains($0) }))
                }
                .padding()
                .background(Color.white) // Define a cor de fundo para o TextField
                .overlay(
                    RoundedRectangle(cornerRadius: 5) // Adiciona borda arredondada
                        .stroke(Color.gray, lineWidth: 1) // Define a cor e largura da borda
                )
            
            if isLoading {
                
                Text("Verifying ...")
                    .font(.caption2)
                
            } else {
                Button("Verify") {
                    // Aqui você chama a função que processa o número
                    verifyTOTP()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .alert("Verification", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text("\(alertMessage)")
        }
        
    } // body
    
    // --
    
    func verifyTOTP() {
        
        let enrollmentEndpoint = URL(string:"https://newpst.authfy.tech/demo/mfa/totp/verify")!
        appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let accessToken = accessToken else {
                print("VerifyTOTP - unable to get accessToken")
                return
            }
            
            
            let jsonString = "{\"verbose\": false, \"otp\": \(numberInput)}"
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
                
                isLoading = false
                
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
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            print("Resposta JSON: \(responseObject!)")
                            
                            if let contents = responseObject!["contents"] as? [[String: Any]],
                               let firstContent = contents.first,
                               let values = firstContent["values"] as? [Any],
                               let booleanValue = values[2] as? Bool { // Considerando que você queria um boolean, mas na sua descrição tem um inteiro (1).
                                
                                print("Boolean value: \(booleanValue)")
                                
                                alertMessage = "The code [\(numberInput)] is valid"
                                showAlert = true
                                
                            } else {
                                print("Error: Unable to find the expected data in the data structure.")
                            }

                            
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("VerifyTOTP - HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    
                    alertMessage = "The code [\(numberInput)] is NOT valid"
                    showAlert = true
                    
                }
                
            }
            
            // Iniciar a tarefa
            isLoading = true
            task.resume()
            
        }
    }
        
}

//struct VerifyTOTP_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyTOTP()
//    }
//}
