//
//  UserDefaults+Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation

extension UserDefaults {

    func registerDefaults () {
        self.register(defaults: [
            "Fullscreen": "False"
        ])
    }

    var isFullscreen: Bool {
        get {
            return self.bool(forKey: "Fullscreen")
        }
        set {
            self.setValue(newValue, forKey: "Fullscreen")
        }
    }
}
