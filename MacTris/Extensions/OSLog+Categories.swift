//
//  OSLog+Categories.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 05.01.24.
//

import OSLog

/// Pre-configured loggers for each subsystem category.
extension Logger {
    // swiftlint:disable:next force_unwrapping
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logger for game engine events (scoring, level changes, line clears).
    static let game = Logger(subsystem: subsystem, category: "game")
    /// Logger for keyboard and controller input events.
    static let input = Logger(subsystem: subsystem, category: "input")
    /// Logger for high score storage and retrieval.
    static let hiscore = Logger(subsystem: subsystem, category: "hiscore")
    /// Logger for app update checks and version comparisons.
    static let update = Logger(subsystem: subsystem, category: "update")
}
