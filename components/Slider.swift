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

open class Slider:View
{
    let slider = UISlider()

    public init(_ value$:BehaviorRelay<Float>, min:Float = 0.0, max:Float = 100.0, step:Float = 1.0) {
        super.init()
        view = slider
        slider.minimumValue = min
        slider.maximumValue = max
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        value$ ~> slider.rx.value ~ disposeBag
        slider.rx.value.map{ round($0/step) * step } ~> value$ ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        slider.tintColor = color
        return self
    }
    
    @discardableResult
    public func onDrag(_ callback:@escaping(Float) -> ()) -> Self {
        slider.rx.value.subscribe(onNext:{
            callback($0)
        }) ~ disposeBag
        return self
    }
}
