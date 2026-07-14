//
//  Bundle+Properties.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation

extension Bundle {
    var version: AppVersion {
        AppVersion(string: self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0")
    }

    var build: Int {
        Int(self.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
    }

    var copyright: String {
        self.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "© 2024-now Sebastian Boettcher"
    }
}
