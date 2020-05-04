//
//  extension.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/2/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxAnimated

extension CGFloat
{
    public var int:Int {
        return Int(self)
    }
}

extension AnimatedSink where Base: UIView {
    public func fadeIn(duration: TimeInterval) -> AnimatedSink<Base> {
        let type = AnimationType<Base>(type:RxAnimationType.animation, duration: duration, setup:{ view in
            view.alpha = 0
        }, animations: { view in
            view.alpha = 1
        })
        
        return AnimatedSink<Base>(base: self.base, type: type)
    }
    
    public func tick2(_ direction: FlipDirection = .right, duration: TimeInterval) -> AnimatedSink<Base> {
        let type = AnimationType<Base>(type: RxAnimationType.spring(damping: 0.33, velocity: 0), duration: duration, setup: { view in
            view.transform = CGAffineTransform(rotationAngle: direction == .right ?  -0.3 : 0.3)
        }, animations: { view in
            view.transform = CGAffineTransform.identity
        })
        return AnimatedSink<Base>(base: self.base, type: type)
    }
}

extension UIEdgeInsets
{
    public enum Side {
        case top
        case right
        case bottom
        case left
    }
    
    public static func all(_ constant:CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: constant, left: constant, bottom: constant, right: constant)
    }
    
    public static func symmetric(_ vertical:CGFloat, _ horizontal:CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    public static func only(_ side:Side, _ constant:CGFloat) -> UIEdgeInsets {
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

extension UIColor
{
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    public convenience init(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 255) {
        self.init(red:r / 255.0, green:g / 255.0, blue: b / 255.0, alpha: a / 255.0)
    }
}

extension Int
{
    public var color: UIColor {
        get {
            return UIColor(hex:self)
        }
    }
}
