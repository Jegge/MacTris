//
//  ConfigurationTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
@testable import MacTris

struct RandomGeneratorModeTests {

    @Test func testRawValues() async throws {
        #expect(RandomGeneratorMode.nes.rawValue == 1)
        #expect(RandomGeneratorMode.sevenBag.rawValue == 2)
    }

    @Test func testIncreaseNes() async throws {
        #expect(RandomGeneratorMode.nes.increase() == .sevenBag)
    }

    @Test func testIncreaseSevenBagWrapsToNes() async throws {
        #expect(RandomGeneratorMode.sevenBag.increase() == .nes)
    }

    @Test func testDecreaseSevenBag() async throws {
        #expect(RandomGeneratorMode.sevenBag.decrease() == .nes)
    }

    @Test func testDecreaseNesWrapsToSevenBag() async throws {
        #expect(RandomGeneratorMode.nes.decrease() == .sevenBag)
    }

    @Test func testCycleRoundtrip() async throws {
        #expect(RandomGeneratorMode.nes.increase().decrease() == .nes)
        #expect(RandomGeneratorMode.sevenBag.decrease().increase() == .sevenBag)
    }

    @Test func testCreateNesGenerator() async throws {
        let gen = RandomGeneratorMode.nes.createGenerator()
        #expect(gen is NesTetrominoShapeGenerator)
    }

    @Test func testCreateSevenBagGenerator() async throws {
        let gen = RandomGeneratorMode.sevenBag.createGenerator()
        #expect(gen is SevenBagTetrominoShapeGenerator)
    }

    @Test func testDescriptionNes() async throws {
        #expect(RandomGeneratorMode.nes.description == "Classic (NES)")
    }

    @Test func testDescriptionSevenBag() async throws {
        #expect(RandomGeneratorMode.sevenBag.description == "Modern (7-Bag)")
    }
}

struct AppearanceTests {

    @Test func testRawValues() async throws {
        #expect(Appearance.plain.rawValue == 1)
        #expect(Appearance.shaded.rawValue == 2)
        #expect(Appearance.bright.rawValue == 3)
    }

    @Test func testIncreasePlain() async throws {
        #expect(Appearance.plain.increase() == .shaded)
    }

    @Test func testIncreaseShaded() async throws {
        #expect(Appearance.shaded.increase() == .bright)
    }

    @Test func testIncreaseBrightWrapsToPlain() async throws {
        #expect(Appearance.bright.increase() == .plain)
    }

    @Test func testDecreaseBright() async throws {
        #expect(Appearance.bright.decrease() == .shaded)
    }

    @Test func testDecreaseShaded() async throws {
        #expect(Appearance.shaded.decrease() == .plain)
    }

    @Test func testDecreasePlainWrapsToBright() async throws {
        #expect(Appearance.plain.decrease() == .bright)
    }

    @Test func testCycleRoundtrip() async throws {
        for appearance in [Appearance.plain, .shaded, .bright] {
            #expect(appearance.increase().decrease() == appearance)
            #expect(appearance.decrease().increase() == appearance)
        }
    }

    @Test func testDescriptionPlain() async throws {
        #expect(Appearance.plain.description == "Plain")
    }

    @Test func testDescriptionShaded() async throws {
        #expect(Appearance.shaded.description == "Shaded")
    }

    @Test func testDescriptionBright() async throws {
        #expect(Appearance.bright.description == "Bright")
    }
}

struct AutoShiftTests {

    @Test func testRawValues() async throws {
        #expect(AutoShift.nes.rawValue == 1)
        #expect(AutoShift.modern.rawValue == 2)
        #expect(AutoShift.fast.rawValue == 3)
        #expect(AutoShift.insane.rawValue == 4)
    }

    @Test func testIncreaseNesToModern() async throws {
        #expect(AutoShift.nes.increase() == .modern)
    }

    @Test func testIncreaseModernToFast() async throws {
        #expect(AutoShift.modern.increase() == .fast)
    }

    @Test func testIncreaseFastToInsane() async throws {
        #expect(AutoShift.fast.increase() == .insane)
    }

    @Test func testIncreaseInsaneWrapsToNes() async throws {
        #expect(AutoShift.insane.increase() == .nes)
    }

    @Test func testDecreaseInsaneToFast() async throws {
        #expect(AutoShift.insane.decrease() == .fast)
    }

    @Test func testDecreaseFastToModern() async throws {
        #expect(AutoShift.fast.decrease() == .modern)
    }

    @Test func testDecreaseModernToNes() async throws {
        #expect(AutoShift.modern.decrease() == .nes)
    }

    @Test func testDecreaseNesWrapsToInsane() async throws {
        #expect(AutoShift.nes.decrease() == .insane)
    }

    @Test func testCycleRoundtrip() async throws {
        for shift in [AutoShift.nes, .modern, .fast, .insane] {
            #expect(shift.increase().decrease() == shift)
            #expect(shift.decrease().increase() == shift)
        }
    }

    @Test func testDelaysNes() async throws {
        let delays = AutoShift.nes.delays
        #expect(delays.initial == 16)
        #expect(delays.repeating == 6)
    }

    @Test func testDelaysModern() async throws {
        let delays = AutoShift.modern.delays
        #expect(delays.initial == 8)
        #expect(delays.repeating == 6)
    }

    @Test func testDelaysFast() async throws {
        let delays = AutoShift.fast.delays
        #expect(delays.initial == 6)
        #expect(delays.repeating == 3)
    }

    @Test func testDelaysInsane() async throws {
        let delays = AutoShift.insane.delays
        #expect(delays.initial == 5)
        #expect(delays.repeating == 1)
    }

    @Test func testDelaysDecreaseOverTime() async throws {
        let nes = AutoShift.nes.delays
        let modern = AutoShift.modern.delays
        let fast = AutoShift.fast.delays
        let insane = AutoShift.insane.delays
        #expect(nes.initial > modern.initial)
        #expect(modern.initial > fast.initial)
        #expect(fast.initial > insane.initial)
        #expect(fast.repeating >= insane.repeating)
    }

    @Test func testDescriptionNes() async throws {
        #expect(AutoShift.nes.description == "Classic (16\u{2013}6)")
    }

    @Test func testDescriptionModern() async throws {
        #expect(AutoShift.modern.description == "Modern (8\u{2013}6)")
    }

    @Test func testDescriptionFast() async throws {
        #expect(AutoShift.fast.description == "Fast (6\u{2013}3)")
    }

    @Test func testDescriptionInsane() async throws {
        #expect(AutoShift.insane.description == "Insane (5\u{2013}1)")
    }
}

struct TetrisOptionsTests {

    @Test func testDescriptionContainsLevel() async throws {
        let options = TetrisOptions(startingLevel: 5, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: true, hardDrop: false)
        #expect(options.description.contains("5"))
    }

    @Test func testDescriptionContainsWallKickWhenEnabled() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: true, hardDrop: false)
        #expect(options.description.contains("Wall kick"))
    }

    @Test func testDescriptionExcludesWallKickWhenDisabled() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: false, hardDrop: false)
        #expect(!options.description.contains("Wall kick"))
    }

    @Test func testDescriptionContainsHardDropWhenEnabled() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: false, hardDrop: true)
        #expect(options.description.contains("Hard drop"))
    }

    @Test func testDescriptionExcludesHardDropWhenDisabled() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: false, hardDrop: false)
        #expect(!options.description.contains("Hard drop"))
    }

    @Test func testDescriptionContainsRngMode() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .nes, randomGeneratorMode: .sevenBag,
                                     wallKick: false, hardDrop: false)
        #expect(options.description.contains("7-Bag"))
    }

    @Test func testDescriptionContainsAutoShift() async throws {
        let options = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true,
                                     autoShift: .fast, randomGeneratorMode: .nes,
                                     wallKick: false, hardDrop: false)
        #expect(options.description.contains("Fast"))
    }
}
