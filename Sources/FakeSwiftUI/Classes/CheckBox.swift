//
//  FakeSwiftUI.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/2.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture

open class CheckBox:View {
    
    public init(_ isChecked$:BehaviorRelay<Bool>, checkIcon:FontType = FontType.googleMaterialDesign(.checkBox), uncheckIcon:FontType = .googleMaterialDesign(.checkBoxOutlineBlank), text:String) {
        
        super.init()
        
        let checkIcon$:BehaviorRelay<FontType> = .init(value:isChecked$.value ? checkIcon : uncheckIcon)
        
        _view = HStack(
            Icon(checkIcon$.asObservable(), size: 20, color:.green),
            Text(text)
        ).onTap{ _ in
            isChecked$.accept(!isChecked$.value)
        }
        
        isChecked$.subscribe(onNext:{
            if $0 {
                checkIcon$.accept(checkIcon)
            } else {
                checkIcon$.accept(uncheckIcon)
            }
        }) ~ disposeBag
       
        _init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
