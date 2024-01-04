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
        AudioPlayer.shared.playMusic(mp3: "Korobeiniki")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        AudioPlayer.shared.stopMusic()
    }
}
