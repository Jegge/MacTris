//
//  MusicPlayer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import AVFoundation

class MusicPlayer: NSObject {

    private var player: AVAudioPlayer?

    deinit {
        self.stop()
    }

    func play(mp3 name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            self.player = try? AVAudioPlayer(contentsOf: url)
            self.player?.numberOfLoops = -1
            self.player?.volume = self.calculateVolume()
            self.player?.prepareToPlay()
            self.player?.play()
        }
    }

    func stop() {
        self.player?.stop()
        self.player = nil
    }

    var volume: Int = 100 {
        didSet {
            self.player?.volume = self.calculateVolume()
        }
    }

    var muted: Bool = false {
        didSet {
            self.player?.volume = self.calculateVolume()
        }
    }

    private func calculateVolume() -> Float {
        self.muted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.volume)))
    }

    // Kept as a singleton, since it is effectively only used once
    static let shared = MusicPlayer()
}
