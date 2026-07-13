//
//  AppDelegate.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register()
        MusicPlayer.shared.volume = UserDefaults.standard.musicVolume
        MusicPlayer.shared.play(mp3: "Korobeiniki")
    }

    func applicationWillTerminate(_ notification: Notification) {
        MusicPlayer.shared.stop()
    }
}
