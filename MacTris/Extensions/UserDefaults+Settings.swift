//
//  UserDefaults+Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation

extension UserDefaults {

    private struct Key {
        public static let musicVolume = "MusicVolume"
        public static let fxVolume = "FxVolume"
        public static let fullscreen = "Fullscreen"
        public static let keyboardBindings = "KeyboardBindings"
    }

    func register() {
        self.register(defaults: [
            Key.musicVolume: 100,
            Key.fxVolume: 100,
            Key.fullscreen: false,
            Key.keyboardBindings: []
        ])
    }

    var fullscreen: Bool {
        get {
            return self.bool(forKey: Key.fullscreen)
        }
        set {
            self.setValue(newValue, forKey: Key.fullscreen)
        }
    }

    var musicVolume: Int {
        get {
            return max(0, min(100, self.integer(forKey: Key.musicVolume)))
        }
        set {
            self.setValue(max(0, min(100, newValue)), forKey: Key.musicVolume)
        }
    }

    var fxVolume: Int {
        get {
            return max(0, min(100, self.integer(forKey: Key.fxVolume)))
        }
        set {
            self.setValue(max(0, min(100, newValue)), forKey: Key.fxVolume)
        }
    }

    var keyboardBindings: [InputMapper.KeyBinding] {
        get {
            return self.decodable(forKey: Key.keyboardBindings) ?? []
        }
        set {
            self.set(encodable: newValue, forKey: Key.keyboardBindings)
        }
    }
}
