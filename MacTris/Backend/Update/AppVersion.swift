//
//  Version.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

struct AppVersion: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int

    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }
    init(string: String) {
        let parts = Array(string.split(separator: ".").map { Int(String($0)) ?? 0 })
        self.major = parts.count > 0 ? parts[0] : 0
        self.minor = parts.count > 1 ? parts[1] : 0
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major && lhs.minor < rhs.minor {
            return true
        }
        return false
    }

    var description: String {
        return "v\(major).\(minor)"
    }
}
