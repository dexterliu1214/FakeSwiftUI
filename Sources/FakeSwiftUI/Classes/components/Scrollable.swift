//
//  Scrollable.swift
//  FakeSwiftUI
//
//  Created by youga on 2020/6/18.
//

import Foundation

open class Scrollable:View
{
    let view = UIScrollView()
    let contentView = UIView()
    
    public init(_ subview:UIView) {
        super.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.addSubview(subview)
        subview.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        subview.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
