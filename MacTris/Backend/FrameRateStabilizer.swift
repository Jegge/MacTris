//
//  FrameRateStabilizer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 14.07.26.
//

import Foundation

/// Ensures a fixed-timestep update loop regardless of actual frame rate.
/// Accumulates the elapsed time since the last frame and invokes the update
/// callback at a consistent interval (the desired FPS).
struct FrameRateStabilizer {
    private var lastUpdate: TimeInterval = 0
    private var accumulator: TimeInterval = 0

    init(desiredFps fps: Int) {
        self.desiredFps = fps
        self.frameTime = 1.0 / TimeInterval(fps)
    }

    /// The target frame rate.
    let desiredFps: Int
    /// The duration of a single frame at the target FPS.
    let frameTime: TimeInterval

    /// Call this each display frame with the current time. The `stableUpdate`
    /// closure is called at the configured frame rate, potentially multiple
    /// times per display frame if the real FPS is lower than desired.
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
