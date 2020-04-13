//
//  GradientView.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/3/5.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxBinding

open class GradientView: UIView {
    let disposeBag = DisposeBag()
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    public init(colors:[UIColor] = [UIColor.black, UIColor.clear], degree:Double? = nil, locations:[NSNumber]? = nil) {
        super.init(frame: .zero)
        let gradientLayer:CAGradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.locations = locations
        if let degree:Double = degree {
            let x: Double = degree / 360.0
            let a:Double = calc(x, 0.75)
            let b:Double = calc(x, 0.0)
            let c:Double = calc(x, 0.25)
            let d:Double = calc(x, 0.5)
            gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
            gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        }
    }
    
    public init(colors$:Observable<[UIColor]>, degree$:Observable<Double>, locations:[NSNumber]? = nil) {
        super.init(frame: .zero)
        let gradientLayer:CAGradientLayer = self.layer as! CAGradientLayer
        colors$
            .map{ $0.map{ $0.cgColor} }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext:{
                gradientLayer.colors = $0
            }) ~ disposeBag
            
        gradientLayer.locations = locations
        degree$
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext:{[weak self] degree in
                guard let self = self else { return }
                let x: Double = degree / 360.0
                let a:Double = self.calc(x, 0.75)
                let b:Double = self.calc(x, 0.0)
                let c:Double = self.calc(x, 0.25)
                let d:Double = self.calc(x, 0.5)
                gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
                gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
            }) ~ disposeBag
    }
    
    fileprivate func calc(_ x:Double, _ y:Double) -> Double {
        return pow(sin((2.0 * .pi * ((x + y) / 2.0))),2.0)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

