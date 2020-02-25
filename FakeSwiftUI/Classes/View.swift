//
//  View.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxBinding
import RxGesture

open class View:UIView {
    public var _view:UIView?
    public let disposeBag = DisposeBag()
    var overlayShape:Shape?
    var clipShape:Shape?
    var centerX:CGFloat?
    var centerY:CGFloat?
    var leading:CGFloat?
    var trailing:CGFloat?
    var top:CGFloat?
    var bottom:CGFloat?
    var heightConstraint:NSLayoutConstraint?
    
    @discardableResult
    public func on(_ superview:UIView) -> Self {
        superview.addSubview(self)
        setupConstraint()
        return self
    }
    
    @discardableResult
    public func height(_ value:Observable<CGFloat>) -> Self {
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        self.heightConstraint?.isActive = true
        value.asDriver(onErrorJustReturn: 0).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if let hs = self.heightConstraint {
                hs.constant = $0
                self.layoutIfNeeded()
            }
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func frame(width:CGFloat?, height:CGFloat?) -> Self {
        if let width = width {
            self.width(width)
        }
        
        if let height = height {
            self.height(height)
        }
        return self
    }
    
    @discardableResult
    public func top(offset:CGFloat) -> Self {
        top = offset
        return self
    }
    
    @discardableResult
    public func bottom(offset:CGFloat) -> Self {
        bottom = offset
        return self
    }
    
    @discardableResult
    public func fill(padding:UIEdgeInsets = .all(0)) -> Self {
        leading(offset:padding.left).trailing(offset: -padding.right).top(offset: padding.top).bottom(offset: -padding.bottom)
        return self
    }
    
    @discardableResult
    public func leading(offset:CGFloat) -> Self {
        leading = offset
        return self
    }
    
    @discardableResult
    public func trailing(offset:CGFloat) -> Self {
        trailing = offset
        return self
    }
    
    @discardableResult
    public func centerY(offset:CGFloat) -> Self {
        centerY = offset
        return self
    }
    
    @discardableResult
    public func centerX(offset:CGFloat) -> Self {
        centerX = offset
        return self
    }
    
    public func setupConstraint(){
        if let centerX = centerX {
            self.centerX(centerX)
        }
        
        if let centerY = centerY {
            self.centerY(centerY)
        }
        
        if let leading = leading {
           self.leading(leading)
        }
        
        if let trailing = trailing {
           self.trailing(trailing)
        }
        
        if let top = top {
           self.top(top)
        }
        
        if let bottom = bottom {
           self.bottom(bottom)
        }
    }
    
    public init(){
        super.init(frame:.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func _init(){
        _view?.translatesAutoresizingMaskIntoConstraints = false
        _view?.append(to: self).fillSuperview()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let overlayShape = overlayShape {
           layoutOverlay(overlayShape)
        }
         
        if let clipShape = clipShape {
            layoutClipShape(clipShape)
        }
    }
    
    internal func layoutClipShape(_ clipShape:Shape){
        let path = clipShape.getPath(self)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.frame = self.bounds
        self.layer.mask = layer
    }
    
    internal func layoutOverlay(_ overlayShape:Shape){
        _view?.layer.sublayers?.first{ $0.name == "border" }?.removeFromSuperlayer()
        let path = overlayShape.getPath(self)
        let borderLayer = CAShapeLayer()
        borderLayer.name = "border"
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = overlayShape.lineWidth
        borderLayer.strokeColor = overlayShape.color.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = self.bounds
        _view?.layer.addSublayer(borderLayer)
    }
    
    @discardableResult
    public func overlay(_ shape:Shape) -> Self {
        self.overlayShape = shape
        return self
    }
     
    @discardableResult
    public func clipShape(_ shape:Shape) -> Self {
        self.clipShape = shape
        return self
    }
     
    @discardableResult
    public func shadow(color: UIColor = UIColor.black, radius: CGFloat = 3, x: CGFloat = 0, y: CGFloat = 0, opacity:Float = 1.0) -> Self {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: x, height: y)
        return self
    }
    
    @discardableResult
    public func shown(_ stream$:Observable<Bool>) -> Self {
        stream$.asDriver(onErrorJustReturn: false) ~> rx.isShow ~ disposeBag
        return self
    }
    
    @discardableResult
    public func hidden(_ stream$:Observable<Bool>) -> Self {
        stream$.asDriver(onErrorJustReturn: true) ~> rx.isHidden ~ disposeBag
        return self
    }
    
    @discardableResult
    public func hidden(_ value:Bool) -> Self {
        self.isHidden = value
        return self
    }
    
    @discardableResult
    public func fade(_ stream$:Observable<Bool>, duration:TimeInterval) -> Self {
        stream$.asDriver(onErrorJustReturn: true) ~> rx.animated.fade(duration: duration).isHidden ~ disposeBag
        return self
    }
    
    @discardableResult
    public func background(_ color$:Observable<UIColor>) -> Self {
        guard let _view = _view else { return self }
        color$.asDriver(onErrorJustReturn: .red) ~> _view.rx.backgroundColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func background(_ color:UIColor) -> Self {
        guard let _view = _view else { return self }
        _view.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func onTap(_ callback:@escaping(UIView) -> ()) -> Self {
        guard let _view = _view else { return self }
        _view.rx.tapGesture().when(.recognized).asDriver(onErrorJustReturn: UITapGestureRecognizer())
            .drive(onNext:{[weak self] _ in
                guard let self = self else { return }
                callback(self)
            })
            ~ disposeBag
        return self
    }
    
    @discardableResult
    public func height(_ constant$:Observable<CGFloat>, isActive$:Observable<Bool> = Observable.just(true)) -> Self {
        let c = heightAnchor.constraint(equalToConstant: 0)
        constant$.asDriver(onErrorJustReturn: 0) ~> c.rx.constant ~ disposeBag
        isActive$.asDriver(onErrorJustReturn: false) ~> c.rx.active ~ disposeBag
        return self
    }
}
