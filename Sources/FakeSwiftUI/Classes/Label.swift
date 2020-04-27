//
//  Label.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa

open class Label: UILabel {
    var insets = UIEdgeInsets.all(0)
    
    open override func drawText(in rect: CGRect) {
        let newRect = rect.inset(by: insets)
        super.drawText(in: newRect)
    }
    
    open override var intrinsicContentSize:CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += insets.top + insets.bottom
        intrinsicContentSize.width += insets.left + insets.right
        return intrinsicContentSize
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets) -> Self {
        self.insets = insets
        return self
    }
}

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { control, value in
            control.textColor = value
        }
    }
}
