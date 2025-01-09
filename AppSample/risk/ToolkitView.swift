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
    
    init(id: UUID = UUID(), key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
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
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(pairs)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding to JSON: \(error)")
            return nil
        }
    }
}


struct ToolkitView: View {
    @ObservedObject var viewModel: AppSampleViewModel
    
    @StateObject private var keyViewModel = KeyValueViewModel()
    
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
                .navigationTitle("Custom Attributes")
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
                    
                    // -- Form
                    
                    Button {
                        
                    } label: {
                        Text("Evaluate")
                            .padding()
                            .frame(width: 250, height: 50)
                    }
                    .foregroundColor(Color(hex: "#F4F6F8"))
                    .background(Color(hex: "#333333"))
                    .cornerRadius(10)
                    
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
    } // -- body
    
    
    
    // A separate view for editing an existing pair
    private var editView: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Key/Value")) {
                    TextField("Key", text: $editKey)
                    TextField("Value", text: $editValue)
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
                    TextField("Value", text: $newValue)
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
}



#Preview {
    let _appDelegate = AppDelegate()
    ToolkitView(viewModel: AppSampleViewModel(appDelegate: _appDelegate))
}
