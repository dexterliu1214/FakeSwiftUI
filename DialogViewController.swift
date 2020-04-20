//
//  DialogViewController.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/4/20.
//

import Foundation
import UIKit

open class DialogViewController:UIViewController
{
    open var subview:View?
    var backgroundColor = UIColor.white
    
    public init(){
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let subview = subview else { return }
        ZStack(
            HStack(
                subview
            )
                .background(backgroundColor)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .centerX(offset: 0)
                .centerY(offset: 0)
        )
            .fill()
            .on(view)
    }
}

