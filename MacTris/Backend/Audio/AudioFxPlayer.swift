//
//  AudioFxPlayer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import AVFoundation

/// Sound effect identifiers.
enum AudioFx {
    case positive, negative, select, success, quadSuccess, gameOver, shift, rotate, lock
}

/// Plays short sound effects from `.aiff` files bundled with the app.
class AudioFxPlayer: NSObject, VolumeSettable {
    private var players: Set<AVAudioPlayer> = Set()

    init(volume: Int) {
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
            player.volume = self.volume.asPercent
            player.delegate = self
            self.players.insert(player)
            player.play()
        }
    }
}

extension AudioFxPlayer {
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
