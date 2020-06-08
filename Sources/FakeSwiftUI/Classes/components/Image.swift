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
import RxAnimated

open class Image:View {
    public static var urlSession:URLSession = URLSession.shared
    
    let imageView:UIImageView

    public init(image:UIImage?) {
        imageView = UIImageView(image:image)
        super.init()
        view = imageView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
    
    public convenience init(_ name:String) {
        self.init(image:UIImage(named: name))
    }
    
    public convenience init(_ url$:Observable<String>, fadeDuration duration:TimeInterval = 0) {
        let image$:Observable<UIImage?> = url$.flatMapLatest{
            $0.get$(urlSession:Image.urlSession).catchErrorJustReturn(Data())
        }
        .map{UIImage(data:$0)}
        
        self.init(image$, fadeDuration:duration)
    }
    
    public convenience init(_ image$:Observable<UIImage?>, fadeDuration duration:TimeInterval = 0) {
        self.init(image:nil)
        image$.distinctUntilChanged().asDriver(onErrorJustReturn: nil) ~> imageView.rx.animated.fadeIn(duration:duration).image ~ disposeBag
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    public func aspectRatio(contentMode:ContentMode) -> Self {
        imageView.contentMode = contentMode
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
            guard let url:URL = URL(string: "\(self)") else {
                observer.on(.error(RequestError.INVALID_URL))
                return Disposables.create {
                }
            }
            let task:URLSessionDataTask = urlSession.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                print("\(url.absoluteString) \(error?.localizedDescription ?? "")")
//                print(response)
                guard let data:Data = data else {
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
