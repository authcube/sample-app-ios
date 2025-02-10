//
//  JWKS_Key.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 10/02/25.
//

struct Key: Codable {
    let alg: String
    let e: String
    let kid: String
    let kty: String
    let n: String
    let use: String
}

struct KeysResponse: Codable {
    let keys: [Key]
}
