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
        let parts = Array(string.split(separator: ".", omittingEmptySubsequences: false).map { String($0) })

        guard parts.count >= 1, parts.count < 4, parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy { $0.isNumber } }) else {
            return nil
        }

        let numbers = parts.compactMap(Int.init)
        guard numbers.count == parts.count else {
            return nil
        }

        self.major = numbers[0]
        self.minor = numbers.count > 1 ? numbers[1] : 0
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
