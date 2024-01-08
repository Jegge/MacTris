//
//  AudioPlayer.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject {

    private var musicPlayer: AVAudioPlayer?
    private var fxPlayers: [String: AVAudioPlayer] = [:]

    deinit {
        self.stopMusic()
        self.fxPlayers.removeAll()
    }

    func playMusic (mp3 name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            self.musicPlayer = try? AVAudioPlayer(contentsOf: url)
            self.musicPlayer?.numberOfLoops = -1
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
            self.musicPlayer?.prepareToPlay()
            self.musicPlayer?.play()
        }
    }

    func stopMusic () {
        self.musicPlayer?.stop()
        self.musicPlayer = nil
    }

    var musicVolume: Int = 100 {
        didSet {
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
        }
    }

    var musicMuted: Bool = false {
        didSet {
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
        }
    }

    func playFx (aiff name: String) {
        if self.fxPlayers[name] == nil,
           let url = Bundle.main.url(forResource: name, withExtension: "aiff"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            player.numberOfLoops = 0
            self.fxPlayers[name] = player
        }

        if let player = self.fxPlayers[name] {
            player.volume = self.fxMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.fxVolume)))
            player.play()
        }
    }

    var fxVolume: Int = 100

    var fxMuted: Bool = false

    static let shared = AudioPlayer()
}
