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
import RxAnimated

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
    
    public override init (){
        super.init()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.append(to: self).fillSuperview()
    }
    
    public convenience init(_ stream$:Observable<String?>, animationSink:((AnimatedSink<Label>) -> (AnimatedSink<Label>))? = nil) {
        self.init()
        guard let animationSink = animationSink else {
            stream$.asDriver(onErrorJustReturn: nil) ~> labelView.rx.text ~ disposeBag
            return
        }
        stream$.map{ $0 ?? ""}.asDriver(onErrorJustReturn: "") ~> animationSink(labelView.rx.animated).text ~ disposeBag
    }
    
    public convenience init(_ text:String?, animationSink:((AnimatedSink<Label>) -> (AnimatedSink<Label>))? = nil) {
        self.init(.just(text), animationSink:animationSink)
    }
    
    public convenience init(_ stream$:Observable<NSAttributedString?>, animationSink:((AnimatedSink<Label>) -> (AnimatedSink<Label>))? = nil) {
        self.init()
        guard let animationSink = animationSink else {
            stream$.asDriver(onErrorJustReturn: nil) ~> labelView.rx.attributedText ~ disposeBag
            return
        }
        stream$.map{ $0 ?? NSAttributedString() }.asDriver(onErrorJustReturn: NSAttributedString()) ~> animationSink(labelView.rx.animated).attributedText ~ disposeBag
    }
        
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func padding(_ padding:UIEdgeInsets = .symmetric(4, 8)) -> Self {
        labelView.padding(padding)
        return self
    }
    
    @discardableResult
    public func font(_ style:UIFont.TextStyle) -> Self {
        labelView.font = UIFont.preferredFont(forTextStyle: style)
        return self
    }
    
    @discardableResult
    public func font(_ size:CGFloat) -> Self {
        fontSize = size
        labelView.font = generateFont()
        return self
    }
    
    @discardableResult
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
    
    @discardableResult
    public func color(_ color: UIColor) -> Self {
        labelView.textColor = color
        return self
    }
    
    @discardableResult
    public func color(_ color$: Observable<UIColor>) -> Self {
        color$ ~> labelView.rx.textColor ~ disposeBag
        return self
    }
    
    @discardableResult
    public func resizeToFit() -> Self {
        labelView.adjustsFontSizeToFitWidth = true
        labelView.minimumScaleFactor = 0.1
        labelView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return self
    }
    
    @discardableResult
    public func lineLimit(_ number:Int) -> Self {
        labelView.numberOfLines = number
        return self
    }
    
    @discardableResult
    public func lineBreakMode(_ mode:NSLineBreakMode) -> Self {
        labelView.lineBreakMode = mode
        return self
    }
    
    @discardableResult
    public func textAlignment(_ type:NSTextAlignment) -> Self {
        labelView.textAlignment = type
        return self
    }
}
