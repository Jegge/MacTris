//
//  FxPlayer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import AVFoundation

enum AudioFx {
    case positive, negative, select, success, quadSuccess, gameOver, shift, rotate, lock
}

/// Play a given fx
protocol PlayAudio {
    /// Play the given fx
    func play(_ audioFx: AudioFx)
}

class AudioFxPlayer: NSObject {
    private var players: Set<AVAudioPlayer> = Set()

    init (volume: Int) {
        self.volume = volume
    }

    var volume: Int = 100

    deinit {
        self.players.removeAll()
    }

    func play(aiff name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "aiff"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            player.numberOfLoops = 0
            player.volume = 0.01 * max(0.0, min(100.0, Float(self.volume)))
            player.delegate = self
            self.players.insert(player)
            player.play()
        }
    }
}

extension AudioFxPlayer: PlayAudio {
    func play(_ audioFx: AudioFx) {
        switch audioFx {
        case .positive:
            self.play(aiff: "Positive")
        case .negative:
            self.play(aiff: "Negative")
        case .select:
            self.play(aiff: "Select")
        case .success:
            self.play(aiff: "Success")
        case .quadSuccess:
            self.play(aiff: "QuadSuccess")
        case .gameOver:
            self.play(aiff: "GameOver")
        case .shift:
            self.play(aiff: "Shift")
        case .rotate:
            self.play(aiff: "Rotate")
        case .lock:
            self.play(aiff: "Lock")
        }
    }
}

extension AudioFxPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.players.remove(player)
    }
}
