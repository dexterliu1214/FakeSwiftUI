//
//  extension.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/2/24.
//

import Foundation
import UIKit

extension UIColor
{
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    public convenience init(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 255) {
        self.init(red:r / 255.0, green:g / 255.0, blue: b / 255.0, alpha: a / 255.0)
    }
}

extension Int
{
    public var color: UIColor {
        get {
            return UIColor(hex:self)
        }
    }
}

extension String {
    public var hex: Int? {
        return Int(self, radix: 16)
    }
}
