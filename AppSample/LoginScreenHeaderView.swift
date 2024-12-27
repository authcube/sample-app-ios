//
//  LoginScreenHeaderView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import SwiftUI

struct LoginScreenHeaderView: View {
    var body: some View {
        VStack{
            Image("authcube-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 50)
            
            Text("Sample App")
                .fontWeight(Font.Weight.bold)
        }
    }
}

struct LoginScreenHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenHeaderView()
    }
}
