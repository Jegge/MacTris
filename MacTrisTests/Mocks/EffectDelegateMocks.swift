//
//  EffectDelegateMocks.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 20.07.26.
//

@testable import MacTris

class MockEffectDelegate: EffectDelegate {
    var playedEffects: [AudioFx] = []
    var shakeBoardCount: Int = 0
    var gameOverCount: Int = 0

    func play(fx: AudioFx) {
        self.playedEffects.append(fx)
    }

    func shakeBoard() {
        self.shakeBoardCount += 1
    }

    func gameOver() {
        self.gameOverCount += 1
    }
}
