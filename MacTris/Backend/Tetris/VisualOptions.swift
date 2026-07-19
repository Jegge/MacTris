//
//  VisualOptions.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

/// Visual presentation options for the game scene.
struct VisualOptions {
    /// The tile appearance style (plain, shaded, bright).
    let appearance: Appearance
    /// Whether label text changes are animated with a bounce effect.
    let animations: Bool
}

extension VisualOptions: CustomStringConvertible {
    var description: String {
        "Appearance \(self.appearance), Animations \(self.animations)"
    }
}
