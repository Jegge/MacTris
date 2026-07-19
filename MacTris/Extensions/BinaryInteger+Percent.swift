//
//  BinaryInteger+Percent.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

extension BinaryInteger {
    /// Returns the value as a fraction of 100, clamped to the range [0.0, 1.0].
    var asPercent: Float {
        0.01 * max(0.0, min(100.0, Float(self)))
    }
}
