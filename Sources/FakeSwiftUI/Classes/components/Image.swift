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

extension UIImageView
{
    public convenience init(url:String) {
        self.init()
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data:data)
            }
        }.resume()
    }
}

open class Image:View {
    public static var urlSession:URLSession = URLSession.shared
    
    let imageView = UIImageView(image:nil)

    public override init() {
        super.init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.append(to: self).fillSuperview()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
    
    public convenience init(_ url$:Observable<String>, animationSink:((AnimatedSink<UIImageView>) -> (AnimatedSink<UIImageView>))? = nil) {
        self.init()
        let animationSink = animationSink?(imageView.rx.animated) ?? imageView.rx.animated.fade(duration: 0)
		url$.distinctUntilChanged().flatMapLatest{ $0.get$(urlSession:Image.urlSession).catchAndReturn(Data()) }
            .map{UIImage(data:$0)}.asDriver(onErrorJustReturn: nil) ~> animationSink.image ~ disposeBag
    }
    
    public convenience init(_ url:String, animationSink:((AnimatedSink<UIImageView>) -> (AnimatedSink<UIImageView>))? = nil) {
        self.init(.just(url), animationSink:animationSink)
    }
    
    public convenience init(_ image$:Observable<UIImage?>, animationSink:((AnimatedSink<UIImageView>) -> (AnimatedSink<UIImageView>))? = nil) {
        self.init()
        let animationSink = animationSink?(imageView.rx.animated) ?? imageView.rx.animated.fade(duration: 0)
        image$.distinctUntilChanged().asDriver(onErrorJustReturn: nil) ~> animationSink.image ~ disposeBag
    }
    
    public convenience init(_ image:UIImage?, animationSink:((AnimatedSink<UIImageView>) -> (AnimatedSink<UIImageView>))? = nil) {
        self.init(.just(image), animationSink:animationSink)
    }
    
    public convenience init(name:String, animationSink:((AnimatedSink<UIImageView>) -> (AnimatedSink<UIImageView>))? = nil) {
        self.init(.just(UIImage(named: name)), animationSink:animationSink)
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
