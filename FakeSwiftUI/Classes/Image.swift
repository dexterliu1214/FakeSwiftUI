//
//  Image.swift
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
import UIImageViewAlignedSwift

open class Image:View {
    public static var urlSession = URLSession.shared
    var __view:UIImageViewAligned
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView = newValue as? UIImageViewAligned {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(image:UIImage?) {
        __view = UIImageViewAligned(image:image)
        super.init()
        _init()
        __view.contentMode = .scaleAspectFit
        __view.clipsToBounds = true
    }
    
    public convenience init(_ name:String) {
        self.init(image:UIImage(named: name))
    }
    
    public convenience init(_ url$:Observable<String>, fadeDuration duration:TimeInterval = 0) {
        let image$ = url$.flatMapLatest{
            $0.get$(urlSession:Image.urlSession).catchErrorJustReturn(Data())
        }
        .map{UIImage(data:$0)}
        .asDriver(onErrorJustReturn: nil)
        self.init(image$, fadeDuration:duration)
    }
    
    public convenience init(_ image$:Driver<UIImage?>, fadeDuration duration:TimeInterval = 0) {
        self.init(image:nil)
        image$.distinctUntilChanged().asDriver(onErrorJustReturn: nil) ~> __view.rx.animated.fadeIn(duration:duration).image ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutClipShape(_ clipShape: Shape) {
         let path = clipShape.getPath(self)
         let layer = CAShapeLayer()
         layer.path = path.cgPath
         layer.frame = self.bounds
         self.__view.layer.mask = layer
     }

    public func aspectRatio(contentMode:ContentMode) -> Self {
        __view.contentMode = contentMode
        return self
    }
    
    public func alignment(_ mask:UIImageViewAlignmentMask) -> Self {
        __view.alignment = mask
        return self
    }
}
enum RequestError:Error
{
    case INVALID_URL
    case Unknow
}
extension String
{
    public func get$(urlSession:URLSession = URLSession.shared) -> Observable<Data> {
        return Observable.create { observer in
            guard let url = URL(string: "\(self)") else {
                observer.on(.error(RequestError.INVALID_URL))
                return Disposables.create {
                }
            }
            let task = urlSession.dataTask(with: url) {data, response, error in
                print("\(url.absoluteString) \(error?.localizedDescription ?? "")")
//                print(response)
                guard let data = data else {
                    observer.on(.error(error ?? RequestError.Unknow))
                    return
                }
                observer.on(.next(data))
                observer.on(.completed)
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
