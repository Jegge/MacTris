//
//  GameSettingsTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 21.07.26.
//

import Foundation
import Testing
@testable import MacTris

struct GameSettingsTests {
    @Test func testDefaults() async throws {
        let suiteName = UUID().uuidString
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return
        }
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let settings = GameSettings(userDefaults: userDefaults)

        #expect(settings.musicVolume == 100)
        #expect(settings.fxVolume == 100)
        #expect(settings.startLevel == 0)
        #expect(settings.randomGeneratorMode == .sevenBag)
        #expect(settings.appearance == .plain)
        #expect(settings.autoShift == .modern)
        #expect(!settings.fullscreen)
        #expect(!settings.wallKick)
        #expect(!settings.hardDrop)
        #expect(settings.animations)
    }

    @Test func testNumericValuesAreClamped() async throws {
        let suiteName = UUID().uuidString
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return
        }
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let settings = GameSettings(userDefaults: userDefaults)
        settings.musicVolume = -1
        settings.fxVolume = 101
        settings.startLevel = Tetris.maxStartingLevel + 1

        #expect(settings.musicVolume == 0)
        #expect(settings.fxVolume == 100)
        #expect(settings.startLevel == Tetris.maxStartingLevel)
    }

    @Test func testInvalidPersistedChoicesUseDefaults() async throws {
        let suiteName = UUID().uuidString
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return
        }
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        userDefaults.set(0, forKey: "RandomGeneratorMode")
        userDefaults.set(0, forKey: "Appearance")
        userDefaults.set(0, forKey: "AutoShift")
        let settings = GameSettings(userDefaults: userDefaults)

        #expect(settings.randomGeneratorMode == .sevenBag)
        #expect(settings.appearance == .plain)
        #expect(settings.autoShift == .modern)
    }

    @Test func testKeyboardBindingsArePersisted() async throws {
        let suiteName = UUID().uuidString
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return
        }
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let settings = GameSettings(userDefaults: userDefaults)
        settings.keyboardBindings = [
            InputMapper.KeyBinding(keyCode: KeyCode.escape.rawValue, id: .hardDrop),
            InputMapper.KeyBinding(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        ]

        #expect(settings.keyboardBindings.count == 2)
        #expect(settings.keyboardBindings[0].keyCode == KeyCode.escape.rawValue)
        #expect(settings.keyboardBindings[0].id == .hardDrop)
        #expect(settings.keyboardBindings[1].keyCode == KeyCode.z.rawValue)
        #expect(settings.keyboardBindings[1].id == .hardDrop)
    }
}
