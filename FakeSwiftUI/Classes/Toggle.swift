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
    lazy var __view = self._view as! UISwitch
    
    public init(isOn:BehaviorRelay<Bool>){
        super.init()
        _view = UISwitch()
        _init()
        isOn <~> __view.rx.isOn  ~ disposeBag
    }
    
    public init(isOn:BehaviorRelay<Bool>, _ subview:UIView){
        super.init()
        _view = UISwitch()
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

