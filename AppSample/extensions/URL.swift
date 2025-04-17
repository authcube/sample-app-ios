//
//  URL.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 14/04/25.
//
import Foundation

extension URL {
    /// Verifica se esta URL compartilha o mesmo scheme, host e port que outra URL.
    func hasSameBase(as otherURL: URL) -> Bool {
        // Comparar Schemes (case-insensitive)
        guard let selfScheme = self.scheme?.lowercased(), let otherScheme = otherURL.scheme?.lowercased(), selfScheme == otherScheme else {
            return false
        }

        // Comparar Hosts (case-insensitive)
        guard let selfHost = self.host?.lowercased(), let otherHost = otherURL.host?.lowercased(), selfHost == otherHost else {
            return false
        }

        // Comparar Ports
        guard self.port == otherURL.port else {
            return false
        }

        return true
    }
}
