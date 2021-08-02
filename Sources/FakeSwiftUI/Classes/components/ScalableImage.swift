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

open class ScalableImage:View
{
    let scrollView = UIScrollView()
    let imageView = UIImageView()

    public init(_ image$:Driver<UIImage?>) {
        super.init()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.append(to: self).fillSuperview()
        
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
                self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                self.scrollView.contentSize = self.imageView.bounds.size                
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
			.flatMapLatest{ $0.get$().catchAndReturn(Data()) }
                .map{UIImage(data:$0)}
                .asDriver(onErrorJustReturn: nil)
        self.init(image$)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.image == nil {
            return
        }
        self.setZoomScale()
        self.recenterImage()
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
    
    func recenterImage(){
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let hs = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        let vs = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        scrollView.contentInset = .init(top: vs, left: hs, bottom: vs, right: hs)
    }
}

extension ScalableImage:UIScrollViewDelegate
{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
}
