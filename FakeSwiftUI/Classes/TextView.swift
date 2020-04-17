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
import PromiseKit
import AwaitKit

open class TextView:View {
    lazy var __view = self._view as! UITextView

    public init(_ text$:BehaviorRelay<String?>, placeholder:Observable<String?>, limit:Int? = nil) {
        super.init()
        _view = UITextView()
        _init()
        let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .lightGray
        __view.addSubview(placeholderLabel)
        placeholderLabel.fillSuperview()
        
        __view.setValue(placeholderLabel, forKey: "_placeholderLabel")
        placeholder ~> placeholderLabel.rx.text ~ disposeBag
        
        if let limit = limit {
            text$ ~> __view.rx.text ~ disposeBag
            __view.rx.text.compactMap{ $0 }.map{ "\($0.prefix(limit))" } ~> text$ ~ disposeBag
        } else {
            text$ <~> __view.rx.text ~ disposeBag
        }
    }
    
    public init(_ text$:Observable<String?>) {
        super.init()
        _init()
        text$ ~> __view.rx.text ~ disposeBag
    }
    
    public convenience init(_ text:String) {
        self.init()
        self.__view.text = text
    }
    
    public convenience init(_ attributedText:NSAttributedString) {
        self.init()
        self.__view.attributedText = attributedText
    }
    
    public override init (){
        super.init()
        _view = UITextView()
        _init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func editable(_ editable:Bool) -> Self {
        __view.isEditable = editable
        return self
    }
    
    public func scrollable(_ scrollable:Bool) -> Self {
        __view.isScrollEnabled = scrollable
        return self
    }
    
    public func alignment(_ alignment:NSTextAlignment) -> Self {
        __view.textAlignment = alignment
        return self
    }
    
    public func color(_ color:UIColor) -> Self {
        __view.textColor = color
        return self
    }
    
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
}
