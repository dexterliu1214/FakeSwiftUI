//
//  Text.swift
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

open class Text:View {
    let labelView = Label()
    
    var fontSize:CGFloat = UIFont.systemFontSize
    var isBold:Bool = false
    
    public convenience init(_ stream$:Observable<String>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: "") ~> labelView.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:Observable<String?>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: nil) ~> labelView.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:BehaviorRelay<String?>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: nil) ~> labelView.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:Observable<NSAttributedString?>) {
        self.init()
        stream$ ~> labelView.rx.attributedText ~ disposeBag
    }
    
    public convenience init(_ text:String) {
        self.init()
        self.labelView.text = text
    }
    
    public override init (){
        super.init()
        view = labelView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func padding(_ padding:UIEdgeInsets = .symmetric(4, 8)) -> Self {
        labelView.padding(padding)
        return self
    }
    
    public func font(_ style:UIFont.TextStyle) -> Self {
        labelView.font = UIFont.preferredFont(forTextStyle: style)
        return self
    }
    
    public func font(_ size:CGFloat) -> Self {
        fontSize = size
        labelView.font = generateFont()
        return self
    }
    
    public func bold() -> Self {
        isBold = true
        labelView.font = generateFont()
        return self
    }
    
    private func generateFont() -> UIFont {
        if isBold {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
        
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    public func color(_ color: UIColor) -> Self {
        labelView.textColor = color
        return self
    }
    
    public func color(_ color$: Observable<UIColor>) -> Self {
        color$ ~> labelView.rx.textColor ~ disposeBag
        return self
    }
    
    public func resizeToFit() -> Self {
        labelView.adjustsFontSizeToFitWidth = true
        labelView.minimumScaleFactor = 0.1
        labelView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return self
    }
    
    public func lineLimit(_ number:Int) -> Self {
        labelView.numberOfLines = number
        return self
    }
    
    public func lineBreakMode(_ mode:NSLineBreakMode) -> Self {
        labelView.lineBreakMode = mode
        return self
    }
    
    public func textAlignment(_ type:NSTextAlignment) -> Self {
        labelView.textAlignment = type
        return self
    }
}
