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
import RxDataSources

open class Grid<CellType:UICollectionViewCell, ModelType>:View
{
    var columns:Int?
    let layout = UICollectionViewFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
    var scrollToIndexPath:(IndexPath, UICollectionView.ScrollPosition, Bool)?
    var ratio:CGFloat?
    
    override init() {
        super.init()
        self.collectionView.backgroundView = UIView()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.append(to: self).fillSuperview()
        collectionView.backgroundColor = .clear
        collectionView.register(CellType.self, forCellWithReuseIdentifier: "CELL")
    }
    
    public convenience init(
        itemSize:CGSize,
        vSpacing:CGFloat = 8,
        hSpacing:CGFloat = 8,
        items:Observable<[ModelType]>,
        _ builder:@escaping(CellType, ModelType, Int, UICollectionView
        ) -> UICollectionViewCell) {
        self.init()
        
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = hSpacing
        layout.minimumLineSpacing = vSpacing
        
        items.map{ $0.count == 0 }.asDriver(onErrorJustReturn: true) ~> collectionView.backgroundView!.rx.isShow ~ disposeBag
        
        items.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items) { (cv:UICollectionView, row:Int, element:ModelType) in
            let indexPath:IndexPath = .init(row: row, section: 0)
            let cell:CellType = cv.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CellType
            return builder(cell, element, row, cv)
        } ~ disposeBag
    }
    
    public convenience init(
        columns:Int,
        vSpacing:CGFloat = 8,
        hSpacing:CGFloat = 8,
        items:Observable<[ModelType]>,
        _ builder:@escaping(CellType, ModelType, Int, UICollectionView
    ) -> UICollectionViewCell) {
        self.init()
        
        self.columns = columns
        layout.minimumInteritemSpacing = hSpacing
        layout.minimumLineSpacing = vSpacing

        items.map{ $0.count == 0 }.asDriver(onErrorJustReturn: true) ~> collectionView.backgroundView!.rx.isShow ~ disposeBag
        
        items.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items) { (cv:UICollectionView, row:Int, element:ModelType) in
            let indexPath:IndexPath = .init(row: row, section: 0)
            let cell:CellType = cv.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CellType
            return builder(cell, element, row, cv)
        } ~ disposeBag
    }
    
    public convenience init<HeaderType:UICollectionReusableView, FooterType:UICollectionReusableView>(
        columns:Int,
        vSpacing:CGFloat = 8,
        hSpacing:CGFloat = 8,
        items:Observable<[SectionModel<String, ModelType>]>,
        headerBuilder:@escaping((HeaderType, UICollectionView, IndexPath, String) -> UICollectionReusableView),
        footerBuilder:@escaping((FooterType, UICollectionView, IndexPath, String) -> UICollectionReusableView),
        _ builder:@escaping(CellType, ModelType, Int) -> UICollectionViewCell
    ) {
        self.init()
        
        self.columns = columns
        
        layout.minimumInteritemSpacing = hSpacing
        layout.minimumLineSpacing = vSpacing
        layout.headerReferenceSize = CGSize(width: 200, height: 40)
        layout.footerReferenceSize = CGSize(width: 200, height: 40)
        layout.sectionInset = .symmetric(8, 0)

        collectionView.register(HeaderType.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Section")
        collectionView.register(FooterType.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Section")

        items.map{ $0.count == 0 }.asDriver(onErrorJustReturn: true) ~> collectionView.backgroundView!.rx.isShow ~ disposeBag
        
        let dataSource:RxCollectionViewSectionedReloadDataSource<SectionModel<String, ModelType>> = .init(configureCell: { (ds:CollectionViewSectionedDataSource, cv:UICollectionView, ip:IndexPath, model:ModelType) in
            let cell:CellType = cv.dequeueReusableCell(withReuseIdentifier: "CELL", for: ip) as! CellType
            return builder(cell, model, ip.item)
        }, configureSupplementaryView: { (ds:CollectionViewSectionedDataSource, cv:UICollectionView, kind:String, ip:IndexPath) in
            if kind == UICollectionView.elementKindSectionHeader {
                let section:HeaderType = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: ip) as! HeaderType
                return headerBuilder(section, cv, ip, ds[ip.item].model)
            } else {
                let section:FooterType = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: ip) as! FooterType
                return footerBuilder(section, cv, ip, ds[ip.item].model)
            }
        })

        items ~> collectionView.rx.items(dataSource: dataSource) ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.contentInset = .all(8)
        
        guard let _columns = columns else {
            let itemCount = floor((bounds.width) / (layout.itemSize.width + layout.minimumInteritemSpacing))
            let margin:CGFloat =  (bounds.width - (itemCount * layout.itemSize.width) - ((itemCount - 1) * layout.minimumInteritemSpacing)) / 2
            collectionView.contentInset = .init(top: collectionView.contentInset.top, left: margin, bottom: collectionView.contentInset.bottom, right: margin)
            return
        }
        
        let columns = CGFloat(_columns)
        
        let hSpacing:CGFloat = layout.minimumInteritemSpacing
        let totalWidth = min(self.bounds.width, self.bounds.height)
        let width:CGFloat = (totalWidth - collectionView.contentInset.left - collectionView.contentInset.right - (columns - 1) * hSpacing) / columns
        
        if let ratio:CGFloat = ratio {
            layout.itemSize = CGSize(width: width, height: width / ratio)
            return
        }
        
        if layout.scrollDirection == .vertical {
            if width <= 0 {
                return
            }
            layout.itemSize = CGSize(width: width, height: width)
            guard let viewDidLayoutSubview$ = viewDidLayoutSubview$ else { return }
            viewDidLayoutSubview$.asDriver(onErrorJustReturn: ())
                .drive(onNext:{[weak self] in
                    guard let self = self else { return }
                    let columns = floor((self.bounds.width - self.collectionView.contentInset.left) / (self.layout.itemSize.width + hSpacing))
                    let margin:CGFloat = (self.bounds.width - (columns * self.layout.itemSize.width) - ((columns - 1) * hSpacing)) / 2
                    self.collectionView.contentInset = .init(top: self.collectionView.contentInset.top, left: margin, bottom: self.collectionView.contentInset.bottom, right: margin)
                }) ~ disposeBag
        } else {
            if columns == 1 && collectionView.isPagingEnabled {
                let height:CGFloat =  self.bounds.height
                layout.itemSize = CGSize(width: width, height: height)
            } else {
                let width:CGFloat = self.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
                layout.itemSize = CGSize(width: width, height: width)
            }
        }
        
//        guard let viewDidLayoutSubview$ = viewDidLayoutSubview$ else { return }
        guard let (scrollToIndexPath, scrollPosition, animated) = self.scrollToIndexPath  else { return }
//        viewDidLayoutSubview$.asDriver(onErrorJustReturn: ())
//            .drive(onNext:{[weak self] in
//                self?.collectionView.scrollToItem(at: scrollToIndexPath, at: scrollPosition, animated: animated)
//            }) ~ disposeBag
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: scrollToIndexPath, at: scrollPosition, animated: animated)
        }
    }
    
    @discardableResult
    public func ratio(_ value:CGFloat) -> Self {
        ratio = value
        return self
    }
    
    @discardableResult
    public func autoSize() -> Self {
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return self
    }

    @discardableResult
    public func emptyView(_ view:@escaping () -> View) -> Self {
        view().centerX(offset: 0).centerY(offset: 0).on(self.collectionView.backgroundView!)
        return self
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        collectionView.contentInset = insets
        return self
    }
    
    @discardableResult
    public func onRefresh(_ callback:@escaping(_ complete:@escaping() -> ()) -> ()) -> Self {
        let refreshControl:UIRefreshControl = .init()
        refreshControl.tintColor = .white
        refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext:{
            let complete = {
                DispatchQueue.main.async {
                    refreshControl.endRefreshing()
                }
            }
            callback(complete)
        }) ~ disposeBag
        collectionView.refreshControl = refreshControl
        return self
    }
    
    @discardableResult
    public func onSwipe(_ direction:Set<SwipeDirection>, _ callback:@escaping(UISwipeGestureRecognizer.Direction) -> ()) -> Self {
        collectionView.rx.swipeGesture(direction)
            .when(.recognized)
            .subscribe(onNext:{
                callback($0.direction)
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func alwaysBounceVertical(_ value:Bool = true) -> Self {
        collectionView.alwaysBounceVertical = value
        return self
    }
    
    @discardableResult
    public func alwaysBounceHorizontal() -> Self {
        collectionView.alwaysBounceHorizontal = true
        return self
    }
    
    @discardableResult
    public func scrollDirection(_ direction:UICollectionView.ScrollDirection) -> Self {
        layout.scrollDirection = direction
        return self
    }
    
    @discardableResult
    public func isPagingEnabled(_ value:Bool) -> Self {
        collectionView.isPagingEnabled = value
        return self
    }
    
    @discardableResult
    public func scrollToItem(at indexPath:IndexPath, at scrollPosition:UICollectionView.ScrollPosition, animated:Bool) -> Self {
        scrollToIndexPath = (indexPath, scrollPosition, animated)
        return self
    }
    
    @discardableResult
    public func itemSelected(_ callback:@escaping(ModelType, IndexPath) -> ()) -> Self {
        Observable.zip(
            collectionView.rx.modelSelected(ModelType.self),
            collectionView.rx.itemSelected
        )
        .subscribe(onNext:{
            callback($0, $1)
        }) ~ disposeBag
        return self
    }
    
    var viewDidLayoutSubview$:Observable<Void>?
    @discardableResult
    public func viewDidLayoutSubview(_ trigger$:Observable<Void>) -> Self {
        viewDidLayoutSubview$ = trigger$
        return self
    }
}
