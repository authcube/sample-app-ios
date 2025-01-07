//
//  TotpView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 07/01/25.
//

import SwiftUI

struct TotpView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    @State var otpType: String
    @State var isActive: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let _appDelegate = AppDelegate()
    TotpView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), otpType: "TOTP", isActive: true)
}
