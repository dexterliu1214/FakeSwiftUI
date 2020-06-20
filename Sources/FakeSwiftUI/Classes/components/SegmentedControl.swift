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
    var attributes = [NSAttributedString.Key:Any]()
    var selectedAttributes = [NSAttributedString.Key:Any]()

    public init(_ items:[Any]?, defaultIndex:Int = 0) {
        segmentedControl = UISegmentedControl(items: items)
        super.init()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.append(to: self).fillSuperview()
        
        segmentedControl.selectedSegmentIndex = defaultIndex
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
        attributes[.font] = UIFont.systemFont(ofSize: size)
        self.updateTitleAttributes()
        return self
    }
    
    var textColor:UIColor = .black
    @discardableResult
    public func textColor(_ color:UIColor) -> Self {
        attributes[.foregroundColor] = color
        self.updateTitleAttributes()
        return self
    }
    
    func updateTitleAttributes(){
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    }
    
    public func tintColor(_ color:UIColor) -> Self {
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = color
        } else {
            segmentedControl.tintColor = .clear
            selectedAttributes[.backgroundColor] = color
            selectedAttributes.merge(attributes, uniquingKeysWith: { (_, new) in new })
            segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        }
        return self
    }
}
