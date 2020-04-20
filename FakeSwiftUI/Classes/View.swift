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
    open var _view:UIView!
    public let disposeBag:DisposeBag = .init()
    var overlayShape:Shape?
    var clipShape:Shape?
    var centerX:CGFloat?
    var centerY:CGFloat?
    var leading:CGFloat?
    var trailing:CGFloat?
    var top:CGFloat?
    var bottom:CGFloat?
    
    var heightConstraint:NSLayoutConstraint?
    var widthConstraint:NSLayoutConstraint?
    var bottomConstraint:NSLayoutConstraint?
    var centerYConstraint:NSLayoutConstraint?
    var centerXConstraint:NSLayoutConstraint?

    public init(){
        super.init(frame:.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func _init(){
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.append(to: self).fillSuperview()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func on(_ superview:UIView) -> View {
        superview.addSubview(self)
        setupConstraint()
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
    public func height(offset:CGFloat) -> Self {
        self.heightConstraint = heightAnchor.constraint(equalToConstant: offset)
        self.heightConstraint?.isActive = true
        return self
    }
    
    @discardableResult
    public func width(offset:CGFloat) -> Self {
        self.widthConstraint = widthAnchor.constraint(equalToConstant: offset)
        self.widthConstraint?.isActive = true
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
            self.centerXConstraint = centerXAnchor.constraint(equalTo: superview!.centerXAnchor, constant: centerX)
            self.centerXConstraint?.isActive = true
        }
        
        if let centerY = centerY {
            self.centerYConstraint = centerYAnchor.constraint(equalTo: superview!.centerYAnchor, constant: centerY)
            self.centerYConstraint?.isActive = true
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
        let path:UIBezierPath = clipShape.getPath(self)
        let layer:CAShapeLayer = .init()
        layer.path = path.cgPath
        layer.frame = self.bounds
        self.layer.mask = layer
    }
    
    internal func layoutOverlay(_ overlayShape:Shape){
        _view?.layer.sublayers?.first{ $0.name == "border" }?.removeFromSuperlayer()
        let path:UIBezierPath = overlayShape.getPath(self)
        let borderLayer:CAShapeLayer = .init()
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
    open func shown(_ stream$:Observable<Bool>) -> Self {
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
        color$.asDriver(onErrorJustReturn: .red) ~> _view.rx.backgroundColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func background(_ color:UIColor) -> Self {
        _view.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func onTap(_ callback:@escaping(UIView) -> ()) -> Self {
        _view.rx.tapGesture().when(.recognized).asDriver(onErrorJustReturn: UITapGestureRecognizer())
            .drive(onNext:{[weak self] _ in
                guard let self = self else { return }
                callback(self)
            })
            ~ disposeBag
        return self
    }
    
    @discardableResult
    public func height(_ constant$:Observable<CGFloat>) -> Self {
        constant$.asDriver(onErrorJustReturn: 0).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if self.heightConstraint == nil {
                self.heightConstraint = self.heightAnchor.constraint(equalToConstant: $0)
                self.heightConstraint?.isActive = true
            }
            self.heightConstraint?.constant = $0
            print($0)
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func width(_ constant$:Observable<CGFloat>) -> Self {
        constant$.asDriver(onErrorJustReturn: 0).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if self.widthConstraint == nil {
                self.widthConstraint = self.widthAnchor.constraint(equalToConstant: $0)
                self.widthConstraint?.isActive = true
            }
            self.widthConstraint?.constant = $0
            print($0)
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func bottom(_ constant$:Observable<CGFloat>) -> Self {
        constant$.asDriver(onErrorJustReturn: 0).do(afterNext:{[weak self] _ in
             self?.layoutIfNeeded()
        }).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if let superview = self.superview, self.bottomConstraint == nil {
                self.bottomConstraint = self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: $0)
                self.bottomConstraint?.isActive = true
            }
            if let c = self.bottomConstraint {
                c.constant = $0
            }
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func centerY(_ constant$:Observable<CGFloat>) -> Self {
        constant$.asDriver(onErrorJustReturn: 0).do(afterNext:{[weak self] _ in
             self?.layoutIfNeeded()
        }).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if let superview = self.superview, self.centerYConstraint == nil {
                self.centerYConstraint = self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: $0)
                self.centerYConstraint?.isActive = true
            }
            if let c = self.centerYConstraint {
                c.constant = $0
            }
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func centerX(_ constant$:Observable<CGFloat>) -> Self {
        constant$.asDriver(onErrorJustReturn: 0).do(afterNext:{[weak self] _ in
             self?.layoutIfNeeded()
        }).drive(onNext:{[weak self] in
            guard let self = self else { return }
            if let superview = self.superview, self.centerXConstraint == nil {
                self.centerXConstraint = self.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: $0)
                self.centerXConstraint?.isActive = true
            }
            if let c = self.centerXConstraint {
                c.constant = $0
            }
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func draggable() -> Self {
        var beginPos = CGPoint.zero
        
        self.rx.panGesture().when(.began)
            .asTranslation()
            .subscribe(onNext:{translation, _ in
                if let centerY = self.centerYConstraint, let centerX = self.centerXConstraint {
                    beginPos = CGPoint(x:centerX.constant, y:centerY.constant)
                }
            }) ~ disposeBag
        
        self.rx.panGesture().when(.changed)
            .asTranslation()
            .subscribe(onNext:{[unowned self] translation, _ in
                if let centerY = self.centerYConstraint, let centerX = self.centerXConstraint {
                    centerX.constant = beginPos.x + translation.x
                    centerY.constant = beginPos.y + translation.y
                    UIView.animate(withDuration: 0.1, animations: {[unowned self] in
                        self.superview!.layoutIfNeeded()
                    }, completion: nil)
                }                
            }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func scalable() -> Self {
        var scaleOrigin = CGPoint.zero
        var minSize:CGSize?
        self.rx.pinchGesture()
            .when(.began)
            .asScale()
            .subscribe(onNext:{[weak self] (scale, _) in
                guard let self = self, let widthConstraint = self.widthConstraint, let heightConstraint = self.heightConstraint else { return }
                scaleOrigin = CGPoint(x: widthConstraint.constant, y: heightConstraint.constant)
                minSize = minSize ?? CGSize(width: widthConstraint.constant / 2, height: heightConstraint.constant / 2)
            }) ~ disposeBag
        
        self.rx.pinchGesture()
            .when(.changed)
            .asScale()
            .subscribe(onNext:{[weak self] (scale, _) in
                guard let self = self, let widthConstraint = self.widthConstraint, let heightConstraint = self.heightConstraint else { return }
                widthConstraint.constant = max(scaleOrigin.x * scale, minSize!.width)
                heightConstraint.constant = max(scaleOrigin.y * scale, minSize!.height)
                UIView.animate(withDuration: 0.1, animations: {[weak self] in
                    self?.superview!.layoutIfNeeded()
                }, completion: nil)
            }) ~ disposeBag
        
        return self
    }
}
