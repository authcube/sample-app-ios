//
//  ContentView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var seconds = 0
    @State private var countdown = 30
    @State private var codeNumber = Int.random(in: 100000...999999)
    
    @State private var progressValue: Float = 1.0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        
        // --
        VStack {
            
            VStack {
                FeatureItem(title: "ID Tokens")
                FeatureItem(title: "Access Token")
                FeatureItem(title: "Refresh Token")
                FeatureItem(title: "Seeds")
            }
            
            Text("\(countdown)")
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    
//                    let seconds = Calendar.current.component(.second, from: Date())
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
            
            
            Text("Code: \(codeNumber)")
                .font(.title)
                .padding()
            
            ProgressBarView(value: $progressValue)
                .frame(height: 20)
                .padding()

        }
        
        // --
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
