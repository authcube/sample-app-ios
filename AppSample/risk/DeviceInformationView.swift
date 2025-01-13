//
//  DeviceInformationView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct DeviceInformationView: View {
    
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var deviceInformation: String = ""
    
    var body: some View {
        
        VStack {
            
            HeaderView()
            
            Button {
                
                self.deviceInformation = viewModel.appDelegate.authfySdk.getDeviceInfo()
                
            } label: {
                Text("Collect Device Information")
                    .padding()
                    .frame(width: 250, height: 50)
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
            
            ScrollView {
                Text("\(deviceInformation)")
                // If you want to allow text selection (so users can copy)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding()
        }// -- VStack
        .navigationTitle("Device Information")
        
        
    }
}

#Preview {
    let _appDelegate = AppDelegate()
    DeviceInformationView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
