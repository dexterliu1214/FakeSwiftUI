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
struct ImageDemoViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            ImageDemoViewController()
        }
    }
}
#endif

class ImageDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        let height$ = BehaviorRelay<CGFloat>(value: -40)
//        ZStack(
//            VStack(alignment: .fill,
//                   List(items: Observable.just(["1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2","1", "2"]), { (cell:UITableViewCell, model, row, tv) -> UITableViewCell in
//                    cell.textLabel?.text = model
//                    return cell
//                   })
//                        .height(height$.map{ UIScreen.main.bounds.height / 2 - $0 - 30 })
//            )
//                .bottom(offset: 0)
//                .leading(offset: 0)
//                .trailing(offset: 0),
//            View()
//                .background(.red)
//                .width(offset: 40)
//                .height(offset: 40)
//                .centerX(offset: 0)
//                .centerY(height$.asObservable())
//                .draggable(axis: .vertical, limit:Observable.just(CGRect(x: 0, y: -100, width: 0, height: 200))){
//                    print($0)
//                    height$.accept($0.y)
//            }
//        )
//            .fill()
//            .on(view)
        let url = "https://placeimg.com/20/20/any"
        let color = UIColor(patternImage: UIImage(data: try! Data(contentsOf: URL(string: url)!))!)
        Toggle(isOn: BehaviorRelay(value:true)).thumbTintColor(color).centerX(.just(0)).centerY(.just(0)).on(view)
    }
}
