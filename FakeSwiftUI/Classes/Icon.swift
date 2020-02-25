//
//  Icon.swift
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
import SwiftIcons

open class Icon:View
{
    var __view:Label
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? Label {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    var icon:FontType
    var size:CGFloat?

    public init(_ icon:FontType, size:CGFloat? = nil, color:UIColor = .black, bgColor:UIColor = .clear) {
        self.icon = icon
        self.size = size
        __view = Label()

        super.init()
        
        _init()
        __view.setIcon(icon: icon, iconSize: size ?? UIFont.systemFontSize, color:color, bgColor:bgColor)
    }
    
    public convenience init(_ icon$:Observable<FontType>, size:CGFloat? = nil, color:UIColor = .black, bgColor:UIColor = .clear) {
        self.init(FontType.googleMaterialDesign(.accessAlarm), size:size, color:color, bgColor:bgColor)
        icon$.asDriver(onErrorJustReturn: FontType.googleMaterialDesign(.error)).drive(onNext:{[weak self] in
            self?.__view.setIcon(icon: $0, iconSize: size ?? UIFont.systemFontSize, color:color, bgColor:bgColor)
        }) ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func color(_ color:UIColor) -> Self {
        __view.textColor = color
        return self
    }
    
    public func color(_ color$:Observable<UIColor>) -> Self {
        color$.asDriver(onErrorJustReturn: .red) ~> __view.rx.textColor ~ disposeBag
        return self
    }
    
    public func padding(_ padding:UIEdgeInsets = .all(8)) -> Self {
        __view.padding(padding)
        return self
    }
}
