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

    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    TextField("Connect's URL", text: $urlIdp)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    TextField("Client Secret", text: $clientSecret)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
//                    TextField("Campo 3 (URL)", text: $campo3)
//                        .autocapitalization(.none)
//                        .disableAutocorrection(true)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
