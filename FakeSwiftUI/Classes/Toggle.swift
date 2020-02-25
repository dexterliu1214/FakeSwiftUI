//
//  Toggle.swift
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

open class Toggle:View
{
    var __view:UISwitch
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? UISwitch {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(isOn:BehaviorRelay<Bool>){
        __view = UISwitch()
        super.init()
        _init()
        isOn <~> __view.rx.isOn  ~ disposeBag
    }
    
    public init(isOn:BehaviorRelay<Bool>, _ subview:UIView){
        __view = UISwitch()
        super.init()
        isOn <~> __view.rx.isOn  ~ disposeBag
        __view.translatesAutoresizingMaskIntoConstraints = false
        HStack(
            subview,
            __view
        ).fill().on(self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func enabled(_ stream$:Observable<Bool>) -> Self {
        stream$.asDriver(onErrorJustReturn: true) ~> __view.rx.isEnabled ~ disposeBag
        return self
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        __view.onTintColor = color
        return self
    }
}

import Lottie
open class AnimatedToggle:View
{
    var __view:AnimatedSwitch
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? AnimatedSwitch {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(isOn:Observable<Bool>, animation:Animation, _ action:@escaping(AnimatedSwitch) -> ()){
        __view = AnimatedSwitch(animation: animation)
        super.init()
        isOn.asDriver(onErrorJustReturn: false).drive(__view.rx.isOn) ~ disposeBag
        __view.rx.tapGesture().when(.recognized).subscribe(onNext:{[weak self] _ in
            guard let self = self else { return }
            action(self.__view)
        }) ~ disposeBag
        _init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func enabled(_ stream$:Observable<Bool>) -> Self {
        stream$.asDriver(onErrorJustReturn: true) ~> __view.rx.isEnabled ~ disposeBag
        return self
    }
    
    @discardableResult
    public func disabled(_ stream$:Observable<Bool>) -> Self {
        stream$.asDriver(onErrorJustReturn: true) ~> __view.rx.isDisabled ~ disposeBag
        return self
    }
}

extension Reactive where Base: AnimatedSwitch {
    public var isOn: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.setIsOn(value, animated: true)
        }
    }
    
    public var isDisabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = !value
        }
    }
}
