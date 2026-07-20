//
//  MusicPlayer.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import AVFoundation

/// Plays a looping music track from an `.mp3` file bundled with the app.
class MusicPlayer: NSObject, VolumeSettable {

    private var player: AVAudioPlayer?

    init(volume: Int) {
        self.volume = volume
    }

    deinit {
        self.stop()
    }

    /// Starts playing the given MP3 file in a loop.
    func play(mp3 name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            self.player = try? AVAudioPlayer(contentsOf: url)
            self.player?.numberOfLoops = -1
            self.player?.volume = self.volume.asPercent
            self.player?.prepareToPlay()
            self.player?.play()
        }
    }

    /// Stops playback and releases the audio player.
    func stop() {
        self.player?.stop()
        self.player = nil
    }

    /// The playback volume (0–100). Updating this adjusts the player in real time.
    var volume: Int = 100 {
        didSet {
            self.player?.volume = self.volume.asPercent
        }
    }
}
