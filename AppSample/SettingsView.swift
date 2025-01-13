//
//  SettingsView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 29/05/24.
//

import SwiftUI

struct SettingsView: View {
    // Seria melhor usar o KeyChain para salvar essas informações, mas isso está fora do escopo deste exemplo
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""
//    @AppStorage("campo3") private var campo3: String = ""
    @AppStorage("app_name") private var appName: String = ""
    
    @AppStorage("enroll_with_risk") private var enrollWithRisk: Bool = false
    @AppStorage("pkce") private var pkce: Bool = true

    func clearSettings() {
        urlIdp = ""
        clientSecret = ""
        appName = ""
        enrollWithRisk = false
        pkce = true
    }
    
    var body: some View {
        
        NavigationView {

            VStack {

                HStack() {
                    Spacer()
                    
                    Button(action: {
                        clearSettings()
                    })
                    {
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(hex: "#333333"))
                            .padding()
                    }
                } // -- HStack


                LoginScreenHeaderView()

            
                Form {
                    Section(header: Text("Settings")) {
                        TextField("Server", text: $urlIdp)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                        TextField("Client Secret", text: $clientSecret)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        //                    TextField("Campo 3 (URL)", text: $campo3)
                        //                        .autocapitalization(.none)
                        //                        .disableAutocorrection(true)
                        TextField("App Name", text: $appName)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } // -- section
                    
                    Section(header: Text("Security")) {
                        HStack {
                            Text("Enroll with Risk:")
                                .foregroundColor(.gray)
                            Spacer()
                            Toggle("", isOn: $enrollWithRisk)
                                .tint(Color(hex: "#333333"))
                        }
                        
                        HStack {
                            Text("PKCE")
                                .foregroundColor(.gray)
                            Spacer()
                            Toggle("", isOn: $pkce)
                                .tint(Color(hex: "#333333"))
                        }
                    } // -- section
                }
                
            } // -- VStack
            .navigationBarTitle("", displayMode: .inline)
            .background(Color(hex: "#F2F2F6"))
            .padding(.horizontal)
        }
        
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
