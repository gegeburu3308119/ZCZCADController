//
//  ZCAdUIViewController.swift
//  ZCAD
//
//  Created by 张葱 on 17/8/15.
//  Copyright © 2017年 张葱. All rights reserved.
//

import UIKit


fileprivate let Z_WIDTH = UIScreen.main.bounds.size.width
fileprivate let Z_HEIGHT = UIScreen.main.bounds.size.height

enum SkipButtonType{
    case   none
    case   timer
    case   circle

}
enum SkipBUttonPosition{
    case  rightTop
    case rightBotton
    case  rightAdViewBottom

}

enum TransitionType{

    case none
    case rippleEffect
    case  fade
    case flipFromTop            /// 上下翻转
    case filpFromBottom
    case filpFromLeft           /// 左右翻转
    case filpFromRight



}


class ZCAdUIViewController: UIViewController {

    //默认3s
    fileprivate var defalutTime = 3
    
    //广告距离底部
    fileprivate var AdViewBootomDistance : CGFloat = 100
    
    fileprivate  var transionType : TransitionType = .fade
    
    fileprivate var skipBtnPosion : SkipBUttonPosition = .rightTop
    
    fileprivate var skipBtnType : SkipButtonType = .timer{
        didSet{
            let btnWidth : CGFloat = 60
            let btnHeight : CGFloat = 30
            var y : CGFloat = 0
            
            switch skipBtnPosion {
            case .rightBotton:
                y = Z_HEIGHT - 50
            case .rightAdViewBottom:
                y = Z_HEIGHT - AdViewBootomDistance - 50
            default:
                y = 30
                
            }
            
            let timerRect = CGRect(x: Z_WIDTH - 70, y: y, width: btnWidth, height: btnHeight)
            
            let circleRect = CGRect(x:  Z_WIDTH - 50, y: y, width: btnHeight, height: btnHeight)
            
            skipBtn.frame = self.skipBtnType == .timer ? timerRect : circleRect
            
            skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: self.skipBtnType == .timer ? 13.5 : 12)
            
            skipBtn.setTitle(self.skipBtnType == .timer ? "\(self.adDuration) 跳过" : "跳过", for: .normal)
            
        
        }
    
    }
    
    fileprivate var adDuration : Int = 0
    
    fileprivate var originnalTimer : DispatchSourceTimer?
    
    fileprivate var dataTimer : DispatchSourceTimer?
    
    fileprivate var adImageViewClick : (()->())?
    
    fileprivate var competion : (()->())?
    
    fileprivate var animationLayer : CAShapeLayer?
    
    /// ===========================
   
    
    /// 启动页
    /// ===========================
    fileprivate lazy var launchImageView: UIImageView = {
        let imgView = UIImageView.init(frame: UIScreen.main.bounds)
        imgView.image = self.getLaunchImage()
        return imgView
    }()
    //广告图
    fileprivate lazy var launchAdImgView: UIImageView = {
    
     let height = Z_HEIGHT - self.AdViewBootomDistance
     let imgView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Z_WIDTH, height: height))
     imgView.isUserInteractionEnabled = true
     imgView.alpha = 0.2
     let tap = UITapGestureRecognizer.init(target: self, action: #selector(launchAdTapAction(sender:)))
     imgView.addGestureRecognizer(tap)
     return imgView
    
    }()
    
    fileprivate lazy  var skipBtn : UIButton = {
        let button = UIButton.init(type : .custom)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(skipBtnClick), for: .touchUpInside)
        return button
    }()
    
   @objc fileprivate func launchAdTapAction(sender: UITapGestureRecognizer){
      dataTimer?.cancel()
    launchAdVCRemove {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) { 
            if self.adImageViewClick != nil{
                self.adImageViewClick!()
            }
        }
    }
    
    }
    
    
  @objc  fileprivate func skipBtnClick(){
      dataTimer?.cancel()
        
        launchAdVCRemove(completion: nil)
    }
    
    
    fileprivate func launchAdVCRemove(completion: (()->())?){
    
    
    
    let trans  = CATransition()
    trans.duration = 0.5
        switch transionType{
            
        case .rippleEffect:
            trans.type = "rippleEffect"
        case .filpFromLeft:
            trans.type = "oglFlip"
            trans.subtype = kCATransitionFromLeft
        case .filpFromRight:
            trans.type = "oglFlip"
            trans.subtype = kCATransitionFromRight
        case .flipFromTop:
            trans.type = "oglFlip"
            trans.subtype = kCATransitionFromTop
        case .filpFromBottom:
            trans.type = "oglFlip"
            trans.subtype = kCATransitionFromBottom
        default:
            trans.type = "fade"
        }
    UIApplication.shared.keyWindow?.layer.add(trans, forKey: nil)
    
        if self.competion != nil {
            self.competion!()
            if competion != nil {
                competion!()
            }
        }
    

    
    }
    
    
    
    convenience init(defaultDuration: Int = 3,completion : (()->())?){
    
        self.init(nibName: nil ,bundle : nil)
        if  defaultDuration >= 1  {
            self.defalutTime = defaultDuration
        }
        self.competion = completion
    
    }
    
   override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(launchImageView)
        
        startTimer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ZCAdUIViewController{

    
    /// - Parameters:
    ///   - url: 路径
    ///   - adDuartion:             显示时间
    ///   - skipBtnType:            跳过按钮类型，默认 倒计时+跳过
    ///   - skipBtnPosition:        跳过按钮位置，默认右上角
    ///   - adViewBottomDistance:   图片距底部的距离，默认100
    ///   - transitionType:         过渡的类型，默认没有
    ///   - adImgViewClick:         点击广告回调
    ///   - completion:             完成回调
    
    func setAdParams(url: String, adDuartion: Int, skipBtnType: SkipButtonType = .timer, skipBtnPosition: SkipBUttonPosition = .rightTop,  adViewBottomDistance: CGFloat = 100, transitionType: TransitionType = .rippleEffect, adImgViewClick: (()->())?) {
        
        self.AdViewBootomDistance = adViewBottomDistance
        self.skipBtnPosion = skipBtnPosition
        self.transionType = transitionType
        self.adDuration = adDuartion
        self.skipBtnType = skipBtnType
        if adDuration < 1 {
            self.adDuration = 1
        }
        
        
        if url != "" {
            view.addSubview(launchAdImgView)
            self.launchAdImgView.setImage(withurl: url, completion: { 
                
                self.skipBtn.removeFromSuperview()
                if self.animationLayer != nil {
                    self.animationLayer?.removeFromSuperlayer()
                    self.animationLayer = nil
                }
                
                if self.skipBtnType != .none{
                  self.view.addSubview(self.skipBtn)
                    if self.skipBtnType == .circle{
                       self.addLayer()
                }
                }
                
                if self.originnalTimer?.isCancelled == true {
                
                   return
                }
                
                self.adStartTimer()
                
                UIView.animate(withDuration: 0.8, animations: { 
                    self.launchAdImgView.alpha = 1
                })
            
                
            })
            
            
            self.adImageViewClick = adImgViewClick
            
            
        }
        

        
    }

    //添加动画
    fileprivate func addLayer(){
        let berierPath = UIBezierPath.init(ovalIn: skipBtn.bounds)
        animationLayer = CAShapeLayer()
        animationLayer?.path = berierPath.cgPath
        animationLayer?.lineWidth = 2
        animationLayer?.strokeColor = UIColor.red.cgColor
        animationLayer?.fillColor = UIColor.clear.cgColor
        let animation = CABasicAnimation.init(keyPath: "strokeStart")
        animation.duration = Double(adDuration)
        animation.fromValue = 0
        animation.toValue = 1
        animationLayer?.add(animation, forKey: nil)
        skipBtn.layer.addSublayer(animationLayer!)
        
    }
    




}

extension ZCAdUIViewController{

    fileprivate func startTimer(){
       originnalTimer = DispatchSource.makeTimerSource(flags: [],queue: DispatchQueue.global())
        originnalTimer?.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.milliseconds(defalutTime))
        originnalTimer?.setEventHandler(handler: { 
            
            if self.defalutTime == 0{
                DispatchQueue.main.async {
                    self.launchAdVCRemove(completion: nil)
                }
            
            }
            self.defalutTime -= 1
            
        })
    
        originnalTimer?.resume()
    
    
    }
    
    
    
    fileprivate func adStartTimer(){
    
        if self.originnalTimer?.isCancelled == false {
            self.originnalTimer?.cancel()
        }
        
        
        dataTimer = DispatchSource.makeTimerSource(flags: [],queue: DispatchQueue.global())
        dataTimer?.scheduleRepeating(deadline: DispatchTime.now(),interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.milliseconds(adDuration))
        
        dataTimer?.setEventHandler(handler: { 
            self.skipBtn.setTitle(self.skipBtnType == .timer ? "\(self.adDuration)跳过" : "跳过",for : .normal)
            if self.adDuration == 0{
                DispatchQueue.main.async {
                     self.launchAdVCRemove(completion: nil)
                }
            
             self.adDuration -= 1
            }
            
            self.dataTimer?.resume()
            
            
            
        })
    
    
    }
    
    
}

//获取启动页

extension ZCAdUIViewController{
    
    fileprivate func getLaunchImage() -> UIImage {
        if (assetsLaunchImage() != nil) || (storyboardLaunchImage() != nil) {
            return assetsLaunchImage() == nil ? storyboardLaunchImage()! : assetsLaunchImage()!
        }
        return UIImage()
    }
    
    /// 获取Assets里LaunchImage
    /// ===================================
    fileprivate func assetsLaunchImage() -> UIImage? {
        
        let size = UIScreen.main.bounds.size
        
        let orientation = "Portrait" //横屏 "Landscape"
        
        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] else {
            return nil
        }
        
        for dict in launchImages {
            
            let imageSize = CGSizeFromString(dict["UILaunchImageSize"] as! String)
            
            if __CGSizeEqualToSize(imageSize, size) && orientation == (dict["UILaunchImageOrientation"] as! String) {
                
                let launchImageName = dict["UILaunchImageName"] as! String
                let image = UIImage.init(named: launchImageName)
                return image
                
            }
        }
        return nil
    }
    
    /// 获取LaunchScreen.Storyboard
    /// ===================================
    fileprivate func storyboardLaunchImage() -> UIImage? {
        
        guard let storyboardLaunchName = Bundle.main.infoDictionary?["UILaunchStoryboardName"] as? String,
            let launchVC = UIStoryboard.init(name: storyboardLaunchName, bundle: nil).instantiateInitialViewController() else {
                return nil
        }
        let view = launchVC.view
        view?.frame = UIScreen.main.bounds
        let image = viewConvertImage(view: view!)
        return image
        
    }
    
    /// view转换图片
    fileprivate func viewConvertImage(view: UIView) -> UIImage {
        
        let size = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
}





