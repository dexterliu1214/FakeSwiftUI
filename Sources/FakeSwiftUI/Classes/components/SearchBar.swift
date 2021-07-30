//
//  SearchBar.swift
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

open class SearchBar:View {
    let searchBar = UISearchBar()
    
    public init(placeholder:String, _ text$:BehaviorRelay<String?>) {        
        super.init()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.append(to: self).fillSuperview()
        searchBar.placeholder = placeholder
        text$ <~> searchBar.rx.text ~ disposeBag
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func barStyle(_ style:UIBarStyle) -> Self {
        searchBar.barStyle = style
        return self
    }
    
    public func autocapitalizationType(_ type:UITextAutocapitalizationType) -> Self {
        searchBar.autocapitalizationType = type
        return self
    }
    
    public func onSearch(_ callback:@escaping(String?) -> ()) -> Self {
        searchBar.rx.searchButtonClicked
            .subscribe(onNext:{[weak self] in
				guard let self = self else { return }
                callback(self.searchBar.text)
            }) ~ disposeBag
        return self
    }
    
    public func onCancel(_ callback:@escaping() -> ()) -> Self {
        searchBar.rx.text.changed.distinctUntilChanged()
            .subscribe(onNext:{
                if $0 == "" {
                    callback()
                }
            }) ~ disposeBag
        return self
    }
}

