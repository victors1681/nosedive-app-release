//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    let screenWidth = 375.0
    let screenHeight = 667.0
    let arrowLimit = 3
    
    override func loadView() {
        
        let view = UIView()
        
        view.backgroundColor = .black
 
        self.view = view
        
        self.playSwipeAnimation(view: view, orientation: .left) 
        
    }
    
    func playSwipeAnimation(view: UIView, orientation: ArrowOrientation = .left) {
        var arrows: [UIImageView] = []
        
        for _ in 1...arrowLimit {
            let arrow = self.createArrow()
            arrow.alpha = 0
            arrows.append(arrow)
            view.addSubview(arrow)
        }
        
        self.addArrowAnimation(arrow: arrows[0], delay: 1, alpha: 1.0, orientation: orientation)
        self.addArrowAnimation(arrow: arrows[1], delay: 1.3, alpha: 0.7, orientation: orientation, showText: true, view: view)
        self.addArrowAnimation(arrow: arrows[2], delay: 1.7, alpha: 0.5, orientation: orientation)

    }
    
    func animateText(text: String, view: UIView, orientation: ArrowOrientation ){
        
        let yPosition = self.screenHeight - 45.0
        
        let swipeText = UILabel()
       
        swipeText.text = text
        swipeText.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
        swipeText.font = UIFont(name: "Avenir-Light", size: 15)
        swipeText.textColor = .white
        swipeText.alpha = 0
        view.addSubview(swipeText)
        
        var startPosition:CGFloat = 0.0
        var middlePosition:CGFloat = 0.0
        var endPosition:CGFloat = 0.0
        
        switch orientation {
        case .left:
             swipeText.frame = CGRect(x: ((self.screenWidth / 2.0) + 90.0), y: yPosition, width: 200, height: 25)
             
              startPosition = CGFloat((self.screenWidth / 2.0) - 10.0)
              middlePosition = CGFloat((self.screenWidth / 2.0) - 40.0 )
              endPosition = CGFloat((self.screenWidth / 2.0) - 50 )
            
        case .right:
             swipeText.frame = CGRect(x: ((self.screenWidth / 2.0) - 90.0), y: yPosition, width: 200, height: 25)
             
             startPosition = CGFloat((self.screenWidth / 2.0) - 60.0)
             middlePosition = CGFloat((self.screenWidth / 2.0) - 50.0 )
             endPosition = CGFloat((self.screenWidth / 2.0) - 10)
        default:
            break
        }
        
        let labelOrigin = swipeText.frame.origin
        
        let animationText = UIViewPropertyAnimator(duration: 0.7, curve:  UIViewAnimationCurve.easeInOut) {
            swipeText.alpha = 1
            swipeText.frame = CGRect(x: startPosition, y: swipeText.frame.origin.y, width: swipeText.frame.width, height: swipeText.frame.height)
            
        }
        animationText.addCompletion { (end) in
            let animation = UIViewPropertyAnimator(duration: 0.5, curve:  UIViewAnimationCurve.linear) {
                swipeText.frame = CGRect(x: middlePosition, y: swipeText.frame.origin.y, width: swipeText.frame.width, height: swipeText.frame.height)
            }
            animation.startAnimation()
            
            animation.addCompletion({ (end) in
                let lastText = UIViewPropertyAnimator(duration: 0.5, curve:  UIViewAnimationCurve.easeInOut) {
                    swipeText.frame = CGRect(x: endPosition, y: swipeText.frame.origin.y, width: swipeText.frame.width, height: swipeText.frame.height)
                    swipeText.alpha = 0
                }
                lastText.startAnimation()
                
                lastText.addCompletion({ (end) in
                    swipeText.frame.origin = labelOrigin
                })
            })
        }
        animationText.startAnimation()
    }
    
    struct RightPositionAnimation {
        let start = -20.0
        let middle = 40.0
        let end = 20.0
        let initX = 0.0
        let initY = -45.0
    }
    
    struct LeftPositionAnimation {
        let start = -20.0
        let middle = -40.0
        let end = 0.0
        let initX = 0.0
        let initY = -45.0
    }
    struct UpPositionAnimation {
        let start = -20.0
        let middle = 40.0
        let end = 20.0
        let initX = -90.0
        let initY = -45.0
    }
    
    enum ArrowOrientation {
        case right
        case left
        case up
        case down
    }
    
    func arrowOrientation(orientation: ArrowOrientation, arrow: UIImageView) -> (Double, Double, Double, Double, Double) {
        
        switch orientation {
        case .left:
            arrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            
            return (LeftPositionAnimation().start, LeftPositionAnimation().middle, LeftPositionAnimation().end,   self.screenWidth + LeftPositionAnimation().initX, self.screenHeight + LeftPositionAnimation().initY)
        case .right:
            return (RightPositionAnimation().start, RightPositionAnimation().middle, self.screenWidth + RightPositionAnimation().end, RightPositionAnimation().initX, self.screenHeight + RightPositionAnimation().initY)
        case .up:
            return (UpPositionAnimation().start, UpPositionAnimation().middle, UpPositionAnimation().end, UpPositionAnimation().initX, UpPositionAnimation().initY)
        default:
            return (0.0,0.0,0.0, 0.0, 0.0)
        }
            
    }
    
    func addArrowAnimation(arrow:UIImageView, delay: Double, alpha: Double, orientation:ArrowOrientation = .left, showText: Bool = false, view: UIView? = nil)-> UIViewPropertyAnimator{
        
        let (startPosition, middlePosition, endPosition, initX, initY) = self.arrowOrientation(orientation: orientation, arrow: arrow)
        
        let arrowOrigin = arrow.frame.origin
         
        //Set initial Value
        arrow.frame.origin.x = CGFloat(initX)
        arrow.frame.origin.y = CGFloat(initY)
        
        let animation = UIViewPropertyAnimator(duration: 0.7, curve: .easeInOut) {
            
            arrow.frame = CGRect(x: CGFloat((self.screenWidth / 2.0) + startPosition), y: arrow.frame.origin.y, width: arrow.frame.width, height: arrow.frame.height)
            arrow.alpha = CGFloat(alpha)
        }
        
        animation.addCompletion { (end) in
            
            if showText && view != nil{
                self.animateText(text: "swipe", view: view!, orientation: orientation )
            }
            
                let secondAnimation = UIViewPropertyAnimator(duration: 1, curve: UIViewAnimationCurve.linear, animations: {
                    
                    arrow.frame = CGRect(x: CGFloat(Double(arrow.frame.origin.x) + middlePosition), y: arrow.frame.origin.y, width: arrow.frame.width, height: arrow.frame.height)
                    
                })
                
                secondAnimation.startAnimation()
                
                secondAnimation.addCompletion({ (end) in
                    let lastAnimation = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn, animations: {
                        
                        arrow.frame = CGRect(x: CGFloat( endPosition), y: arrow.frame.origin.y, width: arrow.frame.width, height: arrow.frame.height)
                        arrow.alpha = 0
                    })
                    lastAnimation.startAnimation()
                    
                    lastAnimation.addCompletion({ (end) in
                        arrow.frame.origin = arrowOrigin
                        arrow.alpha = 0
                    })
                    
                })
            
        }
       
        animation.startAnimation(afterDelay: delay)
        return animation
        
    }
    
    func createArrow()-> UIImageView {
        let arrow = UIImage(named: "Shape@3x.png")
        let arrowView = UIImageView(image:arrow)
        arrowView.frame = CGRect(x: 0, y: screenHeight - 50, width: 17, height: 29)
        
        return arrowView
    }
    
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
