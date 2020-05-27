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
    var name = ""
    var color = UIColor.black
    var colors = [UIColor]()
    var degree = 0.0
    public var lineWidth:CGFloat = 2
    public var inset:CGFloat = 0
    
    open func getOverlayPath(_ view:UIView) -> UIBezierPath { return UIBezierPath() }
    
    open func getClipPath(_ view:UIView) -> UIBezierPath { return UIBezierPath() }
    
    public func stroke(_ color:UIColor, lineWidth: CGFloat = 2.0, inset:CGFloat = 0) -> Shape {
        self.color = color
        self.lineWidth = lineWidth
        self.inset = inset
        return self
    }
    
    public func stroke(_ colors:[UIColor], degree:Double = 0, lineWidth: CGFloat = 2.0, inset:CGFloat = 0) -> Shape {
        self.colors = colors
        self.lineWidth = lineWidth
        self.degree = degree
        self.inset = inset
        return self
    }
    
    public init(){}
}

open class Circle:Shape {
    override public func getClipPath(_ view:UIView) -> UIBezierPath {
        let radius = view.bounds.height/2
        return UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
    }
    
    override public func getOverlayPath(_ view:UIView) -> UIBezierPath {
        let rect = view.bounds.inset(by: .all((lineWidth/2 + inset)))
        let radius = rect.height/2
        return UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
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
    
    override public func getOverlayPath(_ view:UIView) -> UIBezierPath {
        return UIBezierPath(roundedRect: view.bounds.inset(by: .all(lineWidth/2)), byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    override public func getClipPath(_ view:UIView) -> UIBezierPath {
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
    
    func getPath(_ bounds:CGRect) -> UIBezierPath {
        let path = CGMutablePath()
        if direction == .Right {
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY - cornerRadius))
            path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.minY), radius: cornerRadius)
            path.addLine(to: CGPoint(x: bounds.maxX - arrowWidth, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + bounds.height / 2))
            path.addLine(to: CGPoint(x: bounds.maxX - arrowWidth, y: bounds.maxY))
            path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.minX, y: bounds.minY), radius: cornerRadius)
        } else {
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
            path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.minX, y: bounds.minY), radius: cornerRadius)
            path.addLine(to: CGPoint(x: bounds.minX + arrowWidth, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + bounds.height / 2))
            path.addLine(to: CGPoint(x: bounds.minX + arrowWidth, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.maxY))
            path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.minY), radius: cornerRadius)
        }
        return UIBezierPath(cgPath: path)
    }
    
    override public func getClipPath(_ view:UIView) -> UIBezierPath {
        return getPath(view.bounds)
    }
    
    override public func getOverlayPath(_ view:UIView) -> UIBezierPath {
        return getPath(view.bounds.inset(by: .all(lineWidth/2)))
    }
}
