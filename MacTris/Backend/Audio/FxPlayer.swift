//
//  AudioPlayer.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import AVFoundation

class FxPlayer: NSObject {
    private var players: Set<AVAudioPlayer> = Set()

    init (volume: Int) {
        self.volume = volume
    }

    var volume: Int = 100
    var muted: Bool = false

    deinit {
        self.players.removeAll()
    }

    func play(aiff name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "aiff"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            player.numberOfLoops = 0
            player.volume = self.muted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.volume)))
            player.delegate = self
            self.players.insert(player)
            player.play()
        }
    }
}

extension FxPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.players.remove(player)
    }
}

extension FxPlayer {
    func playPositive() {
        self.play(aiff: "Positive")
    }

    func playNegative() {
        self.play(aiff: "Negative")
    }

    func playSelect() {
        self.play(aiff: "Select")
    }

    func playSuccess() {
        self.play(aiff: "Success")
    }

    func playQuadSuccess() {
        self.play(aiff: "QuadSuccess")
    }

    func playGameOver() {
        self.play(aiff: "GameOver")
    }

    func playShift() {
        self.play(aiff: "Shift")
    }

    func playRotate() {
        self.play(aiff: "Rotate")
    }

    func playLock() {
        self.play(aiff: "Lock")
    }
}
