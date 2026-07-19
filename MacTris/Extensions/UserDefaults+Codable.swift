//
//  UserDefaults+Codable.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 06.01.24.
//

import Foundation

extension UserDefaults {
    /// Encodes an `Encodable` value to JSON data and stores it in UserDefaults.
    func set<T>(encodable object: T, forKey key: String) where T: Encodable {
        if let data = try? JSONEncoder().encode(object) {
            set(data, forKey: key)
        }
    }

    /// Reads JSON data from UserDefaults and decodes it into a `Decodable` type.
    func decodable<T>(forKey key: String) -> T? where T: Decodable {
        if let data = data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
}
