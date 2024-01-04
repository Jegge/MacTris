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
        public static let keyRotateLeft = "KeyRotateLeft"
        public static let keyRotateRight = "KeyRotateRight"
        public static let keyMoveLeft = "KeyMoveLeft"
        public static let keyMoveRight = "KeyMoveRight"
        public static let keySoftDrop = "KeySoftDrop"
    }

    public func register() {
        self.register(defaults: [
            Key.musicVolume: 100,
            Key.fxVolume: 100,
            Key.fullscreen: false,
            Key.keyRotateLeft: KeyCode.a.rawValue,
            Key.keyRotateRight: KeyCode.s.rawValue,
            Key.keyMoveLeft: KeyCode.arrowLeft.rawValue,
            Key.keyMoveRight: KeyCode.arrowRight.rawValue,
            Key.keySoftDrop: KeyCode.arrowDown.rawValue
        ])
    }

    public var fullscreen: Bool {
        get {
            return self.bool(forKey: Key.fullscreen)
        }
        set {
            self.setValue(newValue, forKey: Key.fullscreen)
        }
    }

    public var musicVolume: Int {
        get {
            return max(0, min(100, self.integer(forKey: Key.musicVolume)))
        }
        set {
            self.setValue(max(0, min(100, newValue)), forKey: Key.musicVolume)
        }
    }

    public var fxVolume: Int {
        get {
            return max(0, min(100, self.integer(forKey: Key.fxVolume)))
        }
        set {
            self.setValue(max(0, min(100, newValue)), forKey: Key.fxVolume)
        }
    }

    public var keyRotateLeft: UInt16 {
        get {
            return UInt16(self.integer(forKey: Key.keyRotateLeft))
        }
        set {
            self.setValue(newValue, forKey: Key.keyRotateLeft)
        }
    }

    public var keyRotateRight: UInt16 {
        get {
            return UInt16(self.integer(forKey: Key.keyRotateRight))
        }
        set {
            self.setValue(newValue, forKey: Key.keyRotateRight)
        }
    }

    public var keyMoveLeft: UInt16 {
        get {
            return UInt16(self.integer(forKey: Key.keyMoveLeft))
        }
        set {
            self.setValue(newValue, forKey: Key.keyMoveLeft)
        }
    }

    public var keyMoveRight: UInt16 {
        get {
            return UInt16(self.integer(forKey: Key.keyMoveRight))
        }
        set {
            self.setValue(newValue, forKey: Key.keyMoveRight)
        }
    }

    public var keySoftDrop: UInt16 {
        get {
            return UInt16(self.integer(forKey: Key.keySoftDrop))
        }
        set {
            self.setValue(newValue, forKey: Key.keySoftDrop)
        }
    }
}
