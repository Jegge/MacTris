//
//  VisualOptions.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

struct VisualOptions {
    let appearance: Appearance
    let animations: Bool
}

extension VisualOptions: CustomStringConvertible {
    var description: String {
        "Appearance \(self.appearance), Animations \(self.animations)"
    }
}
