//
//  Version.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

struct MacTrisVersion: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int

    static func < (lhs: MacTrisVersion, rhs: MacTrisVersion) -> Bool {
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
