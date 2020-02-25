//
//  Button.swift
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

open class Button:View
{
    var __view:UIButton
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? UIButton {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public convenience init(_ title:String, _ action:@escaping(Button) -> ()) {
        self.init()
        self.__view.setTitle(title, for: .normal)
        __view.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                action(self)
            }) ~ disposeBag
    }
    
    public convenience init(_ title$:Observable<String>, _ action:@escaping(Button) -> ()) {
        self.init()
        title$ ~> self.__view.rx.title(for: .normal) ~ disposeBag
        __view.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                action(self)
            }) ~ disposeBag
    }
    
    public convenience init(action:@escaping(Button) -> (), label:() -> View) {
        self.init()
        
        let label = label()
        label.append(to:self)
        label.setupConstraint()
        label.rx.tapGesture().when(.recognized)
        .subscribe(onNext:{[unowned self] _ in
            action(self)
        }) ~ disposeBag
   }
    
    override public init (){
        __view = UIButton()
        super.init()
        __view.titleLabel?.adjustsFontSizeToFitWidth = true
        __view.contentEdgeInsets = .all(8)
        _init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func image(_ image:UIImage?, for state:UIControl.State = .normal) -> Self {
        __view.setImage(image, for: state)
        return self
    }
    
    public func color(_ color:UIColor, for state:UIControl.State = .normal) -> Self {
        return self.color(Observable.just(color), for: state)
    }
    
    public func color(_ color$:Observable<UIColor>, for state:UIControl.State = .normal) -> Self {
        color$ ~> __view.rx.titleColor(for:state) ~ disposeBag
        return self
    }
    
    public func disabled(_ value$:Observable<Bool>) -> Self {
        value$ ~> __view.rx.isDisabled ~ disposeBag
        return self
    }
    
    public func enabled(_ value$:Observable<Bool>) -> Self {
        value$ ~> __view.rx.isEnabled ~ disposeBag
        return self
    }
}
