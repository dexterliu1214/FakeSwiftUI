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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Text("FakeSwiftUI Rocks")
            .font(50)
            .clipShape(Circle())
            .overlay(Circle().stroke([.blue, .yellow], lineWidth: 3))
            .padding(.symmetric(4, 16))
            .background([UIColor.red, .blue])
            .centerX(offset: 0)
            .centerY(offset: 0)
            .on(view)
    }
}

