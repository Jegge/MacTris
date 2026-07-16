//
//  Adjustable.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

enum AdjustDirection {
    case increase
    case decrease
}

/// Something that be increased of decreased
protocol Adjustable {
    /// Returns an increased version of itself
    func increased() -> Self
    /// Returns a decreased version of itself
    func decreased() -> Self
    /// Returns an increased of decreased version of itself, depending on the direction
    func adjusted(by direction: AdjustDirection) -> Self
}

extension Adjustable {
    func adjusted(by direction: AdjustDirection) -> Self {
        switch direction {
        case .increase: return self.increased()
        case .decrease: return self.decreased()
        }
    }
}

extension Adjustable where Self: RawRepresentable, RawValue == Int {
    func increased() -> Self {
        Self(rawValue: self.rawValue + 1) ?? self.findLimit(direction: -1)
    }

    func decreased() -> Self {
        Self(rawValue: self.rawValue - 1) ?? self.findLimit(direction: 1)
    }

    private func findLimit(direction: Int) -> Self {
        var raw = self.rawValue
        while Self(rawValue: raw + direction) != nil {
            raw += direction
        }
        // swiftlint:disable:next force_unwrapping
        return Self(rawValue: raw)!
    }
}

extension Bool: Adjustable {
    func increased() -> Bool {
        !self
    }
    func decreased() -> Bool {
        !self
    }
}
