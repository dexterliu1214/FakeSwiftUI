//
//  Picker.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/2/12.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture
import RxDataSources

open class Select:View
{
    public init<T>(_ subject:BehaviorRelay<(String, T?)>, options:Observable<[(String,T?)]>, placeholder:String = "") {
        super.init()
        let pickerView = UIPickerView()
        
        options
            .bind(to: pickerView.rx.itemTitles) { row, item in
                return item.0
            } ~ disposeBag
        
        let text$ = BehaviorRelay<String?>(value:nil)
        
        pickerView.rx.modelSelected((String,T?).self)
            .map{ $0.first?.0 } ~> text$ ~ disposeBag
        
        pickerView.rx.modelSelected((String,T?).self)
            .map{ $0.first! } ~> subject ~ disposeBag
        
        subject.map{ $0.0 } ~> text$ ~ disposeBag
        subject.subscribe(onNext:{
            if $0.1 == nil {
                pickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }) ~ disposeBag
        
        _view =
            HStack(
                TextField(placeholder, text:text$)
                    .inputView(pickerView)
                    .padding(),
                Icon(.googleMaterialDesign(.arrowDropDown))
            )
                .background(0xF8F8F8.color)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(0xC7C7C7.color, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

