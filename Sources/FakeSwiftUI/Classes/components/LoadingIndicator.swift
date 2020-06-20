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
    let indicatorView = UIActivityIndicatorView()
    
    public init(_ isAnimating:Observable<Bool>, style:UIActivityIndicatorView.Style){
        super.init()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.append(to: self).fillSuperview()
        indicatorView.style = style
        indicatorView.hidesWhenStopped = true
        isAnimating.asDriver(onErrorJustReturn: false) ~> indicatorView.rx.isAnimating ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
