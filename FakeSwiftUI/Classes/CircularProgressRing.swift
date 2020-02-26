//
//  CircularProgress.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/8.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture
import PromiseKit
import AwaitKit
import UICircularProgressRing

open class CircularProgressRing:View
{
    var __view:UICircularProgressRing
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView:UICircularProgressRing = newValue as? UICircularProgressRing {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(value$:Observable<CGFloat>, maxValue$:Observable<CGFloat>) {
        __view = UICircularProgressRing()
        super.init()
        
        __view.delegate = self
        value$.subscribe(onNext:{[weak self] in
            self?.__view.value = $0
        }) ~ disposeBag
        
        maxValue$.subscribe(onNext:{[weak self] in
            self?.__view.maxValue = $0
        }) ~ disposeBag
        
        __view.style = UICircularRingStyle.ontop
        __view.startAngle = 270
        __view.endAngle = 270
        __view.innerRingColor = .orange
        __view.innerRingWidth = __view.outerRingWidth
        __view.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        _init()
   }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CircularProgressRing:UICircularProgressRingDelegate
{
    public func willDisplayLabel(for ring: UICircularProgressRing, _ label: UILabel) {
        label.text = "\(ring.value.int) / \(ring.maxValue.int)"
    }
    
    public func didFinishProgress(for ring: UICircularProgressRing) {
            
    }
    
    public func didPauseProgress(for ring: UICircularProgressRing) {
        
    }
    
    public func didContinueProgress(for ring: UICircularProgressRing) {
        
    }
    
    public func didUpdateProgressValue(for ring: UICircularProgressRing, to newValue: CGFloat) {
        
    }
}
