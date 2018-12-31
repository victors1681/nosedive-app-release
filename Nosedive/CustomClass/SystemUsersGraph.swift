//
//  SystemUsersGraph.swift
//  Nosedive
//
//  Created by Victor Santos on 1/9/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Spring
import Kingfisher

protocol SystemUserGraphDelegate {
    func didTapCenterReload()
}

class SystemUsersGraph: UIView {
    
    var delegateProtocol: SystemUserGraphDelegate?
    var ovalPath: UIBezierPath?
    var oval2Path: UIBezierPath?
    var oval3Path: UIBezierPath?
    
    var profileGroups : [UIView] = []
    var counter = 0
    var delegate: UIViewController?
    var destinationController: String = "ratingView"
    var marginTop:CGFloat = 80.0
    var updateFrameTimer: Timer? = nil {
        willSet {
            updateFrameTimer?.invalidate()
        }
    }
    
    let smallScreen : Bool = {
       let size =  Device.IS_4_INCHES_OR_SMALLER()
        return size
    }()
    
    enum SystemLevel {
        case one
        case two
        case three
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds);
        
        return;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
        
    }
    
    
    func setup() {
        
        self.backgroundColor = UIColor.clear
        
        ///CLEANING
     
        //// Oval Drawing
        var ovalPathDiameter = smallScreen ? 180.0 : 300.0
        ovalPath = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (ovalPathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (ovalPathDiameter / 2.0), width: ovalPathDiameter, height: ovalPathDiameter))
        
        ovalPathDiameter = ovalPathDiameter * 1.05 //310.0
        let ovalPathMax = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (ovalPathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (ovalPathDiameter / 2.0), width: ovalPathDiameter, height: ovalPathDiameter))
        let ovalPathLayer = self.createSharpLayer(circle: ovalPath!.cgPath)
        // let ovalPathGuide = self.createSharpLayer(circle: ovalPath.cgPath, guideLayer: true)
        //// Oval 2 Drawing
        var oval2PathDiameter = smallScreen ? 120.0 : 230.0
        oval2Path = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (oval2PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval2PathDiameter / 2.0), width: oval2PathDiameter, height: oval2PathDiameter))
        oval2PathDiameter = oval2PathDiameter * 1.05 //240
        let oval2PathMax = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (oval2PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval2PathDiameter / 2.0), width: oval2PathDiameter, height: oval2PathDiameter))
        let oval2PathLayer = self.createSharpLayer(circle: oval2Path!.cgPath)
        //// Oval 3 Drawing
        var oval3PathDiameter = smallScreen ? 70.0 : 70.0
        oval3Path = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (oval3PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval3PathDiameter / 2.0), width: oval3PathDiameter, height: oval3PathDiameter))
        oval3PathDiameter = oval3PathDiameter * 1.05 //80.0
        let oval3PathMax = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (oval3PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval3PathDiameter / 2.0), width: oval3PathDiameter, height: oval3PathDiameter))
        let oval3PathLayer = self.createSharpLayer(circle: oval3Path!.cgPath)
        //// Oval 4 Drawing
        let oval4PathDiameter = smallScreen ? 25.0 : 25.0
        let oval4Path = UIBezierPath(ovalIn: CGRect(x: Double(frame.midX) - (oval4PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval4PathDiameter / 2.0), width: oval4PathDiameter, height: oval4PathDiameter))
        let oval4PathLayer = self.createSharpLayer(circle: oval4Path.cgPath)
        
        
        layer.addSublayer(ovalPathLayer)
        layer.addSublayer(oval2PathLayer)
        layer.addSublayer(oval3PathLayer)
        //layer.addSublayer(oval4PathLayer)
        
        
       self.startUpdateFrame()
        
        
        self.animateSystem(from: ovalPath!.cgPath, to: ovalPathMax.cgPath, layer: ovalPathLayer)
        self.animateSystem(from: (oval2Path?.cgPath)!, to: oval2PathMax.cgPath, layer: oval2PathLayer)
        self.animateSystem(from: (oval3Path?.cgPath)!, to: oval3PathMax.cgPath, layer: oval3PathLayer)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(reloadUsers))
        let centerCircle = UIView()
        centerCircle.layer.addSublayer(oval4PathLayer)
        centerCircle.frame = CGRect(x: Double(frame.midX) - (oval4PathDiameter / 2.0) , y: Double(frame.midY + marginTop) - (oval4PathDiameter / 2.0), width: 25, height: 25)
        self.addSubview(centerCircle)
        centerCircle.addGestureRecognizer(tap)
        centerCircle.isUserInteractionEnabled = true
        
        layer.addSublayer(oval4PathLayer)
        
    }

    
    @objc func reloadUsers(){
        print("reload!!!!")
        delegateProtocol?.didTapCenterReload()
    }
    
    
    /*
     *       BUBLE CREATION
     */
    
    func createUserBubble(level:SystemLevel, userData:UserModel.User, radio: CGFloat = 30.0){
        
        let radio = smallScreen ? 20: radio
        var animateInPath: CGPath
        
        switch level {
        case .one:
            animateInPath = (ovalPath?.cgPath)!
        case .two:
            animateInPath = (oval2Path?.cgPath)!
        case .three:
            animateInPath = (oval3Path?.cgPath)!
        }
        
        
        let userCircleView = UserProfileImageView(radio: radio, userData: userData, path: animateInPath)
        
        //Add Profile
        let url = URL(string: userData.photoUrl)
        
        //let profileView = UIImageView()
        let imgPlacehorder = UIImage(named: "placeholder")
        
        userCircleView.kf.setImage(with: url, placeholder: imgPlacehorder)
        
        
        let (animationFrame, opacityAnimation, animationSize) = getRandomAnimationForCirculeProfile(animateInPath: animateInPath)
        
        userCircleView.alpha = 0
        userCircleView.frame = CGRect(x: userCircleView.frame.origin.x , y: userCircleView.frame.origin.y, width: radio, height: radio)
        
        userCircleView.layer.add(animationFrame, forKey: "CiculeProfile")
        userCircleView.layer.add(opacityAnimation, forKey: "CircleProfileOpacity")
        userCircleView.layer.add(animationSize, forKey: "CircleProfileSize")
        
        
        self.addSubview(userCircleView)
        
        //Add Action
        let tap = GestureProfileTap(target: self, action: #selector(self.profileTapped))
        userCircleView.addGestureRecognizer(tap)
        userCircleView.isUserInteractionEnabled = true
        tap.userId = userData.id
        
        self.profileGroups.append(userCircleView)
        self.counter += 1
        
        
        UIViewPropertyAnimator(duration: 1, dampingRatio: 0.3) {
            //userCircleView.frame.size = CGSize(width: radio, height: radio)
            userCircleView.alpha = 1
            }.startAnimation(afterDelay: 0)
    }
    
    func stopUpdateFrame(){
        updateFrameTimer?.invalidate()
    }
    
    func startUpdateFrame(){
        updateFrameTimer = Timer.scheduledTimer(timeInterval: 0.020, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
    }
    
    @objc func updateFrame(){
        
        profileGroups.forEach { (profile) in
            guard let presentation = profile.layer.presentation() else{
                return
            }
            
            let point = CGPoint(x: presentation.frame.origin.x, y: presentation.frame.origin.y)
            let size = CGSize(width: profile.frame.width, height: profile.frame.height)
            
            if(point.x.isNaN || point.y.isNaN){
                return
            }
            profile.frame = CGRect(origin: point, size: size)
        }
        
    }
    
    
    func animateSystem(from: CGPath, to: CGPath, layer: CAShapeLayer) {
        
        let aniFrame = CABasicAnimation(keyPath: "path")
        aniFrame.duration = 4
        aniFrame.autoreverses = true
        aniFrame.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        aniFrame.fromValue = from
        aniFrame.toValue = to
        aniFrame.repeatCount = MAXFLOAT
        aniFrame.timeOffset = Double(arc4random_uniform(290))
        
        layer.add(aniFrame, forKey: aniFrame.keyPath)
        
    }
    
    func getRandomAnimationForCirculeProfile(animateInPath: CGPath, currentPosition: Bool = false) ->  (CAKeyframeAnimation, CABasicAnimation, CABasicAnimation) {
        
        let animationOpacity = CABasicAnimation(keyPath: "opacity")
        animationOpacity.duration = 0.5
        animationOpacity.fromValue = 0
        animationOpacity.toValue = 1
        
        let animationSize = CABasicAnimation(keyPath: "transform.scale")
        animationSize.duration = 0.5
        animationSize.fromValue = 0
        animationSize.toValue = 1
        
        
        let animationFrame = CAKeyframeAnimation(keyPath: "position")
        let randomDuration = CFTimeInterval(self.randomFloat(min: 20, max: 25))
        
        
        animationFrame.autoreverses = true// Bool(truncating: self.randomInt(min: 0, max: 1) as NSNumber)
        animationFrame.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationFrame.duration = randomDuration
        animationFrame.repeatCount = .infinity
        
        animationFrame.path = animateInPath
        animationFrame.calculationMode = kCAAnimationPaced
        
        if !currentPosition {
            animationFrame.timeOffset = Double(arc4random_uniform(290))
        }
        
        return (animationFrame, animationOpacity, animationSize)
    }
    
    
    /*
     Remove all objects from super view and Profile Group
     */
    func removeAllUsers(){
        profileGroups.removeAll()
        let views = self.subviews
        for view in views {
            if let userProfile = view as? UserProfileImageView  {
                if let userData = userProfile.userData {
                    if userData.id != "" {
                        userProfile.removeFromSuperview()
                    }
                }
            }
            
        }
    }
    
    
    
    func randomInt(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    func randomDouble(min: Double, max: Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
    
    
    func createSharpLayer(circle: CGPath, guideLayer: Bool = false) -> CAShapeLayer {
        
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = circle
        circleShapeLayer.frame = CGRect(x:0, y:0, width:500, height:500);
        circleShapeLayer.backgroundColor = UIColor.clear.cgColor
        
        circleShapeLayer.fillColor = (guideLayer) ? UIColor.clear.cgColor : UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.20).cgColor
        circleShapeLayer.strokeColor = (guideLayer) ? UIColor.green.cgColor : UIColor.white.cgColor
        circleShapeLayer.lineWidth = 0.5
        
        return circleShapeLayer
        
    }
    
    //MARK: Use this method to stop animation after move to another screen
    func stopAllGraphAnimation(){
        for profile in profileGroups{
            
            guard let userProfile = profile as? UserProfileImageView else {
                return
            }
                //Stop animation
                userProfile.stopAnimation()
                //Stop to update the frame
                self.stopUpdateFrame()
        }
    }
    
    @objc func profileTapped(sender: GestureProfileTap) {
        
        
        for profile in profileGroups{
            
            guard let userProfile = profile as? UserProfileImageView else {
                return
            }
            
            if userProfile.userData?.id  == sender.userId {
                
                //Stop animation
                userProfile.stopAnimation()
                //Stop to update the frame
                self.stopUpdateFrame()
                
                //Present Next View
                delegate?.performSegue(withIdentifier: destinationController, sender: userProfile)
                
            }
        }
        
    }
    
    
}



class GestureProfileTap: UITapGestureRecognizer {
    open var userId: String = ""
    
}




