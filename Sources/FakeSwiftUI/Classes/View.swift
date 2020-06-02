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
    
    open var view:UIView!

    public let disposeBag:DisposeBag = .init()
    var overlayShapes = [Shape]()
    var clipShape:Shape?
    
    var centerXParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var centerYParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var bottomParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var topParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var leadingParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var trailingParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var trailingLessThanOrEqualParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var widthParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    var heightParams:(constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)?
    
    var heightConstraint:NSLayoutConstraint?
    var widthConstraint:NSLayoutConstraint?
    var centerYConstraint:NSLayoutConstraint?
    var centerXConstraint:NSLayoutConstraint?
    
    var masker: UIView?

    public init(){
        super.init(frame:.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
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
        if let params = centerXParams {
            self.centerXConstraint = centerXAnchor.constraint(equalTo: superview!.centerXAnchor, constant: params.startValue)
            self.centerXConstraint?.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> centerXConstraint!.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = centerYParams {
            self.centerYConstraint = centerYAnchor.constraint(equalTo: superview!.centerYAnchor, constant: params.startValue)
            self.centerYConstraint?.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> centerYConstraint!.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = leadingParams {
            let constraint = leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: params.startValue)
            constraint.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = trailingParams {
            let constraint = trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: params.startValue)
            constraint.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = trailingLessThanOrEqualParams {
            let constraint = trailingAnchor.constraint(lessThanOrEqualTo: superview!.trailingAnchor, constant: params.startValue)
            constraint.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = topParams {
            let constraint = topAnchor.constraint(equalTo: superview!.topAnchor, constant: params.startValue)
            constraint.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = bottomParams {
            let constraint = bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: params.startValue)
            constraint.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = heightParams {
            self.heightConstraint = heightAnchor.constraint(equalToConstant: params.startValue)
            self.heightConstraint?.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> heightConstraint!.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
        
        if let params = widthParams {
            self.widthConstraint = widthAnchor.constraint(equalToConstant: params.startValue)
            self.widthConstraint?.isActive = true
            params.constant$.asDriver(onErrorJustReturn: params.startValue) ~> widthConstraint!.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        }
    }
    
    @discardableResult
    public func height(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        heightParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func width(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        widthParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func height(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        heightParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func width(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        widthParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupConstraint()
        }
    }
    
    @discardableResult
    public func leading(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        leadingParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func leading(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        leadingParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func trailing(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func trailingLessThanOrEqual(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingLessThanOrEqualParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func trailingLessThanOrEqual(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingLessThanOrEqualParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func trailing(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func bottom(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        bottomParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func bottom(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        bottomParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func top(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        topParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func top(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        topParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func centerY(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerYParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func centerY(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerYParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    public func centerX(offset:CGFloat, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerXParams = (constant$: Observable.just(offset), startValue: startValue, duration: duration)
        return self
    }

    @discardableResult
    public func centerX(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerXParams = (constant$: constant$, startValue: startValue, duration: duration)
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

        self.mask = self.masker
        
    }
    
    open func mask(_ view:UIView) -> Self {
        addSubview(view)
        view.fillSuperview()
        self.masker = view
        return self
    }
    
    open func layoutClipShape(_ clipShape:Shape){
        let path:UIBezierPath = clipShape.getClipPath(self)
        let layer:CAShapeLayer = .init()
        layer.path = path.cgPath
        layer.frame = self.bounds
        self.layer.mask = layer
    }
    
    open func layoutOverlay(_ overlayShape:Shape){
        layer.sublayers?.first{ $0.name == overlayShape.name }?.removeFromSuperlayer()
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
            if let degree$ = overlayShape.degree$ {
                degree$.asDriver(onErrorJustReturn: 0) ~> gradientLayer.rx.degree  ~ disposeBag
            } 
            
            gradientLayer.colors = overlayShape.colors.map({$0.cgColor})
            gradientLayer.mask = borderLayer
            layer.addSublayer(gradientLayer)
        } else {
            layer.addSublayer(borderLayer)
        }
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
//        layer.masksToBounds = false
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
    public func background(_ colors:[UIColor], degree:Double = 0, locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        return self.background(Observable.just(colors), degree$: Observable.just(degree), locations: locations, type: type)
    }
    
    @discardableResult
    public func background(_ colors:[UIColor], degree$:Observable<Double>, locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        return self.background(Observable.just(colors), degree$: degree$, locations: locations, type: type)
    }
    
    @discardableResult
    public func background(_ colors$:Observable<[UIColor]>, degree$:Observable<Double> = Observable.just(0), locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        func calc(_ x:Double, _ y:Double) -> Double {
            return pow(sin((2.0 * .pi * ((x + y) / 2.0))),2.0)
        }
        
        let gradientLayer:CAGradientLayer = self.layer as! CAGradientLayer
        gradientLayer.type = type
        gradientLayer.locations = locations
        
        colors$.map{ $0.map{ $0.cgColor} }.asDriver(onErrorJustReturn: []) ~> gradientLayer.rx.colors ~ disposeBag
        
        if type == .axial {
            degree$.asDriver(onErrorJustReturn: 0) ~> gradientLayer.rx.degree ~ disposeBag
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
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
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
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.superview!.layoutIfNeeded()
                }, completion: nil)
            }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func blur() -> Self {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.append(to: self).fillSuperview()
        return self
    }
    
    @discardableResult
    public func rotate(_ angle$:Observable<CGFloat>, duration:TimeInterval) -> Self {
        angle$.asDriver(onErrorJustReturn: 0).drive(onNext:{[weak self] angle in
            guard let self = self else { return }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                let radians = angle / 180.0 * CGFloat.pi
                self.transform = self.transform.rotated(by: radians)
            })
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

extension Reactive where Base : CAGradientLayer {
    public var colors: Binder<[CGColor]> {
        return Binder(self.base) { control, value in
            control.colors = value
        }
    }
    
    public var degree: Binder<Double> {
        return Binder(self.base) { control, value in
            control.degree = value
        }
    }
}

extension CAGradientLayer
{
    var degree:Double {
        get {
            return 0
        }
        set{
            func calc(_ x:Double, _ y:Double) -> Double {
                return pow(sin((2.0 * .pi * ((x + y) / 2.0))),2.0)
            }
            let x: Double = newValue / 360.0
            let a:Double = calc(x, 0.75)
            let b:Double = calc(x, 0.0)
            let c:Double = calc(x, 0.25)
            let d:Double = calc(x, 0.5)
            self.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
            self.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
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
