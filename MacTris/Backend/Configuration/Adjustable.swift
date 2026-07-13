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

protocol Adjustable {
    func increased() -> Self
    func decreased() -> Self
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

extension Bool: Adjustable {
    func increased() -> Bool {
        !self
    }
    func decreased() -> Bool {
        !self
    }
}
