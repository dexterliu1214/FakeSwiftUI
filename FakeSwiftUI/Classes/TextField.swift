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

open class TextField:View
{
    var __view:TextInput = .init()
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
    
    
    public init(_ placeholder:String, text:BehaviorRelay<String?>, limit:Int? = nil, onEditingChange:@escaping(_ editing:Bool) -> () = { _ in } , onCommit: @escaping () -> Void = {}) {
        
        __view.placeholder = placeholder
        __view.autocapitalizationType = .none
        super.init()

        _init()
        if let limit = limit {
            text ~> __view.rx.text ~ disposeBag
            __view.rx.text.compactMap{ $0 }.map{ "\($0.prefix(limit))" } ~> text ~ disposeBag
        } else {
            text <~> __view.rx.text ~ disposeBag
        }
        
        __view.rx.controlEvent([.editingDidEnd]).subscribe(onNext:{[weak self] in
            self?.__view.inputView = nil
        }) ~ disposeBag
        
        __view.rx.controlEvent([.editingChanged]).subscribe(onNext:{
            onEditingChange(true)
        }) ~ disposeBag
        
        __view.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext:{
            onCommit()
        }) ~ disposeBag
    }
    public override init (){
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
    
    @discardableResult
    public func inputView(_ inputView$:Observable<UIView?>) -> Self {
        inputView$.subscribe(onNext:{[weak self] in
            guard let self = self else { return }
            self.__view.inputView = $0
            self.__view.reloadInputViews()
            self.__view.becomeFirstResponder()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func placeholder(_ stream$:Observable<String?>) -> Self {
        stream$.asDriver(onErrorJustReturn: nil).drive(onNext:{[weak self] in
            self?.__view.placeholder = $0
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func tintColor(_ color:UIColor) -> Self {
        self.__view.tintColor = color
        return self
    }
}
