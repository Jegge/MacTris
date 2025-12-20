//
//  Statistics.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

struct Statistics {
    private var counts: [Tetromino.Shape: Int] = [:]

    mutating func count(_ shape: Tetromino.Shape) {
        self.counts[shape] = (self.counts[shape] ?? 0) + 1
    }
}

extension Statistics: CustomStringConvertible {
    var description: String {
        let total = self.counts.reduce(0) { (result, entry) in return result + entry.value }
        return Tetromino.Shape.allCases
            .map {
                let count = self.counts[$0] ?? 0
                let percent = (Double(count) / Double(total)) * 100.0
                return String(format: "%@ %.02f%% (%d/%d)", String(describing: $0).uppercased(), percent, count, total)
            }
            .joined(separator: ", ")
    }
}
