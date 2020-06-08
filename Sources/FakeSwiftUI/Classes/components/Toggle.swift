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
    let labelText:Text
    
    public init(_ label:String, isOn:BehaviorRelay<Bool>){
        self.labelText = Text(label)
        
        super.init()
       
        view = HStack(
            labelText,
            switchView
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        isOn <~> switchView.rx.isOn ~ disposeBag
       
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func accentColor(_ color: UIColor) -> Self {
        self.labelText.color(color)
        return self
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        switchView.onTintColor = color
        return self
    }
}
