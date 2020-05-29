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

class GradientTextDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let degree$ = Observable<Int>.timer(.seconds(1), period: .milliseconds(5), scheduler: MainScheduler.instance)
            .map{ Double($0).truncatingRemainder(dividingBy: 360.0) }
        
        ZStack(
            View()
                .mask(
                    Text("FakeSwiftUI Rocks")
                        
                        .font(40)
                        .padding(.symmetric(4, 16))
            )
                .background([UIColor.red, .blue], degree$: degree$)
                .fill()
        )
            .background(.black)
            .clipShape(Circle())
            .overlay(Circle().stroke([.green, .yellow], degree$: degree$, lineWidth: 4))
            .centerX(offset: 0)
            .centerY(offset: 0)
            .on(view)
    }
}

