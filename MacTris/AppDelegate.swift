//
//  AppDelegate.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Cocoa
import AVFoundation

@main class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register()

//        InputBindings.moveLeft = UserDefaults.standard.keyMoveLeft
//        InputBindings.moveRight = UserDefaults.standard.keyMoveRight
//        InputBindings.rotateLeft = UserDefaults.standard.keyRotateLeft
//        InputBindings.rotateRight = UserDefaults.standard.keyRotateRight
//        InputBindings.softDrop = UserDefaults.standard.keySoftDrop

        AudioPlayer.shared.fxVolume = UserDefaults.standard.fxVolume
        AudioPlayer.shared.musicVolume = UserDefaults.standard.musicVolume
        AudioPlayer.shared.playMusic(mp3: "Korobeiniki")

        // try? Hiscore().write(to: Hiscore.url)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        AudioPlayer.shared.stopMusic()
    }
}
