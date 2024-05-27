//
//  FeatureItem.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI

struct FeatureItem: View {
    
    var title: String
    var action: () -> Void
    var showCopyButton: Bool = true // default is showCopyButton
    var copyAction:() -> Void
    
    @State private var showCopySuccess: Bool = false
    
    var body: some View {
        
        HStack{
            
            Button(action: action) {
                HStack {
                    //                Image(systemName: "plus.circle.fill")
                    Text(title)
                    
                }
                .padding()
            }
            
            Spacer()
            
            if showCopyButton {
                
                Button(action: {
                    copyAction()
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
            }
            
        }
        .padding(.horizontal) // HStack
        
        
    }
}

struct FeatureItem_Previews: PreviewProvider {
    static var previews: some View {
        FeatureItem(title: "test",
                    action: {
            print("action")
        },
                    showCopyButton: true,
                    copyAction: {
            print("copy")
        }
        )
    }
}
