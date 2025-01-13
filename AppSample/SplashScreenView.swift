//
//  SplashScreenView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 13/01/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        
        VStack {
            
            Spacer()
            
            VStack {
                HeaderView()
                
                Text("Sample App")
                    .font(.title)
            }
            
            Spacer()
            
            VStack {
                FooterView()
            }
        }
        
        
    }
}

#Preview {
    SplashScreenView()
}
