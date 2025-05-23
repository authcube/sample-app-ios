//
//  ToolkitView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 09/01/25.
//

import SwiftUI

// 1. Model
struct KeyValuePair: Identifiable, Codable {
    let id: UUID
    var key: String
    var value: String
    
    // Only include "key" and "value" in the JSON
    enum CodingKeys: String, CodingKey {
        case key
        case value
    }
    
    init(id: UUID = UUID(), key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
    
    // Initializer for Decodable conformance
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.value = try container.decode(String.self, forKey: .value)
        self.id = UUID() // Assign a default value or handle differently if needed
    }
}

// 2. ViewModel
class KeyValueViewModel: ObservableObject {
    @Published var pairs: [KeyValuePair] = []
    
    func addPair(key: String, value: String) {
        let newPair = KeyValuePair(key: key, value: value)
        pairs.append(newPair)
    }
    
    func updatePair(_ pair: KeyValuePair, newKey: String, newValue: String) {
        guard let index = pairs.firstIndex(where: { $0.id == pair.id }) else { return }
        pairs[index].key = newKey
        pairs[index].value = newValue
    }
    
    func removePair(_ pair: KeyValuePair) {
        pairs.removeAll { $0.id == pair.id }
    }
    
    func toJSON() -> String? {
        // Transform the array of KeyValuePair into an array of dictionaries
        let transformedPairs = pairs.map { pair in
            return [pair.key: pair.value]
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            // Encode the array of dictionaries
            let jsonData = try encoder.encode(transformedPairs)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error encoding to JSON: \(error)")
            return nil
        }
    }
}


struct ToolkitView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    // AppStorage
    @AppStorage("url_idp") private var urlIdp: String = ""
    @AppStorage("client_secret") private var clientSecret: String = ""
    
    
    @StateObject private var keyViewModel = KeyValueViewModel()
    
    // alert
    @State private var isLoading = false
    @State private var loadingText: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // For editing an existing pair
    @State private var editPair: KeyValuePair?
    @State private var editKey: String = ""
    @State private var editValue: String = ""
    @State private var showEditSheet = false
    
    // For adding a new pair
    @State private var newKey: String = ""
    @State private var newValue: String = ""
    @State private var showAddSheet = false
    
    @State private var deviceEnrollment: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                HeaderView()
                
                Text("Custom Attributes")
                
                // List
                List {
                    ForEach(keyViewModel.pairs) { pair in
                        VStack(alignment: .leading) {
                            Text("Key: \(pair.key)")
                                .font(.headline)
                            Text("Value: \(pair.value)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Swipe actions (iOS 15+)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                keyViewModel.removePair(pair)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                // Prepare edit fields and open the sheet
                                editPair = pair
                                editKey = pair.key
                                editValue = pair.value
                                showEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.inset)
                // Edit Sheet
                .sheet(isPresented: $showEditSheet) {
                    editView
                }
                // Add Sheet
                .sheet(isPresented: $showAddSheet) {
                    addView
                }
                // -- List
                
                
                VStack {
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
                    
                    if isLoading {
                        Text("\(loadingText)")
                            .padding()
                            .frame(width: 250, height: 50)
                    }
                    else {
                        Button {
                            doEvaluate(withPostEvaluate: deviceEnrollment)
                        } label: {
                            Text("Evaluate")
                                .padding()
                                .frame(width: 250, height: 50)
                        }
                        .foregroundColor(Color(hex: "#F4F6F8"))
                        .background(Color(hex: "#333333"))
                        .cornerRadius(10)
                    }
                    
                } // -- VStack
                .padding()
                
            }
            
        } // -- NavigationView
        .navigationTitle("Toolkit")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Evaluation", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        } message: {
            Text("\(alertMessage)")
        }
    } // -- body
    
    
    
    // A separate view for editing an existing pair
    private var editView: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Key/Value")) {
                    TextField("Key", text: $editKey)
                        .textInputAutocapitalization(.never)
                    TextField("Value", text: $editValue)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationBarTitle("Edit Pair", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showEditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let pair = editPair {
                            keyViewModel.updatePair(pair, newKey: editKey, newValue: editValue)
                        }
                        showEditSheet = false
                    }
                }
            }
        }
    }
    
    // A separate view for adding a new pair
    private var addView: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Key/Value")) {
                    TextField("Key", text: $newKey)
                        .textInputAutocapitalization(.never)
                    TextField("Value", text: $newValue)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationBarTitle("Add Pair", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddSheet = false
                        // Clear inputs if you want
                        newKey = ""
                        newValue = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !newKey.isEmpty else { return }
                        keyViewModel.addPair(key: newKey, value: newValue)
                        newKey = ""
                        newValue = ""
                        showAddSheet = false
                    }
                }
            }
        }
    }
    
    // do evaluate
    func doEvaluate(withPostEvaluate postEvaluate: Bool) {
        
        let fixedUrl = urlIdp.components(separatedBy: "/").dropLast().joined(separator: "/")
        let evaluateEndpoint = URL(string: "\(fixedUrl)/risk/evaluate")!
        
        let jsonString = #"""
        {
            "additional_inputs": 
                \#(keyViewModel.toJSON() ?? "[]"),
            "dna": "\#(viewModel.appDelegate.authfySdk.getDeviceInfo())",
            "username": "\#(viewModel.appDelegate.getUsername())",
            "verbose": false
        }
        """#
        
        print("data to evaluate: \(jsonString)")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error creating JSON Body")
            alertMessage = "Error creating JSON Body"
            showAlert = true
            return
        }
        
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let accessToken = accessToken else {
                print("Evaluate - unable to get accessToken")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: evaluateEndpoint)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            urlRequest.httpBody = jsonData
            
            // Perform request...
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                
                isLoading = false
                
                // Verifique se houve algum erro
                if let error = error {
                    print("Error performing the request: \(error)")
                    return
                }
                
                // Verificar a resposta HTTP e status code
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Tratar a resposta com sucesso
                    if let data = data {
                        // Supondo que a resposta seja um JSON
                        do {
                            // Tentar decodificar a resposta JSON, supondo uma estrutura básica
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            print("Resposta JSON: \(responseObject!)")
                            
                            let evaluateDataString = try extractEvaluateData(from: responseObject!)
                            
                            if let evaluateDataString = evaluateDataString {
                                print("Evaluate Data String: \(evaluateDataString)")
                                
                                if postEvaluate {
                                    doPostEvaluate(withEvaluateData: evaluateDataString)
                                } else {
                                    
                                    if deviceEnrollment {
                                        alertMessage = "Evaluation and Post-Evaluation: completed"
                                    } else {
                                        alertMessage = "Evaluation transaction-id: \(evaluateDataString)"
                                    }
                                    showAlert = true

                                }
                                
                            } else {
                                print("Error: Unable to find the expected data in the data structure.")
                            }

                            
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Evaluation - HTTP Status Code: \(httpResponse.statusCode)")
                        alertMessage = "Evaluation - HTTP Status Code: \(httpResponse.statusCode)"
                        showAlert = true
                        return
                    }
                    
                    alertMessage = "Evaluation - HTTP Unknown error"
                    showAlert = true
                    
                }
                
            }
            
            // Iniciar a tarefa
            isLoading = true
            loadingText = "Evaluating ..."
            task.resume()
            
        } // -- performAction
    }
    
    func doPostEvaluate(withEvaluateData evaluationData: String) {
        
        let fixedUrl = urlIdp.components(separatedBy: "/").dropLast().joined(separator: "/")
        let evaluateEndpoint = URL(string: "\(fixedUrl)/risk/evaluate")!
        
        let jsonString = #"""
        {
            \#(evaluationData),
            "secondary-auth": true,
            "username": "\#(viewModel.appDelegate.getUsername())",
            "verbose": false
        }
        """#
        
        print("data to evaluate: \(jsonString)")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error creating JSON Body")
            alertMessage = "Error creating JSON Body"
            showAlert = true
            return
        }
        
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let accessToken = accessToken else {
                print("Post-Evaluate - unable to get accessToken")
                return
            }
            
            // Add Bearer token to request
            var urlRequest = URLRequest(url: evaluateEndpoint)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            urlRequest.httpBody = jsonData
            
            // Perform request...
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                
                isLoading = false
                
                // Verifique se houve algum erro
                if let error = error {
                    print("Error post-evaluate: \(error)")
                    return
                }
                
                // Verificar a resposta HTTP e status code
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Tratar a resposta com sucesso
                    if let data = data {
                        // Supondo que a resposta seja um JSON
                        do {
                            // Tentar decodificar a resposta JSON, supondo uma estrutura básica
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            print("Resposta JSON: \(responseObject!)")
                                                           
                            doEvaluate(withPostEvaluate: false)
                            
                        } catch {
                            print("Error post-evaluate: \(error)")
                        }
                    }
                } else {
                    // Lidar com resposta HTTP diferente de 200 OK
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Post-Evaluation - HTTP Status Code: \(httpResponse.statusCode)")
                        alertMessage = "Post-Evaluation - HTTP Status Code: \(httpResponse.statusCode)"
                        showAlert = true
                        return
                    }
                    
                    alertMessage = "Post-Evaluation - HTTP Unknown error"
                    showAlert = true
                    
                }
                
            }
            
            // Iniciar a tarefa
            isLoading = true
            loadingText = "Device Enrollment ..."
            task.resume()
            
        } // -- performAction
    }
    
    func extractEvaluateData(from responseObject: [String: Any]) throws -> String? {
        guard let links = responseObject["links"] as? [[String: Any]] else {
            throw ExtractionError.linksNotFound
        }

        for link in links {
            guard let parameters = link["parameters"] as? [String: Any],
                  let evaluateData = parameters["evaluate-data"] as? [String: Any] else {
                continue // Skip to the next link if "parameters" or "evaluate-data" are not found
            }

            // Format the output as a dictionary with "evaluate-data" as the key
//            let formattedEvaluateData = ["evaluate-data": evaluateData]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: evaluateData, options: [])
                        
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw ExtractionError.stringConversionFailed
                }
                // Create a dictionary with "evaluate-data" as the key and the jsonString as value
                let formattedString = "\"evaluate-data\": \(jsonString)"
                return formattedString
            } catch {
                throw ExtractionError.jsonSerializationFailed(error)
            }
        }

        return nil // Return nil if "evaluate-data" is not found in any link
    }

    // Define custom errors for better error handling
    enum ExtractionError: Error {
        case linksNotFound
        case evaluateDataNotFound
        case jsonSerializationFailed(Error)
        case stringConversionFailed
    }
    
}



#Preview {
    let _appDelegate = AppDelegate()
    ToolkitView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
