//
//  ViewController.swift
//  FakeSwiftUI
//
//  Created by youga on 02/24/2020.
//  Copyright (c) 2020 youga. All rights reserved.
//

import UIKit
import FakeSwiftUI
import RxSwift
import RxRelay
import RxBinding

#if targetEnvironment(simulator)
import SwiftUI

@available(iOS 13.0.0, *)
struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ViewControllerView{
            GridDemoViewController()
        }
    }
}
#endif

class GridDemoViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var currentIndex:Int = 0
    var items:[Photo] = [
        "https://pic2.ii35.net/photo/30771p8.jpg?rand=cmmxgqth",
        "https://pic2.ii35.net/photo/30771p9.jpg?rand=rquml8t2",
        "https://pic2.ii35.net/photo/30771p6.jpg?rand=m83mpu0v",
        "https://pic2.ii35.net/photo/30771p9.jpg?rand=rquml8t2",
        "https://pic2.ii35.net/photo/30771p10.jpg?rand=jz0zx647",
        ].map{ Photo(id: "1", src: $0, price: "0", ext: "0", isPay: "0")}
    let viewDidLayoutSubviews$ = PublishSubject<()>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer$ =  Observable<Int>.interval(.milliseconds(3100), scheduler: MainScheduler.instance)
        ZStack(
            Grid(columns: .just(1), vSpacing: 0, hSpacing: 0, items: .just(items)) { (cell:ImageCollectionViewCell, model:Photo, row:Int, cv:UICollectionView) in
                cell.model$.accept(model)
                return cell
            }
            .scrollDirection(.horizontal)
            .isPagingEnabled(true)
            .scrollToItem(viewDidLayoutSubviews$) {
                (IndexPath(item: self.currentIndex, section: 0), .centeredHorizontally, false)
            }
            .fill(),
            Text("asdf")
                .onTap{[weak self] _ in
                    print("asdfasdf")
//                    self?.dismiss(animated: true, completion: nil)
                }
//            .shown(timer$.delay(.seconds(1), scheduler: MainScheduler.instance).map{ $0 % 2 == 0 }, nil)
                .do(timer$.map{ _ in }){ view in
                    view.isHidden = false
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
                        view.alpha = view.alpha == 0 ? 1 : 0
                    }, completion: { _ in
                        view.isHidden = view.alpha == 0
                    })
                }
            .color(.black)
            .top(.just(16)).trailing(.just(-16))
        )
            .fill().on(view)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
         viewDidLayoutSubviews$.onNext(())
    }
}

class ImageCollectionViewCell:UICollectionViewCell
{
    var model$ = BehaviorRelay<Photo?>(value:nil)
    var onTapBuy:(_ photo:Photo) -> () = { _ in }
    var onTapPlay:(_ photo:Photo) -> () = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let model$ = self.model$.compactMap{ $0 }
        let image$ = model$.map{ $0.previewImageURL }
        let isVideo$ = model$.map{ $0.isVideo }
        let isLocked$ = model$.map{ $0.isLocked }
        let price$ = model$.map{ $0.price }
        backgroundColor = .red
        ScalableImage(image$)
            .fill().on(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Photo:Codable {
    var id:String
    var src:String
    var price:String
    var ext:String
    var isPay:String
    
    init(id:String, src:String, price:String, ext:String, isPay:String) {
        self.id = id
        self.src = src
        self.price = price
        self.ext = ext
        self.isPay = isPay
    }
    
    var isVideo:Bool {
        get {
            return false
        }
    }
    
    var isImage:Bool {
        get {
            return !isVideo
        }
    }
    
    var isLocked:Bool {
        get {
            return false
        }
    }
    
    var isFree:Bool {
        get {
            return true
        }
    }
    
    var mediaTypeString:String {
        get {
            return isVideo ? "影片" : "照片"
        }
    }
    
    var assetURL:String {
        return src
    }
    
    var previewImageURL:String {
        return src
    }
}
