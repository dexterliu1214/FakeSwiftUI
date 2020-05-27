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
import RxCocoa

open class View:UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    open var _view:UIView!
    public let disposeBag:DisposeBag = .init()
    var overlayShapes = [Shape]()
    var clipShape:Shape?
    
    var centerXConstant$:Observable<CGFloat>?
    var centerXDuration:TimeInterval = 0
    
    var centerYConstant$:Observable<CGFloat>?
    var centerYDuration:TimeInterval = 0
    
    var bottomConstant$:Observable<CGFloat>?
    var bottomDuration:TimeInterval = 0
    
    var topConstant$:Observable<CGFloat>?
    var topDuration:TimeInterval = 0
    
    var leadingConstant$:Observable<CGFloat>?
    var leadingDuration:TimeInterval = 0

    var trailingConstant$:Observable<CGFloat>?
    var trailingDuration:TimeInterval = 0

    var trailingLessThanOrEqualConstant$:Observable<CGFloat>?
    var trailingLessThanOrEqualDuration:TimeInterval = 0

    var widthConstant$:Observable<CGFloat>?
    var widthDuration:TimeInterval = 0

    var heightConstant$:Observable<CGFloat>?
    var heightDuration:TimeInterval = 0

    var heightConstraint:NSLayoutConstraint?
    var widthConstraint:NSLayoutConstraint?
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
        return self
    }
    
    @discardableResult
    public func frame(width:CGFloat?, height:CGFloat?) -> Self {
        if let width = width {
            self.width(offset:width)
        }
        
        if let height = height {
            self.height(offset:height)
        }
        return self
    }
    
    @discardableResult
    public func fill(padding:UIEdgeInsets = .all(0)) -> Self {
        leading(offset:padding.left).trailing(offset: -padding.right).top(offset: padding.top).bottom(offset: -padding.bottom)
        return self
    }
    
    public func setupConstraint(){
        if let constant$ = centerXConstant$ {
            self.centerXConstraint = centerXAnchor.constraint(equalTo: superview!.centerXAnchor, constant: 0)
            self.centerXConstraint?.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> centerXConstraint!.rx.animated.layout(duration: centerXDuration).constant ~ disposeBag
        }
        
        if let constant$ = centerYConstant$ {
            self.centerYConstraint = centerYAnchor.constraint(equalTo: superview!.centerYAnchor, constant: 0)
            self.centerYConstraint?.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> centerYConstraint!.rx.animated.layout(duration: centerYDuration).constant ~ disposeBag
        }
        
        if let constant$ = leadingConstant$ {
            let constraint = leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: 0)
            constraint.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> constraint.rx.animated.layout(duration: leadingDuration).constant ~ disposeBag
        }
        
        if let constant$ = trailingConstant$ {
            let constraint = trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: 0)
            constraint.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> constraint.rx.animated.layout(duration: trailingDuration).constant ~ disposeBag
        }
        
        if let constant$ = trailingLessThanOrEqualConstant$ {
            let constraint = trailingAnchor.constraint(lessThanOrEqualTo: superview!.trailingAnchor, constant: 0)
            constraint.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> constraint.rx.animated.layout(duration: trailingLessThanOrEqualDuration).constant ~ disposeBag
        }
        
        if let constant$ = topConstant$ {
            let constraint = topAnchor.constraint(equalTo: superview!.topAnchor, constant: 0)
            constraint.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> constraint.rx.animated.layout(duration: topDuration).constant ~ disposeBag
        }
        
        if let constant$ = bottomConstant$ {
            let constraint = bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0)
            constraint.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> constraint.rx.animated.layout(duration: bottomDuration).constant ~ disposeBag
        }
        
        if let constant$ = heightConstant$ {
            self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)
            self.heightConstraint?.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> heightConstraint!.rx.animated.layout(duration: heightDuration).constant ~ disposeBag
        }
        
        if let constant$ = widthConstant$ {
            self.widthConstraint = widthAnchor.constraint(equalToConstant: 0)
            self.widthConstraint?.isActive = true
            constant$.asDriver(onErrorJustReturn: 0) ~> widthConstraint!.rx.animated.layout(duration: widthDuration).constant ~ disposeBag
        }
    }
    
    @discardableResult
    public func height(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        heightConstant$ = constant$
        heightDuration = duration
        return self
    }
    
    @discardableResult
    public func width(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        widthConstant$ = constant$
        widthDuration = duration
        return self
    }
    
    @discardableResult
    public func height(offset:CGFloat) -> Self {
        heightConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func width(offset:CGFloat) -> Self {
        widthConstant$ = Observable.just(offset)
        return self
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupConstraint()
        }
    }
    
    @discardableResult
    public func leading(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        leadingConstant$ = constant$
        leadingDuration = duration
        return self
    }
    
    @discardableResult
    public func leading(offset:CGFloat) -> Self {
        leadingConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func trailing(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        trailingConstant$ = constant$
        trailingDuration = duration
        return self
    }
    
    @discardableResult
    public func trailingLessThanOrEqual(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        trailingLessThanOrEqualConstant$ = constant$
        trailingLessThanOrEqualDuration = duration
        return self
    }
    
    @discardableResult
    public func trailingLessThanOrEqual(offset:CGFloat) -> Self {
        trailingLessThanOrEqualConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func trailing(offset:CGFloat) -> Self {
        trailingConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func bottom(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        bottomConstant$ = constant$
        bottomDuration = duration
        return self
    }
    
    @discardableResult
    public func bottom(offset:CGFloat) -> Self {
        bottomConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func top(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        topConstant$ = constant$
        topDuration = duration
        return self
    }
    
    @discardableResult
    public func top(offset:CGFloat) -> Self {
        topConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func centerY(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        centerYConstant$ = constant$
        centerYDuration = duration
        return self
    }
    
    @discardableResult
    public func centerY(offset:CGFloat) -> Self {
        centerYConstant$ = Observable.just(offset)
        return self
    }
    
    @discardableResult
    public func centerX(offset:CGFloat) -> Self {
        centerXConstant$ = Observable.just(offset)
        return self
    }

    @discardableResult
    public func centerX(_ constant$:Observable<CGFloat>, duration:TimeInterval = 0) -> Self {
        centerXConstant$ = constant$
        centerXDuration = duration
        return self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        overlayShapes.enumerated().forEach{ (i, shape) in
           shape.name = "overlay\(i)"
           layoutOverlay(shape)
        }
         
        if let clipShape = clipShape {
            layoutClipShape(clipShape)
        }
    }
    
    open func layoutClipShape(_ clipShape:Shape){
        let path:UIBezierPath = clipShape.getClipPath(self)
        let layer:CAShapeLayer = .init()
        layer.path = path.cgPath
        layer.frame = self.bounds
        self.layer.mask = layer
    }
    
    open func layoutOverlay(_ overlayShape:Shape){
        _view?.layer.sublayers?.first{ $0.name == overlayShape.name }?.removeFromSuperlayer()
        let path:UIBezierPath = overlayShape.getOverlayPath(self)
        let borderLayer:CAShapeLayer = .init()
        borderLayer.name = overlayShape.name
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = overlayShape.lineWidth
        borderLayer.strokeColor = overlayShape.color.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = self.bounds
        
        if overlayShape.colors.count > 0 {
            let gradientLayer = CAGradientLayer()
            gradientLayer.name = overlayShape.name
            gradientLayer.frame = self.bounds
            let x: Double = overlayShape.degree / 360.0
            let a:Double = calc(x, 0.75)
            let b:Double = calc(x, 0.0)
            let c:Double = calc(x, 0.25)
            let d:Double = calc(x, 0.5)
            gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
            gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
            gradientLayer.colors = overlayShape.colors.map({$0.cgColor})
            gradientLayer.mask = borderLayer
            _view?.layer.addSublayer(gradientLayer)
        } else {
            _view?.layer.addSublayer(borderLayer)
        }
    }
    
    fileprivate func calc(_ x:Double, _ y:Double) -> Double {
        return pow(sin((2.0 * .pi * ((x + y) / 2.0))),2.0)
    }
    
    @discardableResult
    public func overlay(_ shape:Shape) -> Self {
        self.overlayShapes.append(shape)
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
    public func background(_ color:UIColor) -> Self {
        return self.background([color, color])
    }
    
    @discardableResult
    public func background(_ color$:Observable<UIColor>) -> Self {
        return self.background(color$.map{ [$0, $0] })
    }
    
    @discardableResult
    public func background(_ colors:[UIColor], degree:Double? = nil, locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        return self.background(Observable.just(colors), degree: degree, locations: locations, type: type)
    }
    
    @discardableResult
    public func background(_ colors$:Observable<[UIColor]>, degree:Double? = nil, locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        func calc(_ x:Double, _ y:Double) -> Double {
            return pow(sin((2.0 * .pi * ((x + y) / 2.0))),2.0)
        }
        
        let gradientLayer:CAGradientLayer = self.layer as! CAGradientLayer
        gradientLayer.type = type
        gradientLayer.locations = locations
        
        colors$
            .map{ $0.map{ $0.cgColor} }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext:{
                gradientLayer.colors = $0
            }) ~ disposeBag
        
        if type == .axial {
            if let degree:Double = degree {
                let x: Double = degree / 360.0
                let a:Double = calc(x, 0.75)
                let b:Double = calc(x, 0.0)
                let c:Double = calc(x, 0.25)
                let d:Double = calc(x, 0.5)
                gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
                gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
            }
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1,y: 1)
        }
        return self
    }
    
    @discardableResult
    public func onTap(_ callback:@escaping(UIView) -> ()) -> Self {
        rx.tapGesture(configuration: { gestureRecognizer, delegate in
            delegate.touchReceptionPolicy = .custom {gestureRecognizer, touch in
                return gestureRecognizer.view!.isKind(of: Self.self)
            }
        }).when(.recognized).asDriver(onErrorJustReturn: UITapGestureRecognizer())
            .drive(onNext:{[weak self] _ in
                guard let self = self else { return }
                callback(self)
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
    
    @discardableResult
    public func blur() -> Self {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.append(to: _view).fillSuperview()
        return self
    }
    
    @discardableResult
    public func rotate(_ angle$:Observable<CGFloat>, duration:TimeInterval) -> Self {
        angle$.asDriver(onErrorJustReturn: 0).drive(onNext:{[weak self] angle in
            guard let self = self else { return }
            UIView.animate(withDuration: duration) {
                let radians = angle / 180.0 * CGFloat.pi
                self._view.transform = self._view.transform.rotated(by: radians)
            }
        }) ~ disposeBag
        
        return self
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


extension UIView
{
    @discardableResult
    func append(to superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }
    
    @discardableResult
    func fillSuperview(_ insets:UIEdgeInsets = .zero) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview!.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -insets.bottom).isActive = true
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -insets.right).isActive = true
        return self
    }
    
    @discardableResult
    func fillSafeArea(_ insets:UIEdgeInsets = .zero) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom).isActive = true
        leadingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right).isActive = true
        return self
    }
}
