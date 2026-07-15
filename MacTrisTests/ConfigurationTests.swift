//
//  ConfigurationTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
@testable import MacTris

struct AdjustableTestHelper<T: Adjustable & CustomStringConvertible & RawRepresentable> where T.RawValue == Int {

    struct CaseSpec {
        let value: T
        let rawValue: Int
        let description: String
    }

    let specs: [CaseSpec]
    private var cases: [T] { specs.map(\.value) }

    func verifyRawValues() {
        for spec in specs {
            #expect(spec.value.rawValue == spec.rawValue)
        }
    }

    func verifyIncreaseCycle() {
        for (index, spec) in specs.enumerated() {
            let expected = cases[(index + 1) % cases.count]
            #expect(spec.value.adjusted(by: .increase) == expected, "increased() from \(spec.value) should be \(expected)")
        }
    }

    func verifyDecreaseCycle() {
        for (index, spec) in specs.enumerated() {
            let expected = cases[(index - 1 + cases.count) % cases.count]
            #expect(spec.value.adjusted(by: .decrease) == expected, "decreased() from \(spec.value) should be \(expected)")
        }
    }

    func verifyRoundtrip() {
        for spec in specs {
            #expect(spec.value.adjusted(by: .increase).adjusted(by: .decrease) == spec.value)
            #expect(spec.value.adjusted(by: .decrease).adjusted(by: .increase) == spec.value)
        }
    }

    func verifyDescriptions() {
        for spec in specs {
            #expect(spec.value.description == spec.description)
        }
    }

    func verifyAll() {
        verifyRawValues()
        verifyIncreaseCycle()
        verifyDecreaseCycle()
        verifyRoundtrip()
        verifyDescriptions()
    }
}

struct AdjustableTests {
    @Test func testBoolToggles()  async throws {
        #expect(true.increased() == false)
        #expect(true.decreased() == false)
        #expect(false.increased() == true)
        #expect(false.decreased() == true)
    }
}

struct RandomGeneratorModeTests {

    private let helper = AdjustableTestHelper<RandomGeneratorMode>(specs: [
        .init(value: .nes, rawValue: 1, description: "Classic (NES)"),
        .init(value: .sevenBag, rawValue: 2, description: "Modern (7-Bag)")
    ])

    @Test func testRawValues()     async throws { helper.verifyRawValues() }
    @Test func testIncreaseCycle() async throws { helper.verifyIncreaseCycle() }
    @Test func testDecreaseCycle() async throws { helper.verifyDecreaseCycle() }
    @Test func testRoundtrip()     async throws { helper.verifyRoundtrip() }
    @Test func testDescriptions()  async throws { helper.verifyDescriptions() }

    @Test func testCreateNesGenerator() async throws {
        let gen = RandomGeneratorMode.nes.createGenerator()
        #expect(gen is NesTetrominoShapeGenerator)
    }

    @Test func testCreateSevenBagGenerator() async throws {
        let gen = RandomGeneratorMode.sevenBag.createGenerator()
        #expect(gen is SevenBagTetrominoShapeGenerator)
    }
}

struct AppearanceTests {

    private let helper = AdjustableTestHelper<Appearance>(specs: [
        .init(value: .plain, rawValue: 1, description: "Plain"),
        .init(value: .shaded, rawValue: 2, description: "Shaded"),
        .init(value: .bright, rawValue: 3, description: "Bright")
    ])

    @Test func testRawValues()     async throws { helper.verifyRawValues() }
    @Test func testIncreaseCycle() async throws { helper.verifyIncreaseCycle() }
    @Test func testDecreaseCycle() async throws { helper.verifyDecreaseCycle() }
    @Test func testRoundtrip()     async throws { helper.verifyRoundtrip() }
    @Test func testDescriptions()  async throws { helper.verifyDescriptions() }
}

struct AutoShiftTests {

    private let helper = AdjustableTestHelper<AutoShift>(specs: [
        .init(value: .nes, rawValue: 1, description: "Classic (16\u{2013}6)"),
        .init(value: .modern, rawValue: 2, description: "Modern (8\u{2013}6)"),
        .init(value: .fast, rawValue: 3, description: "Fast (6\u{2013}3)"),
        .init(value: .insane, rawValue: 4, description: "Insane (5\u{2013}1)")
    ])

    @Test func testRawValues()     async throws { helper.verifyRawValues() }
    @Test func testIncreaseCycle() async throws { helper.verifyIncreaseCycle() }
    @Test func testDecreaseCycle() async throws { helper.verifyDecreaseCycle() }
    @Test func testRoundtrip()     async throws { helper.verifyRoundtrip() }
    @Test func testDescriptions()  async throws { helper.verifyDescriptions() }

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
}
