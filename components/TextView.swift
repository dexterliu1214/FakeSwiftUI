//
//  TextView.swift
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

extension TextView:UITextViewDelegate
{
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            submitCallback?(self.__view.text)
        }
        return true
    }
}

open class TextView:View {
    let __view = UITextView()
    var submitCallback:((_ text:String) -> ())?
    var text$:BehaviorRelay<String?>? = nil
    
    public init(_ text$:BehaviorRelay<String?>) {
        self.text$ = text$
        super.init()
        __view.delegate = self
        _view = __view
        _init()
        __view.backgroundColor = .clear
        text$ <~> __view.rx.text ~ disposeBag
    }
    
    public init(_ text$:Observable<String?>) {
        super.init()
        _view = __view
        _init()
        __view.backgroundColor = .clear
        text$ ~> __view.rx.text ~ disposeBag
    }
    
    public init(_ text:String) {
        super.init()
        _view = __view
        _init()
        __view.backgroundColor = .clear
        self.__view.text = text
    }
    
    public init(_ attributedText:NSAttributedString) {
        super.init()
        _view = __view
        _init()
        __view.backgroundColor = .clear
        self.__view.attributedText = attributedText
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func placeholder(_ text$:Observable<String?>) -> Self {
        let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .lightGray
        __view.addSubview(placeholderLabel)
        placeholderLabel.fillSuperview()
        
        __view.setValue(placeholderLabel, forKey: "_placeholderLabel")
        text$ ~> placeholderLabel.rx.text ~ disposeBag
        return self
    }
    
    @discardableResult
    public func placeholder(_ text:String) -> Self {
        return self.placeholder(Observable.just(text))
    }
    
    @discardableResult
    public func limit(_ limit:Int) -> Self {
        guard let text$ = self.text$ else { return self }
        __view.rx.text.compactMap{ $0 }.map{ "\($0.prefix(limit))" } ~> text$ ~ disposeBag
        return self
    }
    
    @discardableResult
    public func editable(_ editable:Bool) -> Self {
        __view.isEditable = editable
        return self
    }
    
    @discardableResult
    public func scrollable(_ scrollable:Bool) -> Self {
        __view.isScrollEnabled = scrollable
        return self
    }
    
    @discardableResult
    public func alignment(_ alignment:NSTextAlignment) -> Self {
        __view.textAlignment = alignment
        return self
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        self.color(Observable.just(color))
        return self
    }
    
    @discardableResult
    public func color(_ color$:Observable<UIColor>) -> Self {
        color$ ~> __view.rx.textColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func font(_ size:CGFloat) -> Self {
        __view.font = UIFont.systemFont(ofSize: size)
        return self
    }
    
    @discardableResult
    public func inputView(_ inputView$:Observable<UIView?>) -> Self {
        inputView$.subscribe(onNext:{[weak self] in
            guard let self = self else { return }
            self.__view.inputView = $0
            self.__view.reloadInputViews()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func inputAccessoryView(_ view:UIView?) -> Self {
        self.__view.inputAccessoryView = view
        self.__view.reloadInputViews()
        return self
    }
    
    @discardableResult
    public func padding(_ padding:UIEdgeInsets = .all(8)) -> Self {
        self.__view.textContainerInset = padding
        return self
    }
    
    @discardableResult
    public func insert(_ text$:Observable<String>) -> Self {
        text$.subscribe(onNext:{[weak self] in
            self?.__view.insertText($0)
        }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func deleteBackword(_ event$:Observable<()>) -> Self {
        event$.subscribe(onNext:{[weak self] in
            self?.__view.deleteBackward()
        }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func returnType(_ type:UIReturnKeyType) -> Self {
        self.__view.returnKeyType = type
        return self
    }
    
    @discardableResult
    public func onSubmit(_ callback:@escaping(_ text:String) -> ()) -> Self {
        submitCallback = callback
        return self
    }
}

extension Reactive where Base: UITextView {
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { control, value in
            control.textColor = value
        }
    }
}
