//
//  TotpView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 07/01/25.
//

import SwiftUI

struct TotpView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    @Binding var otpType: String
    
    // timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //
    // copy button for TOTP
    @State private var showCopySuccess = false
    
    @State private var codeNumber: String = ""
    @State private var countDown: Int = 30
    
    @State private var seedAvailable: Bool = false
    
    @State private var enrollmentInfo = ""
    @State private var errorMessage: String = ""
    
    /// -- functions

    private func hasSeed() -> Bool {
        return viewModel.appDelegate.authfySdk.hasSeed()
    }
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""
    
    
    func generateTOTP() {
        
        if self.seedAvailable {
            self.codeNumber = try! viewModel.appDelegate.authfySdk.generateTOTP()
        }
        
    }
    
    func doEnrollment() {
        errorMessage = ""
        
        let fixedUrl = urlIdp.components(separatedBy: "/").dropLast().joined(separator: "/")
        let enrollmentEndpoint = URL(string: "\(fixedUrl)/mfa/totp/enrollment")!
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let accessToken = accessToken else {
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
                                       var totpURL = values.first {
                                        // Agora 'totpURL' contém o valor desejado
                                        enrollmentInfo = totpURL
                                        print("TOTP URL: \(totpURL)")
                                        totpURL = totpURL.replacingOccurrences(of: "-", with: "")
                                        try viewModel.appDelegate.authfySdk.setSeed(data: totpURL)
                                        seedAvailable = viewModel.appDelegate.authfySdk.hasSeed()
                                        generateTOTP()
                                    }
                                }
                            }
                            
                        } catch {
                            print("Erro ao decodificar JSON: \(error)")
                            enrollmentInfo = ""
                            codeNumber = ""
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
                    
                    codeNumber = ""

                }
                
                seedAvailable = viewModel.appDelegate.authfySdk.hasSeed()
            }
            
            // Iniciar a tarefa
            task.resume()
            
        } // performaAction
        
    }
    
    func doDeleteEnrollment() {
        errorMessage = ""
        
        //        let edeleteEndpoint = URL(string:"https://newpst.authfy.tech/demo/mfa/totp/delete")!
        
        let fixedUrl = urlIdp.components(separatedBy: "/").dropLast().joined(separator: "/")
        let deleteEndpoint = URL(string: "\(fixedUrl)/mfa/totp/delete")!
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
//                changeAuthenticationState(false)
//                isPresented = false
                return
            }
            guard let accessToken = accessToken else {
//                isPresented = false
                return
            }
            
            
            let jsonString = "{\"verbose\": false}"
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("Erro ao criar dados JSON")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: deleteEndpoint)
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
                        try viewModel.appDelegate.authfySdk.deleteSeed()
                        seedAvailable = viewModel.appDelegate.authfySdk.hasSeed()
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
                
                seedAvailable = viewModel.appDelegate.authfySdk.hasSeed()
                codeNumber = ""

            }
            
            // Iniciar a tarefa
            task.resume()
            
        }
        
    }


    ///
    
    var body: some View {
        
        VStack {
            
            HeaderView()
            Spacer()
            
            // VStack 1
            VStack {

                Text("\(countDown)")
                    .frame(width: 50)
                    .font(.largeTitle)
                    .padding(.vertical)
                    .background(self.countDown < 10 ? Color.red : Color.clear)
                    .animation(.default, value: countDown)
                    .clipShape(Circle())

                HStack {
                    Text("Code:")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text(codeNumber)
                        .font(.title2)
                        .tracking(10)
                    
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
                            .foregroundColor(Color(hex: "#333333"))
                            .accessibility(label: Text("Copy to Clipboard"))
                    }
                    
                    if showCopySuccess {
                        Text("Copied!")
                            .foregroundColor(Color(hex: "#333333"))
                    }
                }
                    .padding(.horizontal)
                    .padding(.vertical)
                // -- HStack
                
                // VerifyTOTP
                VerifyTOTP(appDelegate: viewModel.appDelegate)
                    .padding(.vertical)
                
                
                ZStack {
                    if !seedAvailable {
                        // Enroll Button
                        Button(action: {
                            doEnrollment()
                            self.otpType = "TOTP"
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 80)
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Text("Enroll TOTP")
                                            .font(.title2)
                                            .bold()
                                    }
                                        .foregroundColor(Color(hex: "#F4F6F8"))
                                    
                                )// -- RoundedRectangle overlay
                                .padding(.horizontal)
                            
                        }
                        // -- Button Verify TOTP
                        
                    } else {
                        // UnEnroll Button
                        Button(action: {
                            doDeleteEnrollment()
                            self.otpType = "None"
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#333333")!)
                                .frame(height: 80)
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Text("Unenroll TOTP")
                                            .font(.title2)
                                            .bold()
                                    }
                                        .foregroundColor(Color(hex: "#F4F6F8"))
                                    
                                )// -- RoundedRectangle overlay
                                .padding(.horizontal)
                            
                        }
                        // -- Button Verify TOTP

                    } // -- else
                    
                } // -- ZStack
     
                VStack {
                    if !errorMessage.isEmpty {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                    
                    if !enrollmentInfo.isEmpty {
                        Text("Seed Registered: \(enrollmentInfo)")
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical)
                
            } // -- VStack 1
            
            Spacer()
            
        } // -- Top VStack
        .navigationTitle("TOTP")
        .onAppear {
            self.seedAvailable = self.hasSeed()
            generateTOTP()
        }
        .onReceive(timer) { _ in
            
            
//            if self.showingDetail {
//                self.codeNumber = "No seed"
//            }
            
//            if self.codeNumber == "No seed" && viewModel.appDelegate.authfySdk.hasSeed() {
//                generateTOTP()
//            }
            
            // let seconds = Calendar.current.component(.second, from: Date())
            let seconds = Calendar.current.component(.second, from: Date())
            let nextReset = (seconds >= 30 ? 60 : 30)
            self.countDown = nextReset - seconds
            
            if countDown == 30 || countDown == 60 {
                generateTOTP()
            }
//            self.progressValue = Float(countDown) / 30.0
            
        }

        
        
    } // -- body
}

#Preview {
    @State var otpType = "TOTP"
    let _appDelegate = AppDelegate()
    TotpView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), otpType: $otpType)
}
