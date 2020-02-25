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
import ISEmojiView

open class TextView:View {
    var __view:UITextView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? UITextView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
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
        __view = UITextView()
        super.init()
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
    public func toggleEmojiView(_ value$:BehaviorRelay<Bool>) -> Self {
        value$.subscribe(onNext:{[weak self] in
            if $0 {
                self?.__view.becomeFirstResponder()
                let keyboardSettings = KeyboardSettings(bottomType: .categories)
                keyboardSettings.needToShowAbcButton = true
                let emojiView = EmojiView(keyboardSettings: keyboardSettings)
                emojiView.translatesAutoresizingMaskIntoConstraints = false
                emojiView.delegate = self
                self?.__view.inputView = emojiView
                self?.__view.reloadInputViews()
            } else {
                self?.__view.becomeFirstResponder()
                self?.__view.inputView = nil
                self?.__view.keyboardType = .default
                self?.__view.reloadInputViews()
            }
        }) ~ disposeBag
        return self
    }
}

extension TextView:EmojiViewDelegate
{
    public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        __view.insertText(emoji)
    }

    public func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        __view.inputView = nil
        __view.keyboardType = .default
        __view.reloadInputViews()
    }
        
    public func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        __view.deleteBackward()
    }

    public func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        __view.resignFirstResponder()
    }
}
