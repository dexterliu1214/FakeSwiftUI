//
//  GradientView.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/3/5.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit

open class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    public init(colors:[UIColor] = [UIColor.black, UIColor.clear], locations:[NSNumber]? = nil, degree:Double? = nil ) {
        super.init(frame: .zero)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.locations = locations
        if let degree:Double = degree {
            let x: Double! = degree / 360.0
            let a:Float = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
            let b:Float = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
            let c:Float = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
            let d:Float = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
            gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
            gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

