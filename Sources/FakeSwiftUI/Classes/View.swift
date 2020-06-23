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
import RxAnimated

open class View:UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    public let disposeBag:DisposeBag = .init()
    var overlayShapes$ = BehaviorRelay(value:[Shape]())
    var clipShape:Shape?
    typealias LayoutParam = (constant$:Observable<CGFloat>, startValue:CGFloat, duration:TimeInterval)
    var centerXParams:LayoutParam?
    var centerYParams:LayoutParam?
    var bottomParams:LayoutParam?
    var topParams:LayoutParam?
    var leadingParams:LayoutParam?
    var trailingParams:LayoutParam?
    var trailingLessThanOrEqualParams:LayoutParam?
    var widthParams:LayoutParam?
    var heightParams:LayoutParam?
    
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
    open func on(_ superview:UIView) -> View {
        superview.addSubview(self)
        return self
    }
    
    @discardableResult
    open func frame(width:Observable<CGFloat>?, height:Observable<CGFloat>?) -> Self {
        if let width = width {
            self.width(width)
        }
        
        if let height = height {
            self.height(height)
        }
        return self
    }
    
    @discardableResult
    open func center(_ x:Observable<CGFloat> = .just(0), _ y:Observable<CGFloat> = .just(0)) -> Self {
        self.centerX(x).centerY(y)
    }
    
    @discardableResult
    open func fill(padding:UIEdgeInsets = .all(0)) -> Self {
        self.leading(.just(padding.left))
            .trailing(.just(-padding.right))
            .top(.just(padding.top))
            .bottom(.just(-padding.bottom))
        return self
    }
    
    var ignoringSafeEdges:Edges?
    @discardableResult
    open func edgesIgnoringSafeArea(_ edges:Edges) -> Self {
        ignoringSafeEdges = edges
        return self
    }
    
    open func setupConstraint(){
        let otherTopAnchor = (ignoringSafeEdges?.contains(.top) ?? false) ? superview!.topAnchor : superview!.safeAreaLayoutGuide.topAnchor
        bindConstraint(topAnchor, to: otherTopAnchor, params: topParams, compare: "==")
        
        let otherBottomAnchor = (ignoringSafeEdges?.contains(.bottom) ?? false) ? superview!.bottomAnchor : superview!.safeAreaLayoutGuide.bottomAnchor
        bindConstraint(bottomAnchor, to: otherBottomAnchor, params: bottomParams, compare: "==")
        
        let otherTrailingAnchor = (ignoringSafeEdges?.contains(.trailing) ?? false) ? superview!.trailingAnchor : superview!.safeAreaLayoutGuide.trailingAnchor
        bindConstraint(trailingAnchor, to: otherTrailingAnchor, params: trailingParams, compare: "==")
        
        let otherTrailingLessThanOrEqualAnchor = (ignoringSafeEdges?.contains(.trailing) ?? false) ? superview!.trailingAnchor : superview!.safeAreaLayoutGuide.trailingAnchor
        bindConstraint(trailingAnchor, to: otherTrailingLessThanOrEqualAnchor, params: trailingLessThanOrEqualParams, compare: "<=")
        
        let otherLeadingAnchor = (ignoringSafeEdges?.contains(.leading) ?? false) ? superview!.leadingAnchor : superview!.safeAreaLayoutGuide.leadingAnchor
        bindConstraint(leadingAnchor, to: otherLeadingAnchor, params: leadingParams, compare: "==")
        
        self.centerXConstraint = bindConstraint(centerXAnchor, to: superview!.centerXAnchor, params: centerXParams, compare: "==")
        self.centerYConstraint = bindConstraint(centerYAnchor, to: superview!.centerYAnchor, params: centerYParams, compare: "==")
        self.heightConstraint = bindConstraint(heightAnchor, params: heightParams, compare: "==")
        self.widthConstraint = bindConstraint(widthAnchor, params: widthParams, compare: "==")
    }
    
    @discardableResult
    func bindConstraint<T:AnyObject>(_ anchor:NSLayoutAnchor<T>, to otherAnchor:NSLayoutAnchor<T>? = nil, params:LayoutParam?, compare:String) -> NSLayoutConstraint? {
        guard let params = params else { return nil }
        var constraint:NSLayoutConstraint!
        switch anchor {
            case let dimension as NSLayoutDimension:
            switch compare {
                case "==":
                    constraint = dimension.constraint(equalToConstant: params.startValue)
                case "<=":
                    constraint = dimension.constraint(lessThanOrEqualToConstant: params.startValue)
                case ">=":
                    constraint = dimension.constraint(greaterThanOrEqualToConstant: params.startValue)
                default:
                    return nil
            }
            default:
                guard let otherAnchor = otherAnchor else { return nil }
                switch compare {
                    case "==":
                        constraint = anchor.constraint(equalTo: otherAnchor, constant: params.startValue)
                    case "<=":
                        constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, constant: params.startValue)
                    case ">=":
                        constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, constant: params.startValue)
                    default:
                        return nil
                }
        }
        
        constraint.isActive = true
        params.constant$.asDriver(onErrorJustReturn: params.startValue)
            ~> constraint.rx.animated.layout(duration: params.duration).constant ~ disposeBag
        return constraint
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupConstraint()
        }
    }
    
    @discardableResult
    open func height(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        heightParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func width(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        widthParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func leading(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        leadingParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func trailing(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func trailingLessThanOrEqual(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        trailingLessThanOrEqualParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }

    @discardableResult
    open func bottom(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        bottomParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func top(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        topParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    @discardableResult
    open func centerY(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerYParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }

    @discardableResult
    open func centerX(_ constant$:Observable<CGFloat>, startValue:CGFloat = 0, duration:TimeInterval = 0) -> Self {
        centerXParams = (constant$: constant$, startValue: startValue, duration: duration)
        return self
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        overlayShapes$.asDriver().drive(onNext:{[weak self] shapes in
            self?.layer.sublayers?.forEach{
                if let name = $0.name, name.starts(with: "overlay") {
                    $0.removeFromSuperlayer()
                }
            }
            shapes.enumerated().forEach{[weak self] (i, shape) in
                shape.name = "overlay\(i)"
                self?.layoutOverlay(shape)
            }
        }) ~ disposeBag
         
        if let clipShape = clipShape {
            layoutClipShape(clipShape)
        }

        self.mask = self.masker
    }
    
    open func mask(_ maskView:UIView) -> Self {
        addSubview(maskView)
        maskView.fillSuperview()
        self.masker = maskView
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
    public func overlay(_ shape$:Observable<[Shape]>) -> Self {
        shape$ ~> self.overlayShapes$ ~ disposeBag
        return self
    }
    
    @discardableResult
    public func overlay(_ shapes:[Shape]) -> Self {
        self.overlay(Observable.just(shapes))
    }
    
    @discardableResult
    public func overlay(_ shape:Shape) -> Self {
        self.overlay(Observable.just([shape]))
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
    open func shown(_ stream$:Observable<Bool>, _ animationSink:((Self) -> (AnimatedSink<Self>))?) -> Self {
        self.hidden(stream$.map{!$0}, animationSink)
    }
    
    @discardableResult
    open func hidden(_ stream$:Observable<Bool>, _ animationSink:((Self) -> (AnimatedSink<Self>))?) -> Self {
        let animationSink = animationSink?(self) ?? rx.animated.fade(duration: 0)
        stream$.asDriver(onErrorJustReturn: false) ~> animationSink.isHidden ~ disposeBag
        return self
    }
    
    @discardableResult
    open func background(_ color:UIColor) -> Self {
        self.background(.just(color))
    }
    
    @discardableResult
    open func background(_ color:Observable<UIColor>) -> Self {
        color ~> self.rx.backgroundColor ~ disposeBag
        return self
    }
    
    @discardableResult
    open func background(_ colors:[UIColor], degree:Double = 0, locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
        self.background(.just(colors), degree$:.just(degree), locations:locations, type:type)
    }
    
    @discardableResult
    open func background(_ colors$:Observable<[UIColor]>, degree$:Observable<Double> = Observable.just(0), locations:[NSNumber]? = nil, type:CAGradientLayerType = .axial) -> Self {
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
    open func onTap(_ callback:@escaping(UIView) -> ()) -> Self {
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
    open func draggable(axis:Axis = .both, limit:Observable<CGRect?> = Observable.just(nil), _ callback:((CGPoint) -> ())? = nil) -> Self {
        var beginPos = CGPoint.zero
        
        self.rx.panGesture().when(.began)
            .asTranslation()
            .subscribe(onNext:{ _ in
                guard let centerY = self.centerYConstraint, let centerX = self.centerXConstraint else { return }
                beginPos = CGPoint(x:centerX.constant, y:centerY.constant)
            }) ~ disposeBag
        
        Observable.combineLatest(
            self.rx.panGesture().when(.changed).asTranslation().map{ $0.0 },
            limit
        )
            .subscribe(onNext:{[weak self] translation, limit in
                guard let self = self, let centerY = self.centerYConstraint, let centerX = self.centerXConstraint else { return }
                if axis.contains(.horizontal) {
                    var constant = beginPos.x + translation.x
                    if let limit = limit {
                        constant = max(limit.minX, min(limit.width, constant))
                    }
                    centerX.constant = constant
                }
                if axis.contains(.vertical) {
                    var constant = beginPos.y + translation.y
                    if let limit = limit {
                        constant = max(limit.minY, min(limit.height, constant))
                    }
                    centerY.constant = constant
                }
                
                callback?(CGPoint(x: centerX.constant, y: centerY.constant))
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.superview?.layoutIfNeeded()
                }, completion: nil)
            }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    open func scalable() -> Self {
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
    open func blur(_ style:UIBlurEffect.Style = .light) -> Self {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.append(to: self).fillSuperview()        
        return self
    }
    
    @discardableResult
    open func rotate(_ angle$:Observable<CGFloat>, duration:TimeInterval) -> Self {
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

public struct Axis : OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    public static let horizontal = Axis(rawValue: 1 << 0)
    
    public static let vertical = Axis(rawValue: 1 << 1)
    
    public static let both:Axis = [.horizontal, .vertical]
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
    public var degree:Double {
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

public extension UIView
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
