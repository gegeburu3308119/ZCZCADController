//
//  UIImageView+Gif.swift
//  ZCAD
//
//  Created by 张葱 on 17/8/15.
//  Copyright © 2017年 张葱. All rights reserved.
//

import UIKit
import ImageIO

extension UIImageView{

    func setImage(withurl : String,completion: (()->())? ) {
        DispatchQueue.global().async {
           guard let data = try? Data.init(contentsOf: URL.init(string:withurl )!) else{
            return

            }
            
            guard let imageSorce = CGImageSourceCreateWithData(data as CFData, nil) else{
                
                return
            }
            
            let totalCount = CGImageSourceGetCount(imageSorce)
            var images = [UIImage]()
            var gifDurration = 0.0
            
            for i in 0 ..< totalCount{
                
                // 获取对应帧的 CGImage
                guard let imageRef = CGImageSourceCreateImageAtIndex(imageSorce, i, nil) else {
                    return
                }
                
                if totalCount == 1 {
                    /// 单张图片
                    gifDurration = Double.infinity
                    guard let imageData = try? Data.init(contentsOf: URL.init(string: withurl)!),
                        let image = UIImage.init(data: imageData) else {
                            return
                    }
                    images.append(image)
                    
                } else{
                    /// gif
                    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSorce, i, nil),
                        let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                        let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else {
                            return
                    }
                    
                    gifDurration += frameDuration.doubleValue
                    // 获取帧的img
                    let image = UIImage.init(cgImage: imageRef, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)
                    
                    images.append(image)
                }
            }
            
            DispatchQueue.main.async {
                self.animationImages = images
                self.animationDuration = gifDurration
                self.animationRepeatCount = 0
                self.startAnimating()
                
                
            }
            
            if completion != nil{
            
                completion!()
            }
            
            
            
        }
        
        
        
    }







}
