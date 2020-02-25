//
//  TextField.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/16.
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

open class TextInput: UITextField {

    var insets: UIEdgeInsets = .all(0)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets) -> Self {
        self.insets = insets
        return self
    }
}

class TextField:View
{
    var __view:TextInput
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? TextInput {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    
    public convenience init(_ placeholder:String, text:BehaviorRelay<String?>, onEditingChange:@escaping(_ editing:Bool) -> () = { _ in } , onCommit: @escaping () -> Void = {}) {
        self.init()
        __view.placeholder = placeholder
        
        text <~> __view.rx.text ~ disposeBag
        __view.rx.controlEvent([.editingChanged]).subscribe(onNext:{
            onEditingChange(true)
        }) ~ disposeBag
        
        __view.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext:{
            onCommit()
        }) ~ disposeBag
    }
    public override init (){
        __view = TextInput()
        super.init()
        _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        __view.padding(insets)
        return self
    }
    
    @discardableResult
    public func onEditingDidBegin(_ callback:@escaping() -> ()) -> Self {
        __view.rx.controlEvent([.editingDidBegin])
            .subscribe(onNext:{ _ in
                callback()
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func onEditingDidEnd(_ callback:@escaping() -> ()) -> Self {
        __view.rx.controlEvent([.editingDidEnd])
            .subscribe(onNext:{ _ in
                callback()
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func inputView(_ inputView:UIView) -> Self {
        __view.inputView = inputView
        return self
    }
}
