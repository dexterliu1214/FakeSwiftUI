//
//  UIEdgeInsets+extension.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/6/5.
//

import Foundation
import UIKit

public extension UIEdgeInsets
{
    enum Side {
        case top
        case right
        case bottom
        case left
    }
    
    static func all(_ constant:CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: constant, left: constant, bottom: constant, right: constant)
    }
    
    static func symmetric(_ vertical:CGFloat, _ horizontal:CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    static func only(_ side:Side, _ constant:CGFloat) -> UIEdgeInsets {
        switch side {
            case Side.top:
                return UIEdgeInsets(top: constant, left: 0, bottom: 0, right: 0)
            case Side.right:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: constant)
            case Side.bottom:
                return UIEdgeInsets(top: 0, left: 0, bottom: constant, right: 0)
            case Side.left:
                return UIEdgeInsets(top: 0, left: constant, bottom: 0, right: 0)
        }
    }
}
