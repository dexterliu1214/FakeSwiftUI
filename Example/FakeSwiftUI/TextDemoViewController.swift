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
        let time$ = Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
        let overlay$ = time$.map{
             $0 % 2 == 0 ? [Circle().stroke([.blue, .yellow], lineWidth: 4)] : []
        }
        ZStack(
            Text(time$.map{ "FakeSwiftUI Rocks\($0)"})
                .font(40)
                .clipShape(Circle())
                .overlay(overlay$)
                .padding(.symmetric(4, 16))
                .background([UIColor.red, .blue])
                .centerX(offset: 0)
                .centerY(offset: 0)
        )
            .background(.red)
            .fill()
            .edgesIgnoringSafeArea(.all)
//            .blur()
            .on(view)
    }
}
