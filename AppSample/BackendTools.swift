//
//  BackendTools.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import Foundation

class BackendTools {
    private var userInfo: [String: Any] = [:]
    
    func fetchUserInfo(_ appDelegate: AppDelegate, completion: @escaping (String) -> Void) {
        
        guard let authState = appDelegate.getAuthState(),
              let userinfoEndpoint = authState.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            completion("")
            return
        }
        
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                print("Error fetching fresh tokens: \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let accessToken = accessToken else {
                print("Error, accessToken is invalid, aborting")
                completion("")
                return
            }
            
            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.httpMethod = "GET"
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print("Error making request: \(error)")
                    completion("")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let data = data {
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                        self.userInfo = responseObject as? [String: Any] ?? [:]
                        let name = self.userInfo["uid"] as? String ?? ""
                        completion(name)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion("")
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    completion("")
                }
            }
            
            task.resume()
        }
    }
}
