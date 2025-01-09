//
//  ToolkitView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

struct ToolkitView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    //
    @State private var deviceInfo: String = ""
    @State private var host: String = "localhost"
    @State private var port: String = "443"
    @State private var customAttributes: String = #"{ "json_schema": "" }"#
    @State private var deviceEnrollment: Bool = false
    
    var body: some View {
        VStack {
            
            HeaderView()
            Spacer()
            
            // -- Form
            
            VStack(alignment: .leading, spacing: 16) {
                        
                        // Device Information
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Device Information:")
                                .font(.headline)
                            TextField("Device Info", text: $deviceInfo)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                // If you want it read-only (grayed out), do:
                                .disabled(true)
                        }
                        
                        // Host
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Host:")
                                .font(.headline)
                            TextField("localhost", text: $host)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(true)
                        }
                        
                        // Port
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Port:")
                                .font(.headline)
                            TextField("localhost", text: $port)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(true)
                        }
                        
                        // Custom Attributes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Custom Attributes:")
                                .font(.headline)
                            
                            // If you want a multi-line area, TextEditor is good:
                            TextEditor(text: $customAttributes)
                                .frame(minHeight: 80)
                                .border(Color.gray.opacity(0.3), width: 1)
                                .disabled(true) // read-only
                                .cornerRadius(4)
                                .padding(.top, 4)
                        }

                        // Device Enrollment Toggle
                        HStack {
                            Text("Device Enrollment:")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $deviceEnrollment)
                                .labelsHidden()
                                // Optional: styling for the toggle
                                // .toggleStyle(SwitchToggleStyle(tint: .red))
                        }

                        Spacer()
                    }
                    .padding()
            
            // -- Form
            
            Button {

            } label: {
                Text("Test")
                    .padding()
                    .frame(width: 250, height: 50)
            }
            .foregroundColor(Color(hex: "#F4F6F8"))
            .background(Color(hex: "#333333"))
            .cornerRadius(10)
            
            Spacer()
            
            
        } // -- VStack
        .navigationTitle("Toolkit")
    }
}

#Preview {
    let _appDelegate = AppDelegate()
    ToolkitView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
