//
//  Stack.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxGesture

open class ZStack:View
{
    public init(_ subviews:UIView...) {
        super.init()
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        subviews.forEach{
            $0.append(to: view)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class VStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 8, _ subviews: UIView...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.stackView.axis = .vertical
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 8, _ subviews: UIView...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.stackView.axis = .horizontal
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Stack:View {
    let stackView = UIStackView()
        
    public init(alignment:UIStackView.Alignment = .center, spacing:CGFloat, subviews:[UIView]) {
        super.init()
        stackView.alignment = alignment
        stackView.distribution = .fill
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.append(to: self).fillSuperview()
        subviews.forEach{
            stackView.addArrangedSubview($0)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = insets
        return self
    }
    
    @discardableResult
    public func distribution(_ type:UIStackView.Distribution) -> Self {
        stackView.distribution = type
        return self
    }
}

open class Spacer:View {
    public init(axis:NSLayoutConstraint.Axis = .horizontal) {
        super.init()
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: axis)
        view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
