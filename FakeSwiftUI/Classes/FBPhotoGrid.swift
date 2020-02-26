//
//  CollectionView.swift
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

open class FBPhotoGrid<C:UICollectionViewCell>:View, UICollectionViewDelegateFlowLayout {
    var __view:UICollectionView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView:UICollectionView = newValue as? UICollectionView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    let layout:UICollectionViewFlowLayout = .init()
    
    public init<T>(vSpacing:CGFloat = 8, hSpacing:CGFloat = 8, items:Observable<[T]>, _ builder:@escaping(C, T, Int) -> (C)) {
        __view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init()
        let _ = __view.rx.setDelegate(self)
        __view.isScrollEnabled = false
        layout.minimumInteritemSpacing = hSpacing
        layout.minimumLineSpacing = vSpacing
        
        self.__view.backgroundView = UIView()
        
        _init()
        __view.register(C.self, forCellWithReuseIdentifier: "CELL")
        
        items.map{ $0.count == 0 }.asDriver(onErrorJustReturn: true).drive(__view.backgroundView!.rx.isShow) ~ disposeBag
        
        items.asDriver(onErrorJustReturn: []).drive(__view.rx.items) { (collectionView:UICollectionView, row:Int, element:T) in
            let indexPath:IndexPath = .init(row: row, section: 0)
            let cell:C = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! C
            return builder(cell, element, row)
        }.disposed(by: disposeBag)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func emptyView(_ view:@escaping () -> UIView) -> Self {
        view().append(to: self.__view.backgroundView!).centerX().centerY()
        return self
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        __view.contentInset = insets
        return self
    }
    
    @discardableResult
    public func scrollDirection(_ direction$:Observable<UICollectionView.ScrollDirection>) -> Self {
        direction$.asDriver(onErrorJustReturn: .horizontal)
            .drive(onNext:{[weak self] in
                self?.layout.scrollDirection = $0
            }) ~ disposeBag
        return self
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count:Int = collectionView.numberOfItems(inSection: 0)
        let hSpacing:CGFloat = layout.minimumInteritemSpacing
        let vSpacing:CGFloat = layout.minimumInteritemSpacing
        let horizontalBigItemWidth:CGFloat = collectionView.bounds.width
        let horizontalSmallItemHeight:CGFloat = (collectionView.bounds.width - hSpacing * 2) / 3
        let horizontalBigItemHeight:CGFloat = (collectionView.bounds.width - horizontalSmallItemHeight - vSpacing)
        switch count {
        case 1:
            let cellWidth:CGFloat = collectionView.bounds.width
            let cellHeight:CGFloat = collectionView.bounds.height
            return CGSize(width: cellWidth, height: cellHeight)
        case 2:
            if layout.scrollDirection == .vertical {
                let cellWidth:CGFloat = collectionView.bounds.width
                let width:CGFloat = collectionView.bounds.width
                let cellHeight:CGFloat = (width - vSpacing) / 2
                return CGSize(width: cellWidth, height: cellHeight)
            } else {
                let width:CGFloat = collectionView.bounds.width - hSpacing
                let cellWidth:CGFloat = width / 2
                let cellHeight:CGFloat = collectionView.bounds.height
                return CGSize(width: cellWidth, height: cellHeight)
            }
        case 3:
            if layout.scrollDirection == .vertical {
                if indexPath.item == 0 {
                    return CGSize(width: horizontalBigItemWidth, height: horizontalBigItemHeight)
                } else {
                    let width:CGFloat = collectionView.bounds.width - hSpacing
                    let cellWidth:CGFloat = width / 2
                    return CGSize(width: cellWidth, height: horizontalSmallItemHeight)
                }
            } else {
                let width:CGFloat = collectionView.bounds.width - vSpacing
                let cellWidth:CGFloat = width / 2
                if indexPath.item == 0 {
                    let cellHeight:CGFloat = collectionView.bounds.height
                    return CGSize(width: cellWidth, height: cellHeight)
                } else {
                    return CGSize(width: cellWidth, height: cellWidth)
                }
            }
            case 4:
                if layout.scrollDirection == .vertical {
                    if indexPath.item == 0 {
                        return CGSize(width: horizontalBigItemWidth, height: horizontalBigItemHeight)
                    } else {
                        let width:CGFloat = collectionView.bounds.width - hSpacing * 2
                        let cellWidth:CGFloat = width / 3
                        return CGSize(width: cellWidth, height: cellWidth)
                    }
                } else {
                    if indexPath.item == 0 {
                        let width:CGFloat = collectionView.bounds.width - hSpacing * 2
                        let cellWidth:CGFloat = collectionView.bounds.width - width / 3 - hSpacing
                        let cellHeight:CGFloat = collectionView.bounds.height
                        return CGSize(width: cellWidth, height: cellHeight)
                    } else {
                        let width:CGFloat = collectionView.bounds.width - hSpacing * 2
                        let cellWidth:CGFloat = width / 3
                        return CGSize(width: cellWidth, height: cellWidth)
                    }
                }
            default:
                if layout.scrollDirection == .vertical {
                    if indexPath.item == 0 || indexPath.item == 1 {
                        let width:CGFloat = collectionView.bounds.width - hSpacing
                        let cellWidth:CGFloat = width / 2
                        return CGSize(width: cellWidth, height: horizontalBigItemHeight)
                    } else {
                        let width:CGFloat = collectionView.bounds.width - hSpacing * 2
                        let cellWidth:CGFloat = width / 3
                        return CGSize(width: cellWidth, height: cellWidth)
                    }
                } else {
                    if indexPath.item == 0 || indexPath.item == 1 {
                        let width:CGFloat = collectionView.bounds.width - hSpacing
                        let cellWidth:CGFloat = width / 2
                        let cellHeight:CGFloat = (collectionView.bounds.height - vSpacing) / 2
                        return CGSize(width: cellWidth, height: cellHeight)
                    } else {
                        let width:CGFloat = collectionView.bounds.width - hSpacing
                        let height:CGFloat = collectionView.bounds.height - vSpacing * 2
                        let cellWidth:CGFloat = width / 2
                        let cellHeight:CGFloat = height / 3
                        return CGSize(width: cellWidth, height: cellHeight)
                    }
                }
        }
    }
}
