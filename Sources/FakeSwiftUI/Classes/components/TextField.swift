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
    let textInputView = TextInput()
    
    public init(_ placeholder:String, text:BehaviorRelay<String?>, limit:Int? = nil, onEditingChange:@escaping(_ editing:Bool) -> () = { _ in } , onCommit: @escaping () -> Void = {}) {
        super.init()
        textInputView.placeholder = placeholder
            textInputView.autocapitalizationType = .none

        textInputView.translatesAutoresizingMaskIntoConstraints = false
        textInputView.append(to: self).fillSuperview()
        if let limit = limit {
            text ~> textInputView.rx.text ~ disposeBag
            textInputView.rx.text.compactMap{ $0 }.map{ "\($0.prefix(limit))" } ~> text ~ disposeBag
        } else {
            text <~> textInputView.rx.text ~ disposeBag
        }
        
        textInputView.rx.controlEvent([.editingChanged]).subscribe(onNext:{
            onEditingChange(true)
        }) ~ disposeBag
        
        textInputView.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext:{
            onCommit()
        }) ~ disposeBag
    }
    
//    public override init (){
//        super.init()
//        _init()
//    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        textInputView.padding(insets)
        return self
    }
    
    @discardableResult
    public func onEditingDidBegin(_ callback:@escaping() -> ()) -> Self {
        textInputView.rx.controlEvent([.editingDidBegin])
            .subscribe(onNext:{ _ in
                callback()
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func onEditingDidEnd(_ callback:@escaping() -> ()) -> Self {
        textInputView.rx.controlEvent([.editingDidEnd])
            .subscribe(onNext:{ _ in
                callback()
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func inputView(_ inputView:UIView) -> Self {
        textInputView.inputView = inputView
        return self
    }
    
    @discardableResult
    public func inputView(_ inputView$:Observable<UIView?>) -> Self {
        inputView$.subscribe(onNext:{[weak self] in
            guard let self = self else { return }
            self.textInputView.inputView = $0
            self.textInputView.reloadInputViews()
            self.textInputView.becomeFirstResponder()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func placeholder(_ stream$:Observable<String?>) -> Self {
        stream$.asDriver(onErrorJustReturn: nil).drive(onNext:{[weak self] in
            self?.textInputView.placeholder = $0
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func tintColor(_ color:UIColor) -> Self {
        self.textInputView.tintColor = color
        return self
    }
}
