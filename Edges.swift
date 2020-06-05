//
//  Edges.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/6/5.
//

import Foundation

protocol Option: RawRepresentable, Hashable, CaseIterable {}
public enum Edge:Int, Option {
    case top
    case trailing
    case bottom
    case leading
    case all
    case horizontal
    case vertical
}

public extension Set where Element == Edge {
    static var horizontal: Set<Edge> {
        return [.leading, .trailing]
    }
    
    static var vertical: Set<Edge> {
        return [.top, .bottom]
    }
    
    static var all: Set<Edge> {
        return Set(Element.allCases)
    }
}

public typealias Edges = Set<Edge>

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }
        
        return rawValue
    }
}
