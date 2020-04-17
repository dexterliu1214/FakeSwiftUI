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

open class LoadingIndicator:View
{
    lazy var __view = self._view as! UIActivityIndicatorView
    
    public init(_ isAnimate$:Observable<Bool>, style:UIActivityIndicatorView.Style){        
        super.init()
        _view = UIActivityIndicatorView()
        __view.style = style
        isAnimate$.asDriver(onErrorJustReturn: false).drive(__view.rx.isAnimating) ~ disposeBag
       _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
