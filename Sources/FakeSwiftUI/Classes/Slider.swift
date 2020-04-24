//
//  Slider.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/10.
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

open class Slider:View
{
    lazy var __view = self._view as! UISlider

    public init(_ value$:BehaviorRelay<Float>, min:Float = 0.0, max:Float = 100.0, step:Float = 1.0) {
        super.init()
        _view = UISlider()
        __view.minimumValue = min
        __view.maximumValue = max
        _init()
        value$ ~> __view.rx.value ~ disposeBag
        __view.rx.value.map{ round($0/step) * step } ~> value$ ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        __view.tintColor = color
        return self
    }
    
    @discardableResult
    public func onDrag(_ callback:@escaping(Float) -> ()) -> Self {
        __view.rx.value.subscribe(onNext:{
            callback($0)
        }) ~ disposeBag
        return self
    }
}
