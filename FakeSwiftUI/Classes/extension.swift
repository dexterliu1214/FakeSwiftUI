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
import Lottie
import PromiseKit
import AwaitKit

extension UITableView {
    public func scrollToBottom(animated:Bool = false){
        if numberOfSections <= 0 {
            return
        }
        let lastSection = numberOfSections - 1
        let lastRow = numberOfRows(inSection: lastSection) - 1
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)
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

extension CGFloat
{
    public var int:Int {
        return Int(self)
    }
}

extension Lottie.AnimationView
{
    @discardableResult
    public func setAnimation(urlString:String) -> Promise<()> {
        return Promise<()> { seal in
            async {
                do {
                    let (data, _) = try await(URLSession.shared.dataTask(.promise, with: URL(string: urlString)!))
                    let animation = try JSONDecoder().decode(Lottie.Animation.self, from: data)

                    DispatchQueue.main.async {
                        self.animation = animation
                        self.alpha = 1
                        self.isHidden = false
                        self.play { isDone in
                            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                    self.alpha = 0
                                }, completion: { _ in
                                    self.isHidden = true
                                    seal.fulfill(())
                                })
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func taskPlay() {
        DispatchQueue.main.async {
            self.isHidden = false
            self.play(completion: { [unowned self] finish in
                if finish {
                    self.isHidden = true
                }
            })
        }
    }
}

extension Reactive where Base: UIButton {
    public var isDisabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = !value
        }
    }
    
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }
    
    public var backgroundColor:Binder<UIColor> {
        return Binder(self.base) { (control, value) -> () in
            control.backgroundColor = value
        }
    }
    
    public func titleColor(for controlState: UIControl.State = []) -> Binder<UIColor?> {
       return Binder(self.base) { button, color -> Void in
           button.setTitleColor(color, for: controlState)
       }
   }
}

public enum Side {
    case top
    case right
    case bottom
    case left
}

extension UIEdgeInsets
{
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

extension UIView {
    @discardableResult
    public func append(to superview:UIView) -> Self {
        superview.addSubview(self)
        return self
    }
    
    @discardableResult
    public func fillSuperview(padding:UIEdgeInsets = .zero) -> Self {
        anchor(top: superview?.topAnchor, bottom: superview?.bottomAnchor, left: superview?.leadingAnchor, right: superview?.trailingAnchor, padding: padding).end()
        return self
    }
    
    @discardableResult
    public func fillSafeArea(padding:UIEdgeInsets = .zero) -> Self {
        anchor(top: superview?.safeTopAnchor(), bottom: superview?.safeBottomAnchor(), left: superview?.safeLeadingAnchor(), right: superview?.safeTrailingAnchor(), padding: padding).end()
        return self
    }
    
    @discardableResult
    public func centerX(_ offset:CGFloat = 0) -> Self {
        centerX(to: superview!.centerXAnchor, constant: offset)
        return self
    }
    
    @discardableResult
    public func centerY(_ offset:CGFloat = 0) -> Self {
        centerY(to: superview!.centerYAnchor, constant: offset)
        return self
    }
    
    @discardableResult
    public func centerX(to anchor:NSLayoutXAxisAnchor, constant:CGFloat = 0) -> Self {
        centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func centerY(to anchor:NSLayoutYAxisAnchor, constant:CGFloat = 0) -> Self {
        centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func width(_ constant:CGFloat, multiplier: CGFloat = 1) -> Self {
        widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func widthAnchor(_ anchor:NSLayoutDimension, multiper:CGFloat, constant:CGFloat = 0)-> Self {
        let cons = widthAnchor.constraint(equalTo: anchor, multiplier: multiper, constant: constant)
        cons.identifier = "width"
        cons.isActive = true
        return self
    }
    
    @discardableResult
    public func height(_ constant:CGFloat, multiplier: CGFloat = 1) -> Self {
        heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func heightAnchor(_ anchor:NSLayoutDimension,multiper:CGFloat)-> Self {
        heightAnchor.constraint(equalTo: anchor, multiplier: multiper).isActive = true
        return self
    }
    
    @discardableResult
    public func top(anchor:NSLayoutYAxisAnchor? = nil, _ constant:CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.topAnchor
        topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func bottom(anchor:NSLayoutYAxisAnchor? = nil, _ constant:CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.bottomAnchor
        bottomAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func leading(anchor:NSLayoutXAxisAnchor? = nil,_ constant:CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.leadingAnchor
        leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    public func trailing(anchor:NSLayoutXAxisAnchor? = nil, _ constant:CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.trailingAnchor
        trailingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    public func end() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    public func anchor(top:NSLayoutYAxisAnchor?, bottom:NSLayoutYAxisAnchor?, left:NSLayoutXAxisAnchor?, right:NSLayoutXAxisAnchor?, padding:UIEdgeInsets = .zero, size:CGSize = .zero, centerX:NSLayoutXAxisAnchor? = nil, centerY:NSLayoutYAxisAnchor? = nil) -> Self {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let left = left {
            leadingAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        
        if let right = right {
            trailingAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX, constant: 0).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY, constant: 0).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        return self
    }
    
    @discardableResult
    public func safeBottomAnchor() -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }
    
    @discardableResult
    public func safeTopAnchor() -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
    
    @discardableResult
    public func safeLeadingAnchor() -> NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leadingAnchor
        } else {
            return leadingAnchor
        }
    }
    
    @discardableResult
    public func safeTrailingAnchor() -> NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.trailingAnchor
        } else {
            return trailingAnchor
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

extension Reactive where Base : UIView {
    public var isShow: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isShow = value
        }
    }
}


extension UIView {
    public var isShow:Bool {
        get {
            return !isHidden
        }
        
        set {
            isHidden = !newValue
        }
    }
}
