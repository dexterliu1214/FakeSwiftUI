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
        }
    }
}
#endif

class TextDemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Scrollable(
            VStack(
               
            )
//                .centerX(offset: 0)
//                .top(offset: 0)
//                .bottom(offset: 0)
            .fill()
        )
            .fill().on(view)
    }
}
