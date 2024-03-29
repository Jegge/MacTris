//
//  AudioPlayer+Fx.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

extension AudioPlayer {
    static func playFxPositive () {
        AudioPlayer.shared.playFx(aiff: "Positive")
    }

    static func playFxNegative () {
        AudioPlayer.shared.playFx(aiff: "Negative")
    }

    static func playFxSelect () {
        AudioPlayer.shared.playFx(aiff: "Select")
    }

    static func playFxSuccess () {
        AudioPlayer.shared.playFx(aiff: "Success")
    }

    static func playFxQuadSuccess () {
        AudioPlayer.shared.playFx(aiff: "QuadSuccess")
    }

    static func playFxGameOver () {
        AudioPlayer.shared.playFx(aiff: "GameOver")
    }

    static func playFxShift () {
        AudioPlayer.shared.playFx(aiff: "Shift")
    }

    static func playFxRotate () {
        AudioPlayer.shared.playFx(aiff: "Rotate")
    }

    static func playFxLock () {
        AudioPlayer.shared.playFx(aiff: "Lock")
    }
}
