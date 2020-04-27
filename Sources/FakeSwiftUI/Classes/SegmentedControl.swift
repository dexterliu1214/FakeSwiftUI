//
//  SegmentedControl.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/15.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture

open class SegmentedControl:View
{
    lazy var __view = self._view as! UISegmentedControl
    
    public init(_ items:[Any], defaultIndex:Int = 0) {        
        super.init()
        _view = UISegmentedControl(items: items)
        __view.selectedSegmentIndex = defaultIndex
        _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func onChange(_ callback:@escaping (Int) -> ()) -> Self {
        __view.rx.value.subscribe(onNext:{
            callback($0)
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func font(_ size:CGFloat) -> Self {
        __view.backgroundColor = 0x4F3D6A.color
        __view.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: size), .foregroundColor: UIColor.white ], for: .normal)
        if #available(iOS 13.0, *) {
            __view.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.4)
        } else {
            __view.tintColor = .clear
            __view.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: size), .foregroundColor: UIColor.white, .backgroundColor: UIColor.white.withAlphaComponent(0.4) ], for: .selected)
        }
        return self
    }
}
