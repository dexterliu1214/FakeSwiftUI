//
//  ScalableImage.swift
//  ios-webrtc-client
//
//  Created by youga on 2020/1/14.
//  Copyright © 2020 dexterliu1214. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RxSwift
import RxCocoa
import RxBinding

open class Scrollable:View
{
    let view = UIScrollView()
    
    public init(_ subview:UIView) {
        super.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.append(to: self).fillSuperview()
        
        self.view.addSubview(subview)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.contentSize = self.view.subviews.first!.frame.size
        }
    }
}

open class ScalableImage:View
{
    let scrollView = UIScrollView()
    let imageView = UIImageView()

    public init(_ image$:Driver<UIImage?>) {
        super.init()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.append(to: self).fillSuperview()
        
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.append(to: scrollView)
        
        imageView.rx.tapGesture() { gesture, _ in
            gesture.numberOfTapsRequired = 2
        }.when(.recognized)
            .subscribe(onNext:{[weak self] _ in
                guard let self = self else { return }
                if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
                    self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
                } else {
                    self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
                }
            }) ~ disposeBag
        image$
            .drive(onNext:{[weak self] in
                guard let self = self else { return }
                self.imageView.image = $0
                guard let size = $0?.size else { return }
                self.scrollView.contentSize = CGSize(width: size.width, height: size.height)
                self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                self.setZoomScale()
               
                if size.width >= size.height {
                    let newContentOffsetX = (self.scrollView.contentSize.width/2) - (self.bounds.size.width/2)
                    self.scrollView.setContentOffset(CGPoint(x: newContentOffsetX, y: 0) , animated: false)
                } else {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0) , animated: false)
                }
            }) ~ disposeBag
    }
    
    public convenience init(_ url$:Observable<String>) {
        let image$ = url$
                .flatMapLatest{ $0.get$().catchErrorJustReturn(Data()) }
                .map{UIImage(data:$0)}
                .asDriver(onErrorJustReturn: nil)
        self.init(image$)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
            
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = max(widthScale, heightScale)
        scrollView.zoomScale = heightScale
    }
}

extension ScalableImage:UIScrollViewDelegate
{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let xCenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : scrollView.center.x
        let yCenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : scrollView.center.y;
        imageView.center = CGPoint(x: xCenter, y: yCenter)
    }
}
