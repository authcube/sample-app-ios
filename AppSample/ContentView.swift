//
//  ContentView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 17/04/24.
//

import SwiftUI
import AuthenticationServices
import AppAuthCore


struct ContentView: View {
    //    var appDelegate: AppDelegate
    @ObservedObject var viewModel: AppSampleViewModel
    
    @State private var isAuthorized: Bool = false
    
    @State private var showingSettings = false
    
    @State private var username = ""
    
    @StateObject private var locationManager = LocationManager()
    
    
    // callback
    func changeAuthenticationState(_ authorized: Bool) {
        self.isAuthorized = authorized
        
        if !authorized {
            return
        }
        
        self.username = viewModel.appDelegate.getUsername()
        
    }
    
    var body: some View {
        
        NavigationView {
            // --
            VStack {
                
                Group {
                    
                    if isAuthorized {
                        
                        VStack {
                            Spacer()
                            
                            Text("Welcome back, \(username)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            NavigationLink(destination: DashboardView(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)) {
                                
                                Text("Enter")
                                    .frame(width: 200, height: 50)
                                    .foregroundColor(Color(hex: "#F4F6F8"))
                                    .background(Color(hex: "#333333"))
                                    .cornerRadius(8)
                                
                            }
                            
//                            Spacer()
                            
                            // --
                            VStack {
                                switch locationManager.authorizationStatus {
                                case .notDetermined:
                                    Text("Location access not determined")
                                    Button("Request Location") {
                                        locationManager.requestLocation()
                                    }
                                case .restricted:
                                    Text("Location access restricted")
                                case .denied:
                                    Text("Location access denied")
                                    Text("Please enable in Settings")
                                case .authorizedWhenInUse, .authorizedAlways:
                                    if let location = locationManager.location {
                                        Text("Latitude: \(location.coordinate.latitude)")
                                        Text("Longitude: \(location.coordinate.longitude)")
                                    } else {
                                        Text("Fetching location...")
                                    }
                                default:
                                    Text("Unknown location status")
                                }
                            }
                            // --
                            
                            Spacer()
                        }
                        
                        
                    } else {
                        
                        HStack() {
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(hex: "#333333"))
                                
                                    .padding()
                            }
                        } // -- HStack
                        
                        
                        VStack {
                            LoginScreenHeaderView()
                            
                            Spacer()
                            
                            OAuthView(appDelegate: viewModel.appDelegate, changeAuthenticationState: changeAuthenticationState)
                            Spacer()

                        } // -- VStack
                        .navigationBarTitle("", displayMode: .inline)
                        .padding(.vertical)
                        
                    } // -- else

                } // -- Group
                
                FooterView()
                
                
            }.navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .onAppear{
                    changeAuthenticationState(viewModel.appDelegate.isAuthorized())
                    locationManager.requestLocation()

                }
            
            // -- VStack
        } // -- NavigationView
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let _appDelegate = AppDelegate()
        ContentView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
    }
}
