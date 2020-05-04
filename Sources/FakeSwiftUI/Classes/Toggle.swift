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

open class Toggle:View
{
    let __view = UISwitch()
    
    public init(isOn:BehaviorRelay<Bool>){
        super.init()
        _view = __view
        _init()
        isOn <~> __view.rx.isOn ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        __view.onTintColor = color
        return self
    }
}

