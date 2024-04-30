//
//  ProgressBarView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI

struct ProgressBarView: View {
    
    @Binding var value: Float
    
    private var barColor: Color {
        if value > 0.5 { // Se o valor for maior que 15, mantenha azul (2/3 do progresso).
            return Color(UIColor.systemBlue)
        } else if value > 0.333 { // Se o valor for maior que 10 mas menor que 15, faça amarelo (1/3 do progresso).
            return Color(UIColor.systemYellow)
        } else { // Caso contrário, faça vermelho.
            return Color(UIColor.systemRed)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(barColor)
                    .animation(.linear, value: value)
            }.cornerRadius(45.0)
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(value: .constant(0.7))
    }
}
