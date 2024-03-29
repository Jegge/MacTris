//
//  OsLog+Categories.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 05.01.24.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let game = Logger(subsystem: subsystem, category: "game")
    static let input = Logger(subsystem: subsystem, category: "input")
    static let hiscore = Logger(subsystem: subsystem, category: "hiscore")
}
