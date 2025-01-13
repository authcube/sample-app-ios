//
//  HeaderView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//
import SwiftUI

struct HeaderView: View {
    
    var body: some View {
        VStack {
            Image("authcube-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 50)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
//        .background(Color(hex: "#F2F2F6"))
    }
    
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
