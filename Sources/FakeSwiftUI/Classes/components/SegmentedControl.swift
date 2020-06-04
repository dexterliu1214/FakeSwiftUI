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
    let segmentedControl:UISegmentedControl
    
    public init(_ items:[Any], defaultIndex:Int = 0) {
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = defaultIndex

        super.init()
        view = segmentedControl
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func onChange(_ callback:@escaping (Int) -> ()) -> Self {
        segmentedControl.rx.value.subscribe(onNext:{
            callback($0)
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func font(_ size:CGFloat) -> Self {
        segmentedControl.backgroundColor = 0x4F3D6A.color
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), .foregroundColor: UIColor.white ], for: .normal)
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.4)
        } else {
            segmentedControl.tintColor = .clear
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), .foregroundColor: UIColor.white, .backgroundColor: UIColor.white.withAlphaComponent(0.4) ], for: .selected)
        }
        return self
    }
}
