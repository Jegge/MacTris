//
//  FrameRateStabilizer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 14.07.26.
//

import Foundation

struct FrameRateStabilizer {
    private var lastUpdate: TimeInterval = 0
    private var accumulator: TimeInterval = 0

    init(desiredFps fps: Int) {
        self.desiredFps = fps
        self.frameTime = 1.0 / TimeInterval(fps)
    }

    let desiredFps: Int
    let frameTime: TimeInterval

    mutating func update(_ currentTime: TimeInterval, stableUpdate: (TimeInterval) -> Void) {
        let delta = self.lastUpdate > 0 ? currentTime - self.lastUpdate : 0
        self.lastUpdate = currentTime
        self.accumulator = min(self.accumulator + delta, self.frameTime * 5) // cap at 5 frames

        while self.accumulator >= self.frameTime {
            stableUpdate(self.frameTime)
            self.accumulator -= self.frameTime
        }
    }
}
