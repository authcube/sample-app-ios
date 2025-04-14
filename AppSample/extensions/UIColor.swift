//
//  UIColor.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 14/04/25.
//

import UIKit // Required for UIColor

extension UIColor {
    /**
     Initializes and returns a UIColor object using a hexadecimal string.

     - Parameter hex: The hexadecimal string (e.g., "#RRGGBB", "RRGGBB").
     - Parameter alpha: The alpha (opacity) value for the color (default is 1.0).
     - Returns: An optional UIColor object, or nil if the hex string is invalid.
     */
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        // 1. Sanitize the string (remove # and whitespace)
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        // 2. Convert the sanitized hex string to a UInt64 integer
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            // Return nil if conversion fails
            return nil
        }

        // 3. Ensure we have 6 characters (RRGGBB)
        let length = hexSanitized.count
        guard length == 6 else {
            // Return nil if not 6 characters (can be extended to support RGB or RRGGBBAA)
            return nil
        }

        // 4. Extract the Red, Green, Blue components
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        // 5. Call the standard UIColor initializer with the calculated components
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
