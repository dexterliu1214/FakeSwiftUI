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
    let switchView = UISwitch()
    
    public init(isOn:BehaviorRelay<Bool>){
        super.init()
       
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.append(to: self).fillSuperview()
        isOn <~> switchView.rx.isOn ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        switchView.onTintColor = color
        return self
    }
    
    @discardableResult
    public func thumbTintColor(_ color$:Observable<UIColor>) -> Self {
        color$ ~> switchView.rx.thumbTintColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func thumbTintColor(_ color:UIColor) -> Self {
        self.thumbTintColor(Observable.just(color))
        return self
    }
}

extension Reactive where Base: UISwitch {
    public var thumbTintColor: Binder<UIColor> {
        return Binder(self.base) { control, value in
            control.thumbTintColor = value
        }
    }
}
