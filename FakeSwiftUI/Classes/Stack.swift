//
//  Stack.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture
import PromiseKit
import AwaitKit
open class ZStack:View
{
    var backgroundView:UIView?
    
    public init(_ subviews:View...) {
        super.init()
        _view = UIView()
        _init()
        subviews.forEach{[weak self] in
            guard let self = self, let view = self._view else { return }
            let v = $0
            v.on(view)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func background(_ colors:[UIColor], degree:Double? = nil, locations:[NSNumber]? = nil) -> Self {
        backgroundView = GradientView(colors: colors, degree: degree, locations: locations)
        insertSubview(backgroundView!, at: 0)
        backgroundView?.fillSuperview()
        return self
    }
}

open class VStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 0, _ subviews: UIView...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.__view.axis = .vertical
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 0, _ subviews: UIView...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.__view.axis = .horizontal
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Stack:View {
    var __view:UIStackView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView:UIStackView = newValue as? UIStackView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    var backgroundView:UIView?
    
    public init(alignment:UIStackView.Alignment = .center, spacing:CGFloat, subviews:[UIView]) {
        __view = UIStackView()
        super.init()
        
        __view.alignment = alignment
        __view.distribution = .fill
        __view.spacing = spacing
        _init()
        subviews.forEach{
            __view.addArrangedSubview($0)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func background(_ color:UIColor) -> Self {
        backgroundView = UIView()
        backgroundView?.backgroundColor = color
        insertSubview(backgroundView!, at: 0)
        backgroundView?.fillSuperview()
        return self
    }
    
    public func background(_ colors:[UIColor], degree:Double? = nil, locations:[NSNumber]? = nil) -> Self {
        backgroundView = GradientView(colors: colors, degree: degree, locations: locations)
        insertSubview(backgroundView!, at: 0)
        backgroundView?.fillSuperview()
        return self
    }
    
    public func background(_ colors$:Observable<[UIColor]>, degree$:Observable<Double>, locations:[NSNumber]? = nil) -> Self {
        backgroundView = GradientView(colors$: colors$, degree$: degree$, locations: locations)
        insertSubview(backgroundView!, at: 0)
        backgroundView?.fillSuperview()
        return self
    }
    
    override internal func layoutClipShape(_ clipShape: Shape) {
        let path:UIBezierPath = clipShape.getPath(self)
        let layer:CAShapeLayer = .init()
         layer.path = path.cgPath
         layer.frame = self.bounds
        backgroundView?.layer.mask = layer
     }
    
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        __view.isLayoutMarginsRelativeArrangement = true
        __view.layoutMargins = insets
        return self
    }
    
    public func distribution(_ type:UIStackView.Distribution) -> Self {
        __view.distribution = type
        return self
    }
}

open class Spacer:View {
    public init(axis:NSLayoutConstraint.Axis = .horizontal) {
        super.init()
        _view = UIView()
        _view.setContentHuggingPriority(.defaultLow, for: axis)
        _view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
