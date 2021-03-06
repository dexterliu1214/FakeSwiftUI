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
struct GradientTextDemoViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            GradientTextDemoViewController()
        }
    }
}
#endif

class GradientTextDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let degree$ = Observable<Int>.timer(.seconds(1), period: .milliseconds(5), scheduler: MainScheduler.instance)
            .map{ Double($0).truncatingRemainder(dividingBy: 360.0) }
        
        ZStack(
            View()
                .mask(
                    Text(.just("FakeSwiftUI Rocks"))
                        .font(40)
                        .padding(.symmetric(4, 16))
            )
                .background(.just([UIColor.red, .blue]), degree$: degree$)
                .fill()
        )
            .background(.just([.black]))
            .clipShape(Circle())
            .overlay(.just([Circle().stroke([.green, .yellow], degree$: degree$, lineWidth: 4)]))
            .centerX(.just(0))
            .centerY(.just(0))
            .on(view)
    }
}

