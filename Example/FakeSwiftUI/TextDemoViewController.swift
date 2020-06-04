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

#if targetEnvironment(simulator)
import SwiftUI
@available(iOS 13.0.0, *)
struct TextDemoViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            TextDemoViewController()
        }            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
    }
}
#endif

class TextDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Text("FakeSwiftUI Rocks")
            .font(40)
            .clipShape(Circle())
            .overlay(Circle().stroke([.blue, .yellow], lineWidth: 4))
            .padding(.symmetric(4, 16))
            .background([UIColor.red, .blue])
            .centerX(offset: 0)
            .centerY(offset: 0)
//            .top(offset: 0)
            .blur()
            .on(view)
    }
}
