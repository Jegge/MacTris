//
//  GameSettings.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 21.07.26.
//

import Foundation

/// Provides validated access to the game's persisted settings.
final class GameSettings {
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.userDefaults.register(defaults: [
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
            Key.updateCheckBaseUrl: GameSettings.defaultUpdateUrl
        ])
    }

    private enum Key {
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

    private static let defaultUpdateUrl = URL(string: "https://api.github.com/repos/Jegge/MacTris/")!

    private let userDefaults: UserDefaults

    /// Whether the game window should use full-screen mode.
    var fullscreen: Bool {
        get {
            self.userDefaults.bool(forKey: Key.fullscreen)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.fullscreen)
        }
    }

    /// The music volume, clamped to the range 0...100.
    var musicVolume: Int {
        get {
            max(0, min(100, self.userDefaults.integer(forKey: Key.musicVolume)))
        }
        set {
            self.userDefaults.set(max(0, min(100, newValue)), forKey: Key.musicVolume)
        }
    }

    /// The sound-effect volume, clamped to the range 0...100.
    var fxVolume: Int {
        get {
            max(0, min(100, self.userDefaults.integer(forKey: Key.fxVolume)))
        }
        set {
            self.userDefaults.set(max(0, min(100, newValue)), forKey: Key.fxVolume)
        }
    }

    /// The starting level, clamped to the supported level range.
    var startLevel: Int {
        get {
            max(0, min(Tetris.maxStartingLevel, self.userDefaults.integer(forKey: Key.startLevel)))
        }
        set {
            self.userDefaults.set(max(0, min(Tetris.maxStartingLevel, newValue)), forKey: Key.startLevel)
        }
    }

    /// The persisted mutable keyboard bindings, normalized through InputMapper validation.
    var keyboardBindings: [InputMapper.KeyBinding] {
        get {
            return self.userDefaults.decodable(forKey: Key.keyboardBindings) ?? []
        }
        set {
            self.userDefaults.set(encodable: newValue, forKey: Key.keyboardBindings)
        }
    }

    /// The selected random tetromino generator mode.
    var randomGeneratorMode: RandomGeneratorMode {
        get {
            RandomGeneratorMode(rawValue: self.userDefaults.integer(forKey: Key.randomGeneratorMode)) ?? .sevenBag
        }
        set {
            self.userDefaults.set(newValue.rawValue, forKey: Key.randomGeneratorMode)
        }
    }

    /// The selected tile appearance.
    var appearance: Appearance {
        get {
            Appearance(rawValue: self.userDefaults.integer(forKey: Key.appearance)) ?? .plain
        }
        set {
            self.userDefaults.set(newValue.rawValue, forKey: Key.appearance)
        }
    }

    /// The selected auto-shift configuration.
    var autoShift: AutoShift {
        get {
            AutoShift(rawValue: self.userDefaults.integer(forKey: Key.autoShift)) ?? .modern
        }
        set {
            self.userDefaults.set(newValue.rawValue, forKey: Key.autoShift)
        }
    }

    /// Whether wall-kick rotation is enabled.
    var wallKick: Bool {
        get {
            self.userDefaults.bool(forKey: Key.wallKick)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.wallKick)
        }
    }

    /// Whether hard drop is enabled.
    var hardDrop: Bool {
        get {
            self.userDefaults.bool(forKey: Key.hardDrop)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.hardDrop)
        }
    }

    /// Whether visual animations are enabled.
    var animations: Bool {
        get {
            self.userDefaults.bool(forKey: Key.animations)
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.animations)
        }
    }

    /// The base URL used for release update checks.
    var updateCheckBaseUrl: URL {
        get {
            self.userDefaults.url(forKey: Key.updateCheckBaseUrl) ?? GameSettings.defaultUpdateUrl
        }
        set {
            self.userDefaults.set(newValue, forKey: Key.updateCheckBaseUrl)
        }
    }

    /// The current gameplay options.
    var tetrisOptions: TetrisOptions {
        TetrisOptions(startingLevel: self.startLevel,
                      autoShift: self.autoShift,
                      randomGeneratorMode: self.randomGeneratorMode,
                      wallKick: self.wallKick,
                      hardDrop: self.hardDrop)
    }

    /// The current visual options.
    var visualOptions: VisualOptions {
        VisualOptions(appearance: self.appearance, animations: self.animations)
    }
}
