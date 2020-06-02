//
//  ViewControllerView.swift
//  FakeSwiftUI_Example
//
//  Created by youga on 2020/6/2.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 13.0.0, *)
struct ViewControllerView<T:UIViewController>: UIViewControllerRepresentable {
    
    let builder:() -> T
    
    init(_ builder:@escaping() -> T) {
        self.builder = builder
    }
    
    func makeUIViewController(context: Context) -> T {
        builder()
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        
    }
    
    typealias UIViewControllerType = T
}
