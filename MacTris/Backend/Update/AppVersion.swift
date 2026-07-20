//
//  AppVersion.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

/// Represents a semantic version with major and minor components (e.g. "v1.3").
struct AppVersion: Equatable, Comparable, CustomStringConvertible {
    /// The major version number.
    let major: Int
    /// The minor version number.
    let minor: Int

    /// Creates a version with the given major and minor components.
    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }
    /// Parses a version string such as `"1.3"` or `"1.3.0"`. Returns `nil` if the string is invalid.
    init?(string: any StringProtocol) {
        if !string.allSatisfy({ $0.isNumber || $0 == "." }) {
            return nil
        }

        let parts = Array(string.split(separator: ".").map { Int($0) ?? 0 })

        switch parts.count {
        case 1:
            self.major = parts[0]
            self.minor = 0
        case 2...3:
            self.major = parts[0]
            self.minor = parts[1]
        default:
            return nil
        }
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
