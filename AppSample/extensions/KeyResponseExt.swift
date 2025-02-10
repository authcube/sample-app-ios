//
//  KeyResponseExt.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 10/02/25.
//

import Foundation

extension KeysResponse {
    /// Returns the JSON string of the key whose `use` field matches the given value.
    func keyJSON(forUse desiredUse: String) -> String? {
        // Find the key with the desired `use` value.
        guard let matchingKey = keys.first(where: { $0.use == desiredUse }) else {
            return nil
        }
        
        // Encode the key back into JSON.
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]  // Optional formatting
        do {
            let data = try encoder.encode(matchingKey)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding key: \(error)")
            return nil
        }
    }
}
