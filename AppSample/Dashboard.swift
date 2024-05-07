//
//  Dashboard.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 06/05/24.
//

import SwiftUI

struct Dashboard: View {
    // parameters
    var appDelegate: AppDelegate
    var changeAuthenticationState: (Bool) -> Void
    
    // state
    @State private var seconds = 0
    @State private var countdown = 30
    @State private var codeNumber = Int.random(in: 100000...999999)
    
    @State private var progressValue: Float = 1.0
    
    // timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        VStack {
            
            VStack {
                Text("Username: \(self.appDelegate.getUsername())")
                FeatureItem(title: "ID Tokens")
                FeatureItem(title: "Access Token")
                FeatureItem(title: "Refresh Token")
                FeatureItem(title: "Seeds")
            }
            
            Text("\(countdown)")
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    
                    // let seconds = Calendar.current.component(.second, from: Date())
                    seconds = Calendar.current.component(.second, from: Date())
                    let nextReset = (seconds >= 30 ? 60 : 30)
                    self.countdown = nextReset - seconds
                    
                    if countdown == 30 || countdown == 60 {
                        self.codeNumber = Int.random(in: 100000...999999)
                    }
                    self.progressValue = Float(countdown) / 30.0
                    
                }
                .padding()
                .background(self.countdown < 10 ? Color.red : Color.clear)
                .animation(.default, value: countdown)
                .clipShape(Circle())
            
            
            Text("Code: \(codeNumber)")
                .font(.title)
                .padding()
            
            ProgressBarView(value: $progressValue)
                .frame(height: 20)
                .padding()
            
            Button {
                
                appDelegate.deleteAuthStateFromKeychain()
                changeAuthenticationState(false)
                
            } label: {
                Text("Logout")
                    .padding()
                    .frame(width: 200, height: 50)
            }
            .background(Color(#colorLiteral(red: 0.82, green: 0.18, blue: 0.18, alpha: 1)))
            .foregroundColor(.white)
            .cornerRadius(10)
            
        } // VStack
        
    }
}

struct Dashboard_Previews: PreviewProvider {
    
    class MockAppDelegate: UIResponder, UIApplicationDelegate {
        // Add any necessary mock properties here
    }
    
    static var previews: some View {
        Dashboard(appDelegate: UIApplication.shared.delegate as! AppDelegate, changeAuthenticationState: { _ in })
    }
}
