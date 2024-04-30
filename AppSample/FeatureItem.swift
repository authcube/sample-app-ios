//
//  FeatureItem.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI

struct FeatureItem: View {
    var title: String
    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
            Text(title)
            Spacer()
            Image(systemName: "checkmark")
        }
        .padding()
    }
}

struct FeatureItem_Previews: PreviewProvider {
    static var previews: some View {
        FeatureItem(title: "test")
    }
}
