//
//  List.swift
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
import RxDataSources
import ReverseExtension

open class List<CellType:UITableViewCell>:View,UITableViewDelegate {
    var __view:UITableView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? UITableView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    var sectionViewBuilder:((Int) -> UIView?)?
    var sectionViewHeightCalculator:((Int) -> CGFloat)?
    var isAutoDeselect = false
    
    public init<ModelType>(items:Observable<[ModelType]>, _ builder:@escaping(CellType, ModelType, Int, UITableView) -> UITableViewCell) {
        __view = UITableView()
        super.init()
       
        __view.rowHeight = UITableView.automaticDimension
        __view.register(CellType.self, forCellReuseIdentifier: "CELL")
        
        _init()
        
        self.__view.backgroundView = UIView()
        self.__view.tableFooterView = UIView()
        items.map{ $0.count > 0 } ~> __view.backgroundView!.rx.isHidden ~ disposeBag
        
        items.asDriver(onErrorJustReturn: []).drive(__view.rx.items) { (view, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = view.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! CellType
            return builder(cell, element, row, view)
        }.disposed(by: disposeBag)
        
        __view.rx.itemSelected
            .subscribe(onNext:{[weak self] in
                 guard let self = self else { return }
                 if self.isAutoDeselect {
                     self.__view.deselectRow(at: $0, animated: false)
                 }
            })
            .disposed(by: disposeBag)
    }

    public init<ModelType>(items:Observable<[SectionModel<String, ModelType>]>, style:UITableView.Style = .plain, _ builder:@escaping(CellType, IndexPath, ModelType) -> UITableViewCell) {
        __view = UITableView(frame: .zero, style: style)
        super.init()
              
        __view.rowHeight = UITableView.automaticDimension
        __view.register(CellType.self, forCellReuseIdentifier: "CELL")
        _init()
        
        self.__view.backgroundView = UIView()
        self.__view.tableFooterView = UIView()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ModelType>>(configureCell: { ds, tv, ip, model in
            let cell = tv.dequeueReusableCell(withIdentifier: "CELL", for: ip) as! CellType
            return builder(cell, ip, model)
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
           return dataSource.sectionModels[index].model
        }
        items ~> __view.rx.items(dataSource: dataSource) ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("")
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let builder = sectionViewBuilder {
            let headerView = UIView()
            builder(section)?.append(to:headerView).fillSuperview()
            return headerView
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionViewHeightCalculator?(section) ?? 0
    }
    
    @discardableResult
    public func reversed() -> Self {
        __view.re.delegate = self
        return self
    }
    
    @discardableResult
    public func sectionView(_ builder:@escaping(_ section:Int) -> UIView?, height:@escaping(_ section:Int) -> CGFloat) -> Self {
        __view.rx.setDelegate(self) ~ disposeBag
        sectionViewBuilder = builder
        sectionViewHeightCalculator = height
        return self
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
    public func onRefresh(tintColor:UIColor = .white, _ callback:@escaping() -> (Promise<()>)) -> Self {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = tintColor
        refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext:{
			AwaitKit.async {
                try `await`(callback())
                DispatchQueue.main.async {
                    refreshControl.endRefreshing()
                }
            }
        }).disposed(by: disposeBag)
        __view.refreshControl = refreshControl
        return self
    }
    
    @discardableResult
    public func onModelSelected<T>(_ callback:@escaping(T) -> ()) -> Self {
        __view.rx.modelSelected(T.self)
            .subscribe(onNext:{
                callback($0)
            })
            .disposed(by: disposeBag)
        return self
    }
    
    @discardableResult
    public func itemSelected(_ callback:@escaping(IndexPath) -> ()) -> Self {
       __view.rx.itemSelected
           .subscribe(onNext:{
                callback($0)
           })
           .disposed(by: disposeBag)
       return self
    }
    
    public func itemDeleted(_ callback:@escaping(IndexPath) -> ()) -> Self {
       __view.rx.itemDeleted
           .subscribe(onNext:{
                callback($0)
           })
           .disposed(by: disposeBag)
       return self
    }
    
    @discardableResult
    public func onSwipe(_ direction:Set<SwipeDirection>, _ callback:@escaping(UISwipeGestureRecognizer.Direction) -> ()) -> Self {
        __view.rx.swipeGesture(direction)
            .when(.recognized)
            .subscribe(onNext:{
                callback($0.direction)
            })
            .disposed(by: disposeBag)
        return self
    }
    
    @discardableResult
    public func allowSelection(_ value:Bool) -> Self {
        __view.allowsSelection = value
        return self
    }
    
    @discardableResult
    public func autoDeselect(_ value:Bool) -> Self {
        isAutoDeselect = value
        return self
    }
    
    @discardableResult
    public func separatorStyle(_ style:UITableViewCell.SeparatorStyle) -> Self {
        __view.separatorStyle = style
        return self
    }

    @discardableResult
    public func scrollToBottom(_ event$:Observable<()>) -> Self {
        event$.asDriver(onErrorJustReturn: ()).drive(onNext:{[weak self] in
            self?.__view.scrollToBottom()
        }) ~ disposeBag
        return self
    }
}

extension UITableView {
    public func scrollToBottom(animated:Bool = false){
        if numberOfSections <= 0 {
            return
        }
        let lastSection = numberOfSections - 1
        let lastRow = numberOfRows(inSection: lastSection) - 1
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)
    }
}
