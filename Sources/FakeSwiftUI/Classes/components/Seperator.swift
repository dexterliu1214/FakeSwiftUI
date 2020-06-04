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

open class Seperator:View {
    public override init() {
        super.init()
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
