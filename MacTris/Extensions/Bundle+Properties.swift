//
//  Bundle+Properties.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation

extension Bundle {
    /// The app's short version string (e.g. "v1.3").
    var version: AppVersion {
        AppVersion(string: self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0") ?? AppVersion(major: 1, minor: 0)
    }

    /// The app's build number.
    var build: Int {
        Int(self.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
    }

    /// The app's human-readable copyright string.
    var copyright: String {
        self.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "© 2024-now Sebastian Boettcher"
    }
}
