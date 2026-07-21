//
//  FrameRateStabilizerTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 17.07.26.
//

import Foundation
import Testing
@testable import MacTris

struct FrameRateStabilizerTests {
    @Test func testDesiredFpsAndFrameTime() async throws {
        let s30 = FrameRateStabilizer(desiredFps: 30)
        #expect(s30.desiredFps == 30)
        #expect(s30.frameTime == 1.0 / 30.0)

        let s120 = FrameRateStabilizer(desiredFps: 120)
        #expect(s120.desiredFps == 120)
        #expect(s120.frameTime == 1.0 / 120.0)
    }

    @Test func testFirstUpdateProducesNoCallback() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 60)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        #expect(callCount == 0)
    }

    @Test func testMultipleFramesTriggerCorrectCallbacks() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 2)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        stabilizer.update(2.5) { _ in callCount += 1 }
        #expect(callCount == 3)
    }

    @Test func testAccumulatorCappedAtFiveFrames() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 2)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        stabilizer.update(11.0) { _ in callCount += 1 }
        #expect(callCount == 5)
    }

    @Test func testCallbackReceivesFrameTime() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 2)
        var receivedTimes: [TimeInterval] = []
        stabilizer.update(1.0) { _ in }
        stabilizer.update(2.0) { time in receivedTimes.append(time) }
        #expect(receivedTimes.count == 2)
        for time in receivedTimes {
            #expect(time == 0.5)
        }
    }

    @Test func testNoCallbackWhenDeltaTooSmall() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 60)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        stabilizer.update(1.0 + 0.5 / 60.0) { _ in callCount += 1 }
        #expect(callCount == 0)
    }

    @Test func testPartialFrameTimeCarriesOver() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 2)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        stabilizer.update(1.75) { _ in callCount += 1 }
        #expect(callCount == 1)
        stabilizer.update(2.1) { _ in callCount += 1 }
        #expect(callCount == 2)
    }

    @Test func testResetDiscardsElapsedAndPartialFrameTime() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 2)
        var callCount = 0
        stabilizer.update(1.0) { _ in callCount += 1 }
        stabilizer.update(1.75) { _ in callCount += 1 }
        #expect(callCount == 1)

        stabilizer.reset()
        stabilizer.update(10.0) { _ in callCount += 1 }
        #expect(callCount == 1)
        stabilizer.update(10.5) { _ in callCount += 1 }
        #expect(callCount == 2)
    }

    @Test func testNegativeDeltaTimeHandledGracefully() async throws {
        var stabilizer = FrameRateStabilizer(desiredFps: 60)
        var callCount = 0
        stabilizer.update(5.0) { _ in callCount += 1 }
        stabilizer.update(4.0) { _ in callCount += 1 }
        #expect(callCount == 0)
    }
}
