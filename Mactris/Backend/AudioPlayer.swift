//
//  AudioPlayer.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation
import AVFoundation

public class AudioPlayer: NSObject {

    private var musicPlayer: AVAudioPlayer?
    private var fxPlayers: Set<AVAudioPlayer> = Set()

    deinit {
        self.stopMusic()
        self.fxPlayers.removeAll()
    }

    public func playMusic (mp3 name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            self.musicPlayer = try? AVAudioPlayer(contentsOf: url)
            self.musicPlayer?.numberOfLoops = -1
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
            self.musicPlayer?.prepareToPlay()
            self.musicPlayer?.play()
        }
    }

    public func stopMusic () {
        self.musicPlayer?.stop()
        self.musicPlayer = nil
    }

    public var musicVolume: Int = 100 {
        didSet {
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
        }
    }

    public var musicMuted: Bool = false {
        didSet {
            self.musicPlayer?.volume = self.musicMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.musicVolume)))
        }
    }

    public func playFx (aiff name: String) {

        if let url = Bundle.main.url(forResource: name, withExtension: "aiff"),
           let player = try? AVAudioPlayer(contentsOf: url) {

            player.numberOfLoops = 0
            player.volume = self.fxMuted ? 0.0 : 0.01 * max(0.0, min(100.0, Float(self.fxVolume)))
            player.prepareToPlay()
            player.delegate = self
            self.fxPlayers.insert(player)
            player.play()
        }
    }

    public var fxVolume: Int = 100

    public var fxMuted: Bool = false

    public static let shared = AudioPlayer()
}

extension AudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.fxPlayers.remove(player)
    }
}
