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
import RxBinding

#if targetEnvironment(simulator)
import SwiftUI

@available(iOS 13.0.0, *)
struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            GridDemoViewController()
        }
    }
}
#endif

class GridDemoViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let isShowColorMenu$ = BehaviorRelay(value: false)
        let colors = [
            "#FFFFFF",
            "#FE99FF",
            "#CCFFFF",
            "#CC99FF",
            "#99FFFF",
            "#9999FF",
            "#FFFE00",
            "#FF9900",
            "#CCFE00",
            "#CC9900",
            "#99FE00",
            "#999900",
            "#66FFFF",
            "#6699FF",
            "#33FFFF",
            "#3399FF",
            "#1EFFFF",
            "#0999FF",
            "#66FE00",
            "#669900",
            "#33FE00",
            "#339900",
            "#20FE00",
            "#0F9900"
        ]
        
        let selectedColorString$ = BehaviorRelay(value: colors.first!)
        let selectedColor$ = selectedColorString$.map{ String($0.dropFirst()).hex!.color }
        
        ZStack(
            Button("show grid") { _ in
                isShowColorMenu$.accept(true)
            }
                .color(.black)
                .background(selectedColor$)
                .centerX(offset: 0)
                .centerY(offset: 0),
            Grid(columns: 5, items: Observable.just(colors)) { (cell:UICollectionViewCell, model, row, view) -> UICollectionViewCell in
                cell.backgroundColor = String(model.dropFirst()).hex?.color
                return cell
            }
                .padding()
                .background(.black)
                .leading(offset: 0)
                .trailing(offset: 0)
                .bottom(isShowColorMenu$.map{$0 ? 0 : UIScreen.main.bounds.height / 2}, startValue: UIScreen.main.bounds.height / 2, duration: 0.5)
                .height(offset: UIScreen.main.bounds.height / 2)
                .itemSelected{ model, index in
                    selectedColorString$.accept(model)
                    isShowColorMenu$.accept(false)
                }
        ).fill().on(view)
    }
}

