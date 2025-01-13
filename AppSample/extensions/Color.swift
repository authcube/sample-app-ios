//
//  Color.swift
//  AppSample
//
//  This extension convert hex values to color to use
//  on components
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//

import SwiftUI

extension Color {
    /// Initializes a Color from a hex string (e.g. "#FF0000" or "FF0000").
    init?(hex: String, alpha: Double = 1.0) {
        // Remove any extra characters like "#" or spaces
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        // The Scanner will store the numeric value in this variable
        var rgbValue: UInt64 = 0

        // Convert the string into an unsigned 64-bit integer
        guard Scanner(string: hexSanitized).scanHexInt64(&rgbValue) else {
            return nil
        }

        // If the string is a standard 6-digit hex, parse into r/g/b
        let length = hexSanitized.count
        if length == 6 {
            let r = (rgbValue & 0xFF0000) >> 16
            let g = (rgbValue & 0x00FF00) >> 8
            let b = rgbValue & 0x0000FF

            self.init(
                .sRGB,
                red:   Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: alpha
            )
        } else {
            // You can handle 3-digit hex or 8-digit hex w/ alpha if needed
            return nil
        }
    }
}
