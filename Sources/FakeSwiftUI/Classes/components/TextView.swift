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
            submitCallback?(self.textView.text)
        }
        return true
    }
}

open class TextView:View {
    let textView = UITextView()
    var submitCallback:((_ text:String) -> ())?
    var text$:BehaviorRelay<String?>? = nil
    
    public init(_ text$:BehaviorRelay<String?>) {
        self.text$ = text$
        super.init()
        textView.delegate = self
        view = textView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        textView.backgroundColor = .clear
        text$ <~> textView.rx.text ~ disposeBag
    }
    
    public init(_ text$:Observable<String?>) {
        super.init()
        view = textView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        textView.backgroundColor = .clear
        text$ ~> textView.rx.text ~ disposeBag
    }
    
    public init(_ text:String) {
        super.init()
        view = textView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        textView.backgroundColor = .clear
        self.textView.text = text
    }
    
    public init(_ attributedText:NSAttributedString) {
        super.init()
        view = textView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        textView.backgroundColor = .clear
        self.textView.attributedText = attributedText
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
        textView.addSubview(placeholderLabel)
        placeholderLabel.fillSuperview()
        
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
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
        textView.rx.text.compactMap{ $0 }.map{ "\($0.prefix(limit))" } ~> text$ ~ disposeBag
        return self
    }
    
    @discardableResult
    public func editable(_ editable:Bool) -> Self {
        textView.isEditable = editable
        return self
    }
    
    @discardableResult
    public func scrollable(_ scrollable:Bool) -> Self {
        textView.isScrollEnabled = scrollable
        return self
    }
    
    @discardableResult
    public func alignment(_ alignment:NSTextAlignment) -> Self {
        textView.textAlignment = alignment
        return self
    }
    
    @discardableResult
    public func color(_ color:UIColor) -> Self {
        self.color(Observable.just(color))
        return self
    }
    
    @discardableResult
    public func color(_ color$:Observable<UIColor>) -> Self {
        color$ ~> textView.rx.textColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func font(_ size:CGFloat) -> Self {
        textView.font = UIFont.systemFont(ofSize: size)
        return self
    }
    
    @discardableResult
    public func inputView(_ inputView$:Observable<UIView?>) -> Self {
        inputView$.subscribe(onNext:{[weak self] in
            guard let self = self else { return }
            self.textView.inputView = $0
            self.textView.reloadInputViews()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func inputAccessoryView(_ view:UIView?) -> Self {
        self.textView.inputAccessoryView = view
        self.textView.reloadInputViews()
        return self
    }
    
    @discardableResult
    public func padding(_ padding:UIEdgeInsets = .all(8)) -> Self {
        self.textView.textContainerInset = padding
        return self
    }
    
    @discardableResult
    public func insert(_ text$:Observable<String>) -> Self {
        text$.subscribe(onNext:{[weak self] in
            self?.textView.insertText($0)
        }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func deleteBackword(_ event$:Observable<()>) -> Self {
        event$.subscribe(onNext:{[weak self] in
            self?.textView.deleteBackward()
        }) ~ disposeBag
        
        return self
    }
    
    @discardableResult
    public func returnType(_ type:UIReturnKeyType) -> Self {
        self.textView.returnKeyType = type
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