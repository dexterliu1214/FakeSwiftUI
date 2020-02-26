//
//  AnimationImage.swift
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
import Lottie
import RxAnimated

open class AnimationImage:View
{
    var __view:Lottie.AnimationView
    override public var _view: UIView! {
        get {
            return __view
        }
        set {
            if let newView:Lottie.AnimationView = newValue as? Lottie.AnimationView {
                __view = newView
            } else {
                print("incorrect chassis type for __view")
            }
        }
    }
    
    public init(url$:Observable<String>) {
        __view = Lottie.AnimationView()
        super.init()
        url$.asDriver(onErrorJustReturn: "").drive(onNext:{[weak self] (url:String) in
            guard let self = self else { return }
            async {
                DispatchQueue.main.async {
                    self.isHidden = false
                }
                try await(self.__view.setAnimation(urlString: url))
                DispatchQueue.main.async {
                    self.isHidden = true
                }
            }
        }) ~ disposeBag
        _init()
    }
    
    public init(name:String) {
        __view = Lottie.AnimationView(name:name)
        super.init()
        _init()
    }
    
    override public func shown(_ stream$: Observable<Bool>) -> Self {
        super.shown(stream$)
        stream$.subscribe(onNext:{[weak self] (isShow:Bool) in
            if isShow {
                self?.startAnimate()
            }
        }) ~ disposeBag
        return self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func loopMode(_ mode:LottieLoopMode) -> Self {
        __view.loopMode = mode
        return self
    }
    
    @discardableResult
    public func startAnimate() -> Self {
        __view.play()
        return self
    }
    
    @discardableResult
    public func setAnimation(urlString:String) -> Self {
        __view.setAnimation(urlString: urlString)
        return self
    }
    
    @discardableResult
    public func aspectRatio(contentMode:ContentMode) -> Self {
        __view.contentMode = contentMode
        return self
    }
    
    @discardableResult
    public func animate(_ event$:Observable<()>) -> Self {
        event$.asDriver(onErrorJustReturn: ()).drive(onNext:{[weak self] in
            self?.isHidden = false
            self?.__view.play{[weak self] doen in
                self?.isHidden = true
            }
        }) ~ disposeBag
        return self
    }
}

extension Reactive where Base: Lottie.AnimationView {
    var animationURL: Binder<String> {
        return Binder(self.base) { control, value in
            control.setAnimation(urlString: value)
        }
    }
}

extension Lottie.AnimationView
{
    @discardableResult
    public func setAnimation(urlString:String) -> Promise<()> {
        return Promise<()> { (seal:Resolver) in
            async {
                do {
                    let (data, _) = try await(URLSession.shared.dataTask(.promise, with: URL(string: urlString)!))
                    let animation = try JSONDecoder().decode(Lottie.Animation.self, from: data)

                    DispatchQueue.main.async {
                        self.animation = animation
                        self.alpha = 1
                        self.isHidden = false
                        self.play { isDone in
                            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                    self.alpha = 0
                                }, completion: { _ in
                                    self.isHidden = true
                                    seal.fulfill(())
                                })
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func taskPlay() {
        DispatchQueue.main.async {
            self.isHidden = false
            self.play(completion: { [unowned self] (finish:Bool) in
                if finish {
                    self.isHidden = true
                }
            })
        }
    }
}
