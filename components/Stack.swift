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
    public init(_ subviews:View...) {
        super.init()
        _view = UIView()
        _init()
        subviews.forEach{[weak self] in
            guard let self = self, let view = self._view else { return }
            let v = $0
            v.on(view)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class VStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 0, _ subviews: View...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.__view.axis = .vertical
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HStack:Stack {
    public init(alignment: UIStackView.Alignment = .center, spacing:CGFloat = 0, _ subviews: View...) {
        super.init(alignment: alignment, spacing:spacing, subviews:subviews)
        self.__view.axis = .horizontal
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class Stack:View {
    let __view = UIStackView()
        
    public init(alignment:UIStackView.Alignment = .center, spacing:CGFloat, subviews:[View]) {
        super.init()
        _view = __view

        __view.alignment = alignment
        __view.distribution = .fill
        __view.spacing = spacing
        _init()
        subviews.forEach{
            __view.addArrangedSubview($0)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        __view.isLayoutMarginsRelativeArrangement = true
        __view.layoutMargins = insets
        return self
    }
    
    public func distribution(_ type:UIStackView.Distribution) -> Self {
        __view.distribution = type
        return self
    }
}

open class Spacer:View {
    public init(axis:NSLayoutConstraint.Axis = .horizontal) {
        super.init()
        _view = UIView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.setContentHuggingPriority(.defaultLow, for: axis)
        _view.append(to: self).fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
