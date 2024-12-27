//
//  Footer.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("COPYRIGHTS © SINCE 2009.")
                .font(.subheadline)
            Text("All Rights Reserved.")
                .font(.caption)
        }
    }
}

struct FooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        FooterView()
    }
}
