//
//  LoadingIndicator.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/12/31.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBinding
import UIKit

open class LoadingIndicator:View
{
    let __view:UIActivityIndicatorView
    
    public init(_ isAnimate$:Observable<Bool>, style:UIActivityIndicatorView.Style){
        __view = UIActivityIndicatorView()
        super.init()
        _view = __view
        __view.style = style
        isAnimate$.asDriver(onErrorJustReturn: false).drive(__view.rx.isAnimating) ~ disposeBag
       _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
