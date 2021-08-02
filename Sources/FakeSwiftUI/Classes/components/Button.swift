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

open class Button:View
{
    let button = UIButton()
    
    public convenience init(_ title:String, _ action:@escaping(Button) -> ()) {
        self.init(.just(title), action)
    }
    
    public convenience init(_ title$:Observable<String>, _ action:@escaping(Button) -> ()) {
        self.init()
        title$ ~> self.button.rx.title(for: .normal) ~ disposeBag
        button.rx.tap
            .subscribe(onNext:{[weak self] _ in
				guard let self = self else { return }
                action(self)
            }) ~ disposeBag
    }
    
    public convenience init(_ title$:Observable<String?>, _ action:@escaping(Button) -> ()) {
        self.init()
        title$ ~> self.button.rx.title(for: .normal) ~ disposeBag
        button.rx.tap
            .subscribe(onNext:{[weak self] _ in
				guard let self = self else { return }
                action(self)
            }) ~ disposeBag
    }
    
    public convenience init(action:@escaping(Button) -> (), viewBuilder:() -> View) {
        self.init()
        
        let view = viewBuilder()
        view.append(to:self).fillSuperview()
        view.rx.tapGesture().when(.recognized)
        .subscribe(onNext:{[weak self] _ in
            guard let self = self else { return }
            action(self)
        }) ~ disposeBag
   }
    
    override public init (){
        super.init()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.append(to: self).fillSuperview()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func image(_ image:UIImage?, for state:UIControl.State = .normal) -> Self {
        button.setImage(image, for: state)
        return self
    }
    
    @discardableResult
    public func color(_ color:UIColor, for state:UIControl.State = .normal) -> Self {
        return self.color(Observable.just(color), for: state)
    }
    
    @discardableResult
    public func color(_ color$:Observable<UIColor>, for state:UIControl.State = .normal) -> Self {
        color$ ~> button.rx.titleColor(for:state) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func disabled(_ value$:Observable<Bool>) -> Self {
        value$ ~> button.rx.isDisabled ~ disposeBag
		value$.map{ $0 ? 0.5 : 1 }.observe(on: MainScheduler.instance).subscribe(onNext:{[weak self] in
			self?.alpha = $0
		}) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func enabled(_ value$:Observable<Bool>) -> Self {
        value$ ~> button.rx.isEnabled ~ disposeBag
        return self
    }
    
    @discardableResult
    public func contentEdgeInsets(_ insets:UIEdgeInsets) -> Self {
        button.contentEdgeInsets = insets
        return self
    }
}

extension Reactive where Base: UIButton {
    public var isDisabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = !value
        }
    }
    
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }
    
    public var backgroundColor:Binder<UIColor> {
        return Binder(self.base) { (control, value) -> () in
            control.backgroundColor = value
        }
    }
    
    public func titleColor(for controlState: UIControl.State = []) -> Binder<UIColor?> {
       return Binder(self.base) { button, color -> Void in
           button.setTitleColor(color, for: controlState)
       }
   }
}
