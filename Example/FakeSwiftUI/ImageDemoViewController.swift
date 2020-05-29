//
//  ViewController.swift
//  FakeSwiftUI
//
//  Created by youga on 02/24/2020.
//  Copyright (c) 2020 youga. All rights reserved.
//

import UIKit
import FakeSwiftUI
import RxSwift
import RxRelay

class ImageDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        ZStack(
            Image(Observable.just("https://placeimg.com/640/480/any"))
                .aspectRatio(contentMode: .scaleAspectFill)
                .clipShape(Circle())
                .overlay(Circle().stroke([.green, .yellow], lineWidth: 4))
                .shadow(color: .black, radius: 10)
                .fill()
        )
            .frame(width: 200, height: 200)
            .shadow(radius: 10)
            .centerX(offset: 0)
            .centerY(offset: 0)
            .on(view)
    }
}

