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
import RxDataSources

open class List<CellType:UITableViewCell>:View,UITableViewDelegate {
    public let tableView:UITableView
    
    var sectionViewBuilder:((Int) -> UIView?)?
    var sectionViewHeightCalculator:((Int) -> CGFloat)?
    var isAutoDeselect = false
    let contentOffset = BehaviorRelay(value:CGPoint(x: 0, y: 0))
    
    public init(style:UITableView.Style) {
        self.tableView = .init(frame:.zero, style:style)
        
        super.init()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(CellType.self, forCellReuseIdentifier: "CELL")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.append(to: self).fillSuperview()
        
        tableView.rx.contentOffset.asObservable()
            .subscribe(onNext:{
                print($0)
            }) ~ disposeBag
    }
    
    public convenience init<ModelType>(items:Observable<[ModelType]>, style:UITableView.Style = .plain, _ builder:@escaping(CellType, ModelType, Int, UITableView) -> UITableViewCell) {
        self.init(style: style)
        
        items.map{ $0.count > 0 } ~> tableView.backgroundView!.rx.isHidden ~ disposeBag
        
        items.asDriver(onErrorJustReturn: []).drive(tableView.rx.items) { (view, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = view.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! CellType
            return builder(cell, element, row, view)
        } ~ disposeBag
        
        tableView.rx.itemSelected
            .subscribe(onNext:{[weak self] in
                 guard let self = self else { return }
                 if self.isAutoDeselect {
                     self.tableView.deselectRow(at: $0, animated: false)
                 }
            }) ~ disposeBag
    }

    public convenience init<ModelType>(items:Observable<[SectionModel<String, ModelType>]>, style:UITableView.Style = .plain, _ builder:@escaping(CellType, IndexPath, ModelType) -> UITableViewCell) {
        self.init(style: style)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ModelType>>(configureCell: { ds, tv, ip, model in
            let cell = tv.dequeueReusableCell(withIdentifier: "CELL", for: ip) as! CellType
            return builder(cell, ip, model)
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
           return dataSource.sectionModels[index].model
        }
        items ~> tableView.rx.items(dataSource: dataSource) ~ disposeBag
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset.accept(scrollView.contentOffset) 
    }
    
    @discardableResult
    public func sectionView(_ builder:@escaping(_ section:Int) -> UIView?, height:@escaping(_ section:Int) -> CGFloat) -> Self {
        tableView.rx.setDelegate(self) ~ disposeBag
        sectionViewBuilder = builder
        sectionViewHeightCalculator = height
        return self
    }
    
    @discardableResult
    public func emptyView(_ view:@escaping () -> View) -> Self {
        view().centerX(.just(0)).centerY(.just(0)).on(self.tableView.backgroundView!)
        return self
    }
    
    @discardableResult
    public func padding(_ insets:UIEdgeInsets = .all(8)) -> Self {
        tableView.contentInset = insets
        return self
    }
    
    @discardableResult
    public func onRefresh(tintColor:UIColor = .white, _ callback:@escaping(_ complete:@escaping() -> ()) -> ()) -> Self {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = tintColor
        refreshControl.rx.controlEvent(.valueChanged).asDriver().drive(onNext:{
            let complete = {
                DispatchQueue.main.async {
                    refreshControl.endRefreshing()
                }                
            }
            callback(complete)            
        }) ~ disposeBag
        tableView.refreshControl = refreshControl
        return self
    }
    
    @discardableResult
    public func itemSelected<T>(_ callback:@escaping(IndexPath, T) -> ()) -> Self {
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(T.self)
        )
           .subscribe(onNext:{
                callback($0, $1)
           }) ~ disposeBag
       return self
    }
    
    @discardableResult
    public func itemDeleted(_ callback:@escaping(IndexPath) -> ()) -> Self {
       tableView.rx.itemDeleted
           .subscribe(onNext:{
                callback($0)
           }) ~ disposeBag
       return self
    }
    
    @discardableResult
    public func onSwipe(_ direction:Set<SwipeDirection>, _ callback:@escaping(UISwipeGestureRecognizer.Direction) -> ()) -> Self {
        tableView.rx.swipeGesture(direction)
            .when(.recognized)
            .subscribe(onNext:{
                callback($0.direction)
            }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func allowSelection(_ value:Bool) -> Self {
        tableView.allowsSelection = value
        return self
    }
    
    @discardableResult
    public func autoDeselect(_ value:Bool) -> Self {
        isAutoDeselect = value
        return self
    }
    
    @discardableResult
    public func separatorStyle(_ style:UITableViewCell.SeparatorStyle) -> Self {
        tableView.separatorStyle = style
        return self
    }

    @discardableResult
    public func scrollToBottom(_ event$:Observable<()>) -> Self {
        event$.asDriver(onErrorJustReturn: ()).drive(onNext:{[weak self] in
            self?.tableView.scrollToBottom()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func scrollToTop(_ event$:Observable<()>) -> Self {
        event$.asDriver(onErrorJustReturn: ()).drive(onNext:{[weak self] in
            self?.tableView.scrollToTop()
        }) ~ disposeBag
        return self
    }
    
    @discardableResult
    public func contentOffset(_ stream$:BehaviorRelay<CGPoint> ) -> Self {
        contentOffset ~> stream$ ~ disposeBag
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
    
    public func scrollToTop(animated:Bool = true){
        scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: animated)
    }
}
