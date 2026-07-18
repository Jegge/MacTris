//
//  BinaryInteger+Percent.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

extension BinaryInteger {
    var asPercent: Float {
        0.01 * max(0.0, min(100.0, Float(self)))
    }
}
