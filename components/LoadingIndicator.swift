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
    let indicatorView:UIActivityIndicatorView
    
    public init(_ isAnimate$:Observable<Bool>, style:UIActivityIndicatorView.Style){
        indicatorView = UIActivityIndicatorView()
        super.init()
        view = indicatorView
        indicatorView.style = style
        isAnimate$.asDriver(onErrorJustReturn: false).drive(indicatorView.rx.isAnimating) ~ disposeBag
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
