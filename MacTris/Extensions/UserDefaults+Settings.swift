//
//  UserDefaults+Settings.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation

extension UserDefaults {

    private static let defaultUpdateUrl = URL(string: "https://api.github.com/repos/Jegge/MacTris/")!

    private struct Key {
        static let musicVolume = "MusicVolume"
        static let fxVolume = "FxVolume"
        static let fullscreen = "Fullscreen"
        static let keyboardBindings = "KeyboardBindings"
        static let startLevel = "StartLevel"
        static let randomGeneratorMode = "RandomGeneratorMode"
        static let appearance = "Appearance"
        static let autoShift = "AutoShift"
        static let wallKick = "WallKick"
        static let hardDrop = "HardDrop"
        static let animations = "Animations"
        static let updateCheckBaseUrl = "UpdateCheckBaseUrl"
    }

    func register() {
        self.register(defaults: [
            Key.musicVolume: 100,
            Key.fxVolume: 100,
            Key.fullscreen: false,
            Key.keyboardBindings: [],
            Key.startLevel: 0,
            Key.randomGeneratorMode: RandomGeneratorMode.sevenBag.rawValue,
            Key.appearance: Appearance.plain.rawValue,
            Key.autoShift: AutoShift.modern.rawValue,
            Key.wallKick: false,
            Key.hardDrop: false,
            Key.animations: true,
            Key.updateCheckBaseUrl: UserDefaults.defaultUpdateUrl
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

    var startLevel: Int {
        get {
            return max(0, min(19, self.integer(forKey: Key.startLevel)))
        }
        set {
            self.setValue(max(0, min(19, newValue)), forKey: Key.startLevel)
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

    var randomGeneratorMode: RandomGeneratorMode {
        get {
            return RandomGeneratorMode(rawValue: self.integer(forKey: Key.randomGeneratorMode)) ?? .sevenBag
        }
        set {
            self.set(newValue.rawValue, forKey: Key.randomGeneratorMode)
        }
    }

    var appearance: Appearance {
        get {
            return Appearance(rawValue: self.integer(forKey: Key.appearance)) ?? .plain
        }
        set {
            self.set(newValue.rawValue, forKey: Key.appearance)
        }
    }

    var autoShift: AutoShift {
        get {
            return AutoShift(rawValue: self.integer(forKey: Key.autoShift)) ?? .modern
        }
        set {
            self.set(newValue.rawValue, forKey: Key.autoShift)
        }
    }

    var wallKick: Bool {
        get {
            return self.bool(forKey: Key.wallKick)
        }
        set {
            self.setValue(newValue, forKey: Key.wallKick)
        }
    }

    var hardDrop: Bool {
        get {
            return self.bool(forKey: Key.hardDrop)
        }
        set {
            self.setValue(newValue, forKey: Key.hardDrop)
        }
    }

    var animations: Bool {
        get {
            return self.bool(forKey: Key.animations)
        }
        set {
            self.setValue(newValue, forKey: Key.animations)
        }
    }

    var tetrisOptions: TetrisOptions {
        TetrisOptions(startingLevel: self.startLevel, autoShift: self.autoShift, randomGeneratorMode: self.randomGeneratorMode, wallKick: self.wallKick, hardDrop: self.hardDrop)
    }

    var visualOptions: VisualOptions {
        VisualOptions(appearance: self.appearance, animations: self.animations)
    }

    var updateCheckBaseUrl: URL {
        self.url(forKey: Key.updateCheckBaseUrl) ?? UserDefaults.defaultUpdateUrl
    }
}
