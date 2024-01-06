//
//  UserDefaults+Codable.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 06.01.24.
//

import Foundation

extension UserDefaults {
    func set<T>(encodable object: T, forKey key: String) where T: Encodable {
        if let data = try? JSONEncoder().encode(object) {
            set(data, forKey: key)
        }
    }

    func decodable<T>(forKey key: String) -> T? where T: Decodable {
        if let data = data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
}
