//
//  AnimatedSink+extension.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/6/5.
//

import Foundation
import UIKit
import RxAnimated

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
