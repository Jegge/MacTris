//
//  VolumeSettable.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.07.26.
//

/// Supports changing the volume.
protocol VolumeSettable: AnyObject {
    var volume: Int { get set }
}
