//
//  SettingItem.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 19.07.26.
//

import Foundation
import AppKit

/// A single item in the settings menu.
protocol SettingItem {
    /// An identifier that matches the menu setting from the sks file.
    var identifier: String { get }
    /// The display value shown in the settings row.
    var value: String { get }
    /// The controller button description, or `empty string` if not applicable.
    var controllerValue: String { get }
    /// Adjusts the setting in the given direction. Returns `true` if handled.
    func adjust(direction: AdjustDirection) -> Bool
    /// Selects (activates) the setting.
    func select() -> Bool
}

extension SettingItem {
    var controllerValue: String {
        ""
    }
    func select() -> Bool {
        self.adjust(direction: .increase)
    }
}

/// A boolean toggle backed by a UserDefaults key.
struct ToggleSetting: SettingItem {
    let identifier: String
    let defaultsKey: String

    var value: String {
        UserDefaults.standard.bool(forKey: defaultsKey)
            ? NSLocalizedString("SettingGenericEnabled", comment: "Value, if a setting is enabled")
            : NSLocalizedString("SettingGenericDisabled", comment: "Value, if a setting is disabled")
    }

    func adjust(direction: AdjustDirection) -> Bool {
        let current = UserDefaults.standard.bool(forKey: defaultsKey)
        UserDefaults.standard.set(current.adjusted(by: direction), forKey: defaultsKey)
        return true
    }
}

/// An enum setting backed by a UserDefaults key, where the enum is `Adjustable` and `RawRepresentable<Int>`.
struct ChoiceSetting<T: Adjustable & CustomStringConvertible>: SettingItem where T: RawRepresentable, T.RawValue == Int {
    let identifier: String
    let defaultsKey: String

    var value: String {
        T(rawValue: UserDefaults.standard.integer(forKey: defaultsKey))?.description ?? ""
    }

    func adjust(direction: AdjustDirection) -> Bool {
        guard let current = T(rawValue: UserDefaults.standard.integer(forKey: defaultsKey)) else {
            return false
        }
        UserDefaults.standard.set(current.adjusted(by: direction).rawValue, forKey: defaultsKey)
        return true
    }
}

/// A volume setting that syncs between an audio player and UserDefaults.
struct VolumeSetting: SettingItem {
    init(identifier: String, target: VolumeSettable?, defaultsKey: String) {
        self.identifier = identifier
        self.target = target
        self.defaultsKey = defaultsKey
        self.percentFormatter.numberStyle = .percent
    }

    let identifier: String
    var target: VolumeSettable?
    let defaultsKey: String
    let percentFormatter: NumberFormatter = NumberFormatter()

    var value: String {
        self.target?.volume == 0
            ? NSLocalizedString("SettingAudioOff", comment: "Value, if music volume or fx volume is 0")
            : self.percentFormatter.string(from: NSNumber(value: Double(self.target?.volume ?? 0) / 100.0)) ?? ""
    }

    func adjust(direction: AdjustDirection) -> Bool {
        let newVolume = min(100, max(0, (self.target?.volume ?? 0) + (direction == .increase ? 2 : -2)))
        self.target?.volume = newVolume
        UserDefaults.standard.set(newVolume, forKey: self.defaultsKey)
        return true
    }

    func select() -> Bool {
        let volume = (((self.target?.volume ?? 0) / 10) * 10) + 10
        let newVolume = volume > 100 ? 0 : volume
        self.target?.volume = newVolume
        UserDefaults.standard.set(newVolume, forKey: self.defaultsKey)
        return true
    }
}

/// A display setting that syncs between a window's display mode and UserDefaults.
struct DisplaySetting: SettingItem {
    let identifier: String
    let target: NSWindow?
    let defaultsKey: String

    var value: String {
        UserDefaults.standard.bool(forKey: defaultsKey)
            ? NSLocalizedString("SettingDisplayModeFullscreen", comment: "Value, if display mode is fullscreen")
            : NSLocalizedString("SettingDisplayModeWindow", comment: "Value, if display mode is window")
    }

    func adjust(direction: AdjustDirection) -> Bool {
        let current = UserDefaults.standard.bool(forKey: self.defaultsKey)
        UserDefaults.standard.set(current.adjusted(by: direction), forKey: defaultsKey)
        self.target?.toggleFullScreen(nil)
        return true
    }

    func select() -> Bool {
        self.adjust(direction: .decrease)
    }
}

/// A keyboard binding setting that triggers rebinding on select.
struct KeyBindingSetting: SettingItem {
    let identifier: String
    let target: Input
    let inputMapper: InputMapper?
    var action: (Input, String) -> Void

    var value: String {
        self.inputMapper?.describeIdForKeyboard(target) ?? ""
    }

    var controllerValue: String {
        self.inputMapper?.describeIdForController(target) ?? ""
    }

    func adjust(direction: AdjustDirection) -> Bool {
        false
    }
    func select() -> Bool {
        self.action(target, identifier)
        return true
    }
}

/// A non-adjustable item that triggers a closure
struct ActionSetting: SettingItem {
    let identifier: String
    let action: () -> Void

    var value: String = ""

    func adjust(direction: AdjustDirection) -> Bool {
        false
    }
    func select() -> Bool {
        action()
        return true
    }
}
