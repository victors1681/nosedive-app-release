//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let counterLabel = CountingRating()
        counterLabel.frame = CGRect(x: 150, y: 200, width: 200, height: 50)
        counterLabel.text = "Hello World!"
        counterLabel.font = UIFont(name: "Verdana", size: 30)
        counterLabel.textColor = .black
        
        
        counterLabel.count(fromValue: 0.0, toValue: 5, withDuration: 3, andAnimationType: .EaseIn, andCounterType: .Float)
        
        view.addSubview(counterLabel)
        
        self.view = view
    }
}



class CountingRating: UILabel {
    
    enum CounterAnimationType {
        case Linear  // f(x) = x
        case EaseIn  // f(x) = x^3
        case EaseOut // f(x) = (1-x)^3
    }
    
    enum CounterType {
        case Int
        case Float
    }
    
    let counterVelocity: Float = 3.0
    
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!
    
    var counterAnimationType: CounterAnimationType!
    var counterType: CounterType!
    
    var timer: Timer?
    
    var animationInProgress = false
    
    var currentCounterValue: Float{
        if progress >= duration {
            return endNumber
        }
        
        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)
        
        return startNumber + (update * (endNumber - startNumber))
    }
    
    func count(fromValue: Float, toValue: Float, withDuration duration:TimeInterval, andAnimationType animationType: CounterAnimationType, andCounterType counterType: CounterType) {
        
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.counterType = counterType
        self.counterAnimationType = animationType
        
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        
        if duration == 0 {
            updateText(value: toValue)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CountingRating.updateValue), userInfo: nil, repeats: true)
        
    }
    
   @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration {
            invalidateTimer()
            progress = duration
        }
    
    if(!animationInProgress){
        updateText(value: currentCounterValue)
       // animationInProgress = true;
    }
    }
    
    func invalidateTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func updateText(value: Float){
        
        //self.fade()
//        UILabel.transition(with: self, duration: 0.05, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//            self.alpha = 0
//        }) { (tes) in
//            self.alpha = 1
//            //print("completed")
//            self.animationInProgress = false;
//        }
//
        switch counterType! {
        case .Int:
            self.text = "\(Int(value))"
        case .Float:
             self.text = String(format: "%.2f", value)
        }
        
    }
    
    func updateCounter(counterValue: Float)->Float {
        
        switch counterAnimationType! {
        case .Linear:
            return counterValue
        case .EaseIn:
            return powf(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - powf(1.0 - counterValue, counterVelocity)
    }
  }
    
//    func fade(){
//        let fadeOutAnimation = CABasicAnimation()
//        fadeOutAnimation.keyPath = "opacity"
//        fadeOutAnimation.timingFunction = CAMediaTimingFunction(name:
//            kCAMediaTimingFunctionEaseInEaseOut)
//         fadeOutAnimation.fromValue = 1
//        fadeOutAnimation.toValue = 0
//        fadeOutAnimation.duration = 0.25
//
//        fadeOutAnimation.delegate = self
//        self.layer.add(fadeOutAnimation, forKey: kCATransitionFade)
//    }
    
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        print("finished")
//        animationInProgress = false;
//    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
