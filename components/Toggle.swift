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
        view = switchView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
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
}

