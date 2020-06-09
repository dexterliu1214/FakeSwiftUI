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

#if targetEnvironment(simulator)
import SwiftUI
@available(iOS 13.0.0, *)
struct InviteViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            InviteViewController(point: "20")
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

class InviteViewController:UIViewController
{
    let point:String
    
    init(point:String) {
        self.point = point
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let isOn$ = BehaviorRelay(value: false)
        let isOn2$ = BehaviorRelay(value: true)
        ZStack(
            VStack(
                Image(Observable.just("https://placeimg.com/640/480/any"))
                    .background(.white)
                    .frame(width: 50, height: 50),
                Text("啟動一對一"),
                Text("\(point)點/分鐘"),
                HStack(
                    Toggle("攝影機", isOn: isOn$).color(.systemYellow).accentColor(.white),
                    Toggle("麥克風", isOn: isOn2$).color(.systemYellow)
                ),
                Button("確定") {_ in

                }
                .width(offset: 200)
                .background(["5C5C5C".hex!.color, "222222".hex!.color])
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white))
            )
                .padding(.symmetric(8, 30))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background([
                    "7683C6".hex!.color,
                    "A28ACF".hex!.color,
                    "CA7AC2".hex!.color,
                    "9964A4".hex!.color,
                    "340F48".hex!.color,
                ], degree: 40)
                .fill(),
                Text("X")
                    .textAlignment(.center)
                    .frame(width: 30, height: 30)
                    .background(.white)
                    .clipShape(Circle())
                    .trailing(offset: -8)
                    .top(offset: 8)
        )
//            .width(offset: 250)
            .centerX(offset:0)
            .centerY(offset:0)
            .on(view)
    }
}
