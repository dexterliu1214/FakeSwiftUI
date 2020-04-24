//
//  Shape.swift
//  ios-webrtc-client
//
//  Created by youga on 2019/10/15.
//  Copyright © 2019 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit

open class Shape {
    var color = UIColor.black
    var lineWidth:CGFloat = 2
    func getPath(_ view:UIView) -> UIBezierPath { return UIBezierPath() }
    public func stroke(_ color:UIColor, lineWidth: CGFloat = 2.0) -> Shape {
        self.color = color
        self.lineWidth = lineWidth
        return self
    }
}

open class Circle:Shape {
    override func getPath(_ view:UIView) -> UIBezierPath {
        let radius = view.bounds.height/2
        return UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
    }
    override public init() {
        super.init()
    }
}

open class RoundedRectangle:Shape {
    var cornerRadius:CGFloat
    var corners:UIRectCorner
    
    public init(cornerRadius:CGFloat, corners:UIRectCorner = UIRectCorner.allCorners) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }
    
    override func getPath(_ view:UIView) -> UIBezierPath {
        return UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
}

open class Arrow:Shape {
    public enum Direction {
        case Left
        case Right
    }
    var direction:Direction
    var cornerRadius:CGFloat
    var arrowWidth:CGFloat
    
    public init(direction:Direction, arrowWidth:CGFloat, cornerRadius:CGFloat) {
        self.direction = direction
        self.arrowWidth = arrowWidth
        self.cornerRadius = cornerRadius
    }
    
    override func getPath(_ view:UIView) -> UIBezierPath {
        let path = CGMutablePath()
        if direction == .Right {
            path.move(to: CGPoint(x: view.bounds.minX, y: view.bounds.maxY - cornerRadius))
            path.addArc(tangent1End: CGPoint(x: view.bounds.minX, y: view.bounds.minY), tangent2End: CGPoint(x: view.bounds.maxX, y: view.bounds.minY), radius: cornerRadius)
            path.addLine(to: CGPoint(x: view.bounds.maxX - arrowWidth, y: view.bounds.minY))
            path.addLine(to: CGPoint(x: view.bounds.maxX, y: view.bounds.minY + view.bounds.height / 2))
            path.addLine(to: CGPoint(x: view.bounds.maxX - arrowWidth, y: view.bounds.maxY))
            path.addArc(tangent1End: CGPoint(x: view.bounds.minX, y: view.bounds.maxY), tangent2End: CGPoint(x: view.bounds.minX, y: view.bounds.minY), radius: cornerRadius)
        } else {
            path.move(to: CGPoint(x: view.bounds.maxX, y: view.bounds.maxY - cornerRadius))
            path.addArc(tangent1End: CGPoint(x: view.bounds.maxX, y: view.bounds.minY), tangent2End: CGPoint(x: view.bounds.minX, y: view.bounds.minY), radius: cornerRadius)
            path.addLine(to: CGPoint(x: view.bounds.minX + arrowWidth, y: view.bounds.minY))
            path.addLine(to: CGPoint(x: view.bounds.minX, y: view.bounds.minY + view.bounds.height / 2))
            path.addLine(to: CGPoint(x: view.bounds.minX + arrowWidth, y: view.bounds.maxY))
            path.addLine(to: CGPoint(x: view.bounds.maxX - cornerRadius, y: view.bounds.maxY))
            path.addArc(tangent1End: CGPoint(x: view.bounds.maxX, y: view.bounds.maxY), tangent2End: CGPoint(x: view.bounds.maxX, y: view.bounds.minY), radius: cornerRadius)
        }
        return UIBezierPath(cgPath: path)
    }
}
