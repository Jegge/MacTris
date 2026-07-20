//
//  Hiscore.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import CryptoKit
import OSLog

/// Manages loading, saving, inserting, and querying high scores.
/// Scores are stored in an encrypted JSON file using AES-GCM.
class Hiscore {

    #if DEBUG
    static let filename = "hiscores.debug.json"
    #else
    static let filename = "hiscores.json"
    #endif

    /// A single high-score entry with a player name and score value.
    struct Score: Codable, Comparable, Equatable {
        let name: String
        let value: Int

        static func < (lhs: Hiscore.Score, rhs: Hiscore.Score) -> Bool {
            return lhs.value < rhs.value
        }
    }

    /// The file URL where the encrypted high scores are stored.
    static var url: URL {
        if #available(macOS 13.0, *) {
            return URL.applicationSupportDirectory.appendingPathComponent(Hiscore.filename, isDirectory: false)
        } else {
            do {
                let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                return directory.appendingPathComponent(Hiscore.filename, isDirectory: false)
            } catch {
                Logger.hiscore.error("Failed to open application support directory: \(error, privacy: .public)")
                return URL(fileURLWithPath: Hiscore.filename, isDirectory: false)
            }
        }
    }

    static let nameLength: Int = 16
    static let numberOfEntries: Int = 10

    private var list: [Score]
    private var key: SymmetricKey

    var scores: [Score] {
        return self.list
    }

    private init(list: [Score], key: SymmetricKey) {
        self.list = list
        self.key = key
    }

    /// Loads and decrypts high scores from an encrypted JSON file.
    convenience init(contentsOfUrl url: URL, key: String) throws {
        // swiftlint:disable:next force_unwrapping
        let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
        let encrypted = try AES.GCM.SealedBox(combined: try Data(contentsOf: url))
        let decrypted = try AES.GCM.open(encrypted, using: symmetricKey)
        let scores = try JSONDecoder().decode([Score].self, from: decrypted)
        self.init(list: scores, key: symmetricKey)
    }

    /// Creates a default high-score list with prefilled entries.
    convenience init(key: String) {
        // swiftlint:disable:next force_unwrapping
        let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
        self.init(list: [
            Score(name: "Johnnie", value: 100000),
            Score(name: "Jacky", value: 90000),
            Score(name: "Jim", value: 80000),
            Score(name: "Petra", value: 70000),
            Score(name: "Sebastian", value: 60000),
            Score(name: "Mirjam", value: 50000),
            Score(name: "Rebekka", value: 40000),
            Score(name: "Elia", value: 30000),
            Score(name: "Hinz", value: 20000),
            Score(name: "Kunz", value: 10000)
        ], key: symmetricKey)
    }

    /// Encrypts and writes the high-score list to a file. Creates the Application Support directory if needed.
    func write(to url: URL) throws {
        let decrypted = try JSONEncoder().encode(self.list)
        guard let encrypted = try AES.GCM.seal(decrypted, using: self.key).combined else {
            throw CocoaError(.fileWriteUnknown)
        }

        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encrypted.write(to: url, options: .atomic)
    }

    /// Inserts a score into the list and returns its rank index (or `nil` if not in top 10).
    func insert(score: Score) -> Int? {
        let index = self.insertionIndex(for: score)
        guard index < Hiscore.numberOfEntries else {
            return nil
        }

        self.list.insert(score, at: index)
        if self.list.count > Hiscore.numberOfEntries {
            self.list.removeLast()
        }

        return index
    }

    /// Renames the entry at the given index (truncated to `nameLength` characters).
    func rename(at index: Int, to name: String) {
        if index >= 0 && index < self.list.count {
            self.list[index] = Score(name: String(name.prefix(Hiscore.nameLength)), value: self.list[index].value)
        }
    }

    /// Returns the player name at the given index.
    func name(at index: Int) -> String {
        return index >= 0 && index < self.list.count ? self.list[index].name : ""
    }

    /// Returns `true` if the score would make it into the top 10.
    func isHighscore(score: Score) -> Bool {
        return self.insertionIndex(for: score) < Hiscore.numberOfEntries
    }

    /// Returns the insertion index for a score. New equal scores rank ahead of existing equal scores.
    private func insertionIndex(for score: Score) -> Int {
        self.list.firstIndex { $0.value <= score.value } ?? self.list.endIndex
    }
}
