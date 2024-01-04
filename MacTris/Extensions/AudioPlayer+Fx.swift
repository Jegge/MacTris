//
//  AudioPlayer+Fx.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

extension AudioPlayer {
    public static func playFxPositive () {
        AudioPlayer.shared.playFx(aiff: "Positive")
    }

    public static func playFxNegative () {
        AudioPlayer.shared.playFx(aiff: "Negative")
    }

    public static func playFxSelect () {
        AudioPlayer.shared.playFx(aiff: "Select")
    }

    public static func playFxSuccess () {
        AudioPlayer.shared.playFx(aiff: "Success")
    }

    public static func playFxQuadSuccess () {
        AudioPlayer.shared.playFx(aiff: "QuadSuccess")
    }

    public static func playFxGameOver () {
        AudioPlayer.shared.playFx(aiff: "GameOver")
    }

    public static func playFxTranslation () {
        AudioPlayer.shared.playFx(aiff: "Movement")
    }

    public static func playFxRotation () {
        AudioPlayer.shared.playFx(aiff: "Movement")
    }
}
