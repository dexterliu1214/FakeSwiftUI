//
//  InputBar.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/21.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import InputBarAccessoryView
import RxCocoa
import RxSwift
import RxBinding
import ISEmojiView

open class InputBar:View {
    var __view:InputBarAccessoryView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? InputBarAccessoryView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(_ text$:BehaviorRelay<String?>) {
        __view = InputBarAccessoryView()
        super.init()
        _init()
        
        let maxChar = 150

        text$ ~> __view.inputTextView.rx.text ~ disposeBag
        __view.inputTextView.rx.text.compactMap{ $0 }.map{ "\($0.prefix(maxChar))" } ~> text$ ~ disposeBag
        
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        
        let buttonSize:CGFloat = 36
        let emojiButton = InputBarButtonItem()
        emojiButton.setSize(CGSize(width: buttonSize, height: buttonSize), animated: false)
        emojiButton.setIcon(icon: .googleMaterialDesign(.insertEmoticon), iconSize: buttonSize, color: .black, backgroundColor: .clear, forState: .normal)
        __view.separatorLine.height = 0
        
        let wordCounter = InputBarButtonItem()
        let wordLimitHint$ = text$.compactMap{ $0 }.map{ "\($0.count)/\(maxChar)" }
        wordLimitHint$ ~> wordCounter.rx.title() ~ disposeBag
        text$.compactMap{ $0 }.map{ $0.count >= maxChar ? UIColor.red : .black } ~> wordCounter.rx.titleColor() ~ disposeBag

        wordCounter.setTitleColor(.black, for: .normal)
        
        __view.setRightStackViewWidthConstant(to: 36 + 65, animated: false)
        __view.setStackViewItems([wordCounter, emojiButton], forStack: .right, animated: false)
        
        emojiButton.rx.tap.asDriver()
            .drive(onNext:{[weak self] in
                guard let self = self else { return }
                if self.__view.inputTextView.inputView == nil {
                    self.__view.inputTextView.inputView = emojiView
                } else {
                    self.__view.inputTextView.inputView = nil
                }
                self.__view.inputTextView.reloadInputViews()
                self.__view.inputTextView.becomeFirstResponder()
            }) ~ disposeBag
        
        __view.inputTextView.rx.didEndEditing.asDriver()
            .drive(onNext:{[weak self] in
                self?.__view.inputTextView.inputView = nil
            }) ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func placeholder(_ text$:Observable<String>) -> Self {
        text$.asDriver(onErrorJustReturn: "?").drive(onNext:{[weak self] in
            self?.__view.inputTextView.placeholder = $0
        }) ~ disposeBag
        return self
    }
}

extension InputBar:EmojiViewDelegate
{
    public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        __view.inputTextView.insertText(emoji)
    }

    public func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        __view.inputTextView.inputView = nil
        __view.inputTextView.keyboardType = .default
        __view.reloadInputViews()
    }
        
    public func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        __view.inputTextView.deleteBackward()
    }

    public func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        __view.resignFirstResponder()
    }
}
