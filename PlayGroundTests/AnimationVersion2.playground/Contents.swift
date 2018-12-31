//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport


class GestureProfileTap: UITapGestureRecognizer {
    open var userId: String = ""
}
class UserProfileView: UIView {
    
    open var userId: String = ""
    
    init(radio: CGFloat, userId: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.userId = userId
        self.layer.cornerRadius = CGFloat(radio / 2.0)
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        
        return
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MyViewController : UIViewController {
    
    var ovalPath: UIBezierPath?
    var addBubbleBtn : UIButton!
    var profileGroups : [UIView] = []
    var counter = 0
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        view.frame = CGRect(x: 0, y: 0, width: 365, height: 667)
        self.view = view
        
        

        ///CLEANING
        
        //// Oval Drawing
        var ovalPathDiameter = 300.0
         ovalPath = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (ovalPathDiameter / 2.0) , y: Double(view.frame.midY) - (ovalPathDiameter / 2.0), width: ovalPathDiameter, height: ovalPathDiameter))

        ovalPathDiameter = 310.0
        let ovalPathMax = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (ovalPathDiameter / 2.0) , y: Double(view.frame.midY) - (ovalPathDiameter / 2.0), width: ovalPathDiameter, height: ovalPathDiameter))
        let ovalPathLayer = self.createSharpLayer(circle: ovalPath!.cgPath)
       // let ovalPathGuide = self.createSharpLayer(circle: ovalPath.cgPath, guideLayer: true)
        //// Oval 2 Drawing
        var oval2PathDiameter = 230.0
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (oval2PathDiameter / 2.0) , y: Double(view.frame.midY) - (oval2PathDiameter / 2.0), width: oval2PathDiameter, height: oval2PathDiameter))
        oval2PathDiameter = 240
        let oval2PathMax = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (oval2PathDiameter / 2.0) , y: Double(view.frame.midY) - (oval2PathDiameter / 2.0), width: oval2PathDiameter, height: oval2PathDiameter))
        let oval2PathLayer = self.createSharpLayer(circle: oval2Path.cgPath)
        //// Oval 3 Drawing
        var oval3PathDiameter = 70.0
        let oval3Path = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (oval3PathDiameter / 2.0) , y: Double(view.frame.midY) - (oval3PathDiameter / 2.0), width: oval3PathDiameter, height: oval3PathDiameter))
        oval3PathDiameter = 80.0
        let oval3PathMax = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (oval3PathDiameter / 2.0) , y: Double(view.frame.midY) - (oval3PathDiameter / 2.0), width: oval3PathDiameter, height: oval3PathDiameter))
        let oval3PathLayer = self.createSharpLayer(circle: oval3Path.cgPath)
        //// Oval 4 Drawing
        let oval4PathDiameter = 25.0
        let oval4Path = UIBezierPath(ovalIn: CGRect(x: Double(view.frame.midX) - (oval4PathDiameter / 2.0) , y: Double(view.frame.midY) - (oval4PathDiameter / 2.0), width: oval4PathDiameter, height: oval4PathDiameter))
        let oval4PathLayer = self.createSharpLayer(circle: oval4Path.cgPath)
        
        
        view.layer.addSublayer(ovalPathLayer)
        view.layer.addSublayer(oval2PathLayer)
        view.layer.addSublayer(oval3PathLayer)
        view.layer.addSublayer(oval4PathLayer)
        
       
         addBubbleBtn = UIButton(type: .system)
        addBubbleBtn.setTitle("Increment", for: .normal)
        addBubbleBtn.tintColor = .white
        addBubbleBtn.addTarget(self, action: #selector(self.addBubble), for: UIControlEvents.touchUpInside)
        addBubbleBtn.frame = CGRect(x: 50, y: 50, width: 100, height: 30)
        
        
        view.addSubview(addBubbleBtn)
        
        let _ = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
        
        ///view.layer.addSublayer(ovalPathGuide)
        
        
//        for _ in 0...10 {
//            self.createUserBubble(radio: 25.0, animateInPath: oval2Path.cgPath)
//        }
        
        
        self.animateSystem(from: ovalPath!.cgPath, to: ovalPathMax.cgPath, layer: ovalPathLayer)
        self.animateSystem(from: oval2Path.cgPath, to: oval2PathMax.cgPath, layer: oval2PathLayer)
        self.animateSystem(from: oval3Path.cgPath, to: oval3PathMax.cgPath, layer: oval3PathLayer)
        
        
    }
    
    @objc func addBubble() {
        self.createUserBubble(radio: 25.0, animateInPath:ovalPath!.cgPath)
    }
    
    @objc func updateFrame(){
        
        profileGroups.forEach { (profile) in
            guard let presentation = profile.layer.presentation() else{
                return
            }
            let point = CGPoint(x: presentation.frame.origin.x, y: presentation.frame.origin.y)
            let size = CGSize(width: profile.frame.width, height: profile.frame.height)
            
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
    
    func createUserBubble(radio: CGFloat = 35.0, animateInPath: CGPath){
        
        
        let animationFrame = CAKeyframeAnimation(keyPath: "position")
        let randomDuration = CFTimeInterval(self.randomFloat(min: 15, max: 20))
    
        
        
//        let keys = [[0, 0.125, 0.25, 1],
//                    [0, 0.125, 0.25, 0.5, 1],
//                    [0, 0.25, 1],
//                    [0, 0.125, 0.25, 0.5, 1],
//                    [0, 1]]
//        let random = self.randomInt(min: 1, max: keys.count);
//
//        animationFrame.keyTimes = keys[random] as [NSNumber]
        
        animationFrame.autoreverses = true// Bool(truncating: self.randomInt(min: 0, max: 1) as NSNumber)
        animationFrame.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationFrame.duration = randomDuration
        animationFrame.repeatCount = .infinity
        animationFrame.timeOffset = Double(arc4random_uniform(290))
        animationFrame.path = animateInPath
        animationFrame.calculationMode = kCAAnimationPaced
        //animationFrame.beginTime = Double(arc4random_uniform(290))
        //animationFrame.fillMode = kCAFillModeBackwards

        
        let userCircleView = UserProfileView(radio: radio, userId: "El papa\(self.counter)")
        
        //Add Profile
        let photoProfile = #imageLiteral(resourceName: "key.png")
        let profileView = UIImageView(image: photoProfile)
        profileView.frame = CGRect(x: userCircleView.frame.origin.x, y: userCircleView.frame.origin.y, width: 0, height: 0)
        profileView.contentMode = .scaleAspectFill
        profileView.clipsToBounds = true
        profileView.layer.borderColor = UIColor.white.cgColor
        profileView.layer.borderWidth = 0.5
        
        
       
        userCircleView.layer.add(animationFrame, forKey: nil)
        
        userCircleView.addSubview(profileView)
        view.addSubview(userCircleView)
        
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            userCircleView.frame = CGRect(x: 0, y: 0, width: radio, height: radio)
            
            profileView.frame = CGRect(x: userCircleView.frame.origin.x, y: userCircleView.frame.origin.y, width: radio, height: radio)
        }, completion: nil)
        
        
        //Add Action
        let tap = GestureProfileTap(target: self, action: #selector(profileTapped))
         userCircleView.addGestureRecognizer(tap)
        userCircleView.isUserInteractionEnabled = true
        tap.userId = "El papa\(self.counter)"
        
        self.profileGroups.append(userCircleView)
        self.counter += 1
    }
    
    @objc func profileTapped(sender: GestureProfileTap) {
    
        
        for profile in self.profileGroups{
            
            guard let userProfile = profile as? UserProfileView else {
                return
            }
            
            if userProfile.userId  == sender.userId {
                userProfile.layer.convertTime(CACurrentMediaTime(), from: nil)
                userProfile.layer.speed = 0
                userProfile.layer.timeOffset = 0
                
                UIViewPropertyAnimator(duration: 15, curve: UIViewAnimationCurve.easeIn, animations: {
                   // userProfile.frame = CGRect(x: 50, y: 0, width: 40, height: 40)
                    userProfile.layer.cornerRadius = 0
                }).startAnimation()
                print("PROFILEEEEE", sender.userId)
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
        //view.layer.addSublayer(gradientLayer)
        
    }
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

