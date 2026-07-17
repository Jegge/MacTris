//
//  AppVersion.swift
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
