//
//  Hiscore.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import CryptoKit

class Hiscore {

    public struct Score: Codable, Comparable, Equatable {
        let name: String
        let value: Int

        public static func < (lhs: Hiscore.Score, rhs: Hiscore.Score) -> Bool {
            return lhs.value < rhs.value
        }
    }

    static var url: URL {
        let id = Bundle.main.bundleIdentifier ?? "com.realvirtuality.MacTris"
        if #available(macOS 13.0, *) {
            return URL.applicationSupportDirectory.appendingPathComponent("\(id)/hiscores.json")
        } else if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
               return directory.appendingPathComponent("\(id)/hiscores.json")
        } else {
            return URL(fileURLWithPath: "~/Library/Application Support", isDirectory: true).appendingPathComponent("\(id)/hiscores.json")
        }
    }

    static var nameLength: Int = 16

    private var list: [Score]
    private var key: SymmetricKey

    public var scores: [Score] {
        return self.list
    }

    private init (list: [Score], key: SymmetricKey) {
        self.list = list
        self.key = key
    }

    convenience init (contentsOfUrl url: URL, key: String) throws {
        let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
        let encrypted = try AES.GCM.SealedBox(combined: try Data(contentsOf: url))
        let decrypted = try AES.GCM.open(encrypted, using: symmetricKey)
        let scores = try JSONDecoder().decode([Score].self, from: decrypted)
        self.init(list: scores, key: symmetricKey)
    }

    convenience init (key: String) {
        self.init(list: [
            Score(name: "Johnnie", value: 100000),
            Score(name: "Jacky", value: 90000),
            Score(name: "Jim", value: 80000),
            Score(name: "Petra", value: 70000),
            Score(name: "Mirjam", value: 60000),
            Score(name: "Rebekka", value: 50000),
            Score(name: "Elia", value: 40000),
            Score(name: "Hinz", value: 30000),
            Score(name: "Und", value: 20000),
            Score(name: "Kunz", value: 10000)
        ], key: SymmetricKey(data: key.data(using: .utf8)!))
    }

    func write (to url: URL) throws {
        let decrypted = try JSONEncoder().encode(self.list)
        let encrypted = try AES.GCM.seal(decrypted, using: self.key).combined
        try encrypted?.write(to: url)
    }

    func insert (score: Score) -> Int? {
        self.list = Array((self.list + [score]) .sorted().reversed().prefix(10))
        return self.list.firstIndex(of: score)
    }

    func rename (at index: Int, to name: String) {
        self.list[index] = Score(name: String(name.prefix(Hiscore.nameLength)), value: self.list[index].value)
    }

    func name (at index: Int) -> String {
        return self.list[index].name
    }

    func isHighscore (score: Score) -> Bool {
        return score.value > (self.list.map { $0.value }.min() ?? 0)
    }
}
