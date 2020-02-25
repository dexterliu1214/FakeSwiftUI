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
    
    public static func newInstance(colors:[CGColor] = [UIColor.black.cgColor, UIColor.clear.cgColor], locations:[NSNumber]? = nil, degree:Double? = nil ) -> GradientView {
        let v = GradientView()
        let gradientLayer = v.layer as! CAGradientLayer
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        if let degree = degree {
            let x: Double! = degree / 360.0
            let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
            let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
            let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
            let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
            gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
            gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        }
        return v
    }
}

