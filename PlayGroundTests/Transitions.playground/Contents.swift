//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


//extension UIView {
//    func fadeTransition(_ duration:CFTimeInterval) {
//        let animation = CATransition()
//        animation.timingFunction = CAMediaTimingFunction(name:
//            kCAMediaTimingFunctionEaseInEaseOut)
//        animation.type = kCATransitionFade
//        animation.duration = duration
//        layer.add(animation, forKey: kCATransitionFade)
//    }
//}

class MyViewController : UIViewController, CAAnimationDelegate {
    
    var button: UIButton = UIButton(type: UIButtonType.system)
    var label: UILabel = UILabel()
    
    override func loadView() {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 367, height: 667)
        view.backgroundColor = .white
        
 
        
        button.setTitle("Click me", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        button.addTarget(self, action: #selector(self.actionSelector), for: UIControlEvents.touchDown)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
  
        label = UILabel()
        label.text = "Label Text"
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionSelector))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
        view.addSubview(label)
       
        
        
        //Animate along path
        
        let position = CGPoint(x: (view.frame.width / 2.0 ), y: (view.frame.height / 2.0 ))
        let path = UIBezierPath(arcCenter: position, radius: 90, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        
        //Layer only for reference
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 90, height: 90))
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        //Timer: To update the button frame
        Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(updateFrame), userInfo: nil, repeats: true)
       
        //Animate the Button
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.path = path.cgPath
        animation.calculationMode = kCAAnimationCubic
        animation.duration = 20
        //animation.repeatCount = .infinity
        
       // self.button.layer.add(animation, forKey: "button")
      
        label.layer.add(animation, forKey: "labelAnimation")
        
        view.layer.addSublayer(shapeLayer)
        view.addSubview(button)
        
        self.view = view
        
    }
    
    
    //Timer Selector
    @objc func updateFrame(){
        let layer = button.layer.presentation()
        
        let point = CGPoint(x: layer!.frame.origin.x, y: layer!.frame.origin.y)
        let size = CGSize(width: layer!.frame.width, height: layer!.frame.height)
        
        button.frame = CGRect(origin: point, size: size)
        
        let layerLabel = label.layer.presentation()!
        
    
        let pointLb = CGPoint(x: layerLabel.frame.origin.x, y: layerLabel.frame.origin.y)
        let sizeLb = CGSize(width: layerLabel.frame.width, height: layerLabel.frame.height)
       
        label.frame = CGRect(origin: pointLb, size: sizeLb)
    
    }
    
    //Button Selector
    @objc func actionSelector(){
        print("Button Pressed")
    }
 
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
