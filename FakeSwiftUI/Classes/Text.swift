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
import PromiseKit
import AwaitKit

open class Text:View {
    var __view:Label
    override public var _view: UIView? {
        get {
            return __view
        }
        set {
            if let newView = newValue as? Label {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    var fontSize:CGFloat = UIFont.systemFontSize
    var isBold:Bool = false
    
    public convenience init(_ stream$:Observable<String>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: "") ~> __view.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:Observable<String?>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: nil) ~> __view.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:BehaviorRelay<String?>) {
        self.init()
        stream$.asDriver(onErrorJustReturn: nil) ~> __view.rx.text ~ disposeBag
    }
    
    public convenience init(_ stream$:Observable<NSAttributedString?>) {
        self.init()
        stream$ ~> __view.rx.attributedText ~ disposeBag
    }
    
    public convenience init(_ text:String) {
        self.init()
        self.__view.text = text
    }
    
    public override init (){
        __view = Label()
        super.init()
        _init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutClipShape(_ clipShape:Shape){
        let path = clipShape.getPath(self)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.frame = self.bounds
        self.__view.layer.mask = layer
    }
    
    public func padding(_ padding:UIEdgeInsets = .symmetric(4, 8)) -> Self {
        __view.padding(padding)
        return self
    }
    
    public func font(_ style:UIFont.TextStyle) -> Self {
        __view.font = UIFont.preferredFont(forTextStyle: style)
        return self
    }
    
    public func font(_ size:CGFloat) -> Self {
        fontSize = size
        __view.font = generateFont()
        return self
    }
    
    public func bold() -> Self {
        isBold = true
        __view.font = generateFont()
        return self
    }
    
    private func generateFont() -> UIFont {
        if isBold {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
        
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    public func color(_ color: UIColor) -> Self {
        __view.textColor = color
        return self
    }
    
    public func resizeToFit() -> Self {
        __view.adjustsFontSizeToFitWidth = true
        __view.minimumScaleFactor = 0.1
        __view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return self
    }
    
    public func lineLimit(_ number:Int) -> Self {
        __view.numberOfLines = number
        return self
    }
    
    public func lineBreakMode(_ mode:NSLineBreakMode) -> Self {
        __view.lineBreakMode = mode
        return self
    }
    
    public func textAlignment(_ type:NSTextAlignment) -> Self {
        __view.textAlignment = type
        return self
    }
}
