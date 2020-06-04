//
//  ViewControllerView.swift
//  FakeSwiftUI_Example
//
//  Created by youga on 2020/6/2.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
#if targetEnvironment(simulator)
import SwiftUI

@available(iOS 13.0.0, *)
public struct ViewControllerView<T:UIViewController>: UIViewControllerRepresentable {
    
    let builder:() -> T
    
    public init(_ builder:@escaping() -> T) {
        self.builder = builder
    }
    
    public func makeUIViewController(context: Context) -> T {
        builder()
    }
    
    public func updateUIViewController(_ uiViewController: T, context: Context) {
        
    }
    
    public typealias UIViewControllerType = T
}
#endif
