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
        
//        ZStack(
//            Image(Observable.just("https://placeimg.com/640/480/any"))
//                .aspectRatio(contentMode: .scaleAspectFill)
//                .clipShape(Circle())
//                .overlay(Circle().stroke([.green, .yellow], lineWidth: 4))
//                .shadow(color: .black, radius: 10)
//                .blur()
//                .fill()
//        )
//            .frame(width: 200, height: 200)
//            .shadow(radius: 10)
//            .centerX(offset: 0)
//            .centerY(offset: 0)
//            .draggable()
//            .on(view)
        VStack(alignment: .fill, spacing: 0,
               HStack(alignment: .center, spacing: 0,
                      View().background(["38386C", "DEDEDE"].map{ $0.hex!.color }, degree: 90).height(offset: 2),
                      Text("禮物盒").color(.white).textAlignment(.center).font(20),
                      View().background(["DEDEDE", "38386C"].map{ $0.hex!.color }, degree: 90).height(offset: 2)
               )
                .padding()
                .distribution(.fillProportionally),
            Grid(columns:5, items:Observable.just([1])) {(cell:HougongGiftCell, model, row, view) in
                print(model)
                return cell
            }.ratio(0.9)
        )
            .background(["1D1D46", "6666AD", "202052"].map{ $0.hex!.color }, degree: 30)
            .fill().on(view)
    }
}

class HougongGiftCell:UICollectionViewCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        
        VStack(alignment: .fill, spacing: 0,
               Image(Observable.just("https://placeimg.com/640/480/any")),
               HStack(alignment: .center, spacing: 0,
                      Image(Observable.just("https://placeimg.com/640/480/any")),
                      Text("100")
                        .color(.white)
                )//.padding()
                .distribution(.fillEqually)
        )
        //.padding()
            .fill().on(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
