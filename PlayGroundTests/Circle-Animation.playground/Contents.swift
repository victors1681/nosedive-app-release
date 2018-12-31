//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class CircleView: UIView {
    
    var path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
      
        // x^2 + y^2 = r^2
        
        //cos(theta) = x / r ==> x = r * cos(theta)
        //sin(theta) = y / r ==> y = r * sin(theta)
        
        let radius = 100.0
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        
        path.move(to: CGPoint(x: Double(center.x) + radius, y: Double(center.y) ))
        
        for i in stride(from: 0, to: 380.0, by: 1){
            
          let theta = i * Double.pi / 180
          let x = Double(center.x) + radius * cos(theta)
          let y = Double(center.y) + radius * sin(theta)
            
             path.addLine(to: CGPoint(x: x, y: y))
        }
        
        //path.addLine(to: CGPoint(x: 100, y: 100))
        
        //Color
        UIColor.green.setFill()
        path.fill()
        
        //Stroke Color
        UIColor.red.setStroke()
        
        path.lineWidth = 5
        path.stroke()
        
        print("BIG CIRCLEEEEE \n \n", path.cgPath)
        
        path.close()
        
        
    }
    
    func changeStrokeColor() {
        UIColor.blue.setStroke()
        path.stroke()
    }
    
  
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.view = view
        
        let circle = CircleView()

        
        let circleWithPath = self.createCircle(rect: CGRect(x: 200, y: 500, width: 100, height: 100))
        //let circleWithPathEnd = self.createCircle(rect: CGRect(x: 100, y: 300, width: 300 , height: 300))
        let circleWithPathEnd = UIBezierPath(arcCenter: view.center, radius: 200, startAngle: 0, endAngle: .pi*2, clockwise: true)
        
        //Create Layer
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = circleWithPath.cgPath
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        circleShapeLayer.strokeColor = UIColor.blue.cgColor
        
        view.layer.addSublayer(circleShapeLayer)
  
        let circleShapeLayer2 = CAShapeLayer()
        circleShapeLayer2.path = circleWithPathEnd.cgPath
        circleShapeLayer2.fillColor = UIColor.green.cgColor
        circleShapeLayer2.strokeColor = UIColor.red.cgColor
        circleShapeLayer2.backgroundColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(circleShapeLayer2)

        let aniFrame = CABasicAnimation(keyPath: "path")
        aniFrame.duration = 1
        aniFrame.fromValue = circleWithPath.cgPath
        aniFrame.toValue = circleWithPathEnd.cgPath
        aniFrame.repeatCount = MAXFLOAT
        
        circleShapeLayer2.add(aniFrame, forKey: aniFrame.keyPath)
        
      
        
        
        //let circlePath = UIBezierPath(arcCenter: view.center, radius: 20, startAngle: 0, endAngle: .pi*2, clockwise: true)
        
        let circlePath = UIBezierPath(arcCenter: view.center, radius: 20, startAngle: 0, endAngle: .pi*2, clockwise: true)

        let rect = CGRect(x: 100, y: 100, width: 100, height: 100)
        let curve = UIBezierPath(roundedRect: rect, cornerRadius: 10)
       //let poin1 = CGPoint(x: 0, y: 100)
//        let poin2 = CGPoint(x: 50, y: 300)
//        let poin3 = CGPoint(x: 100, y: 100)
//        curve.addCurve(to: poin1, controlPoint1: poin2, controlPoint2: poin3)
//
        let layer = CAShapeLayer()
        layer.path = curve.cgPath
        layer.strokeColor = UIColor.blue.cgColor
        
        
        view.layer.addSublayer(layer)
        
        let animationFrame = CAKeyframeAnimation(keyPath: "position")
        animationFrame.duration = 1
        animationFrame.repeatCount = MAXFLOAT
        //animationFrame.path = circlePath.cgPath
         //animationFrame.path = curve.cgPath
         animationFrame.path = circleWithPath.cgPath
        
        let squareView = UIView()
        //whatever the value of origin for squareView will not affect the animation
        squareView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        squareView.backgroundColor = .lightGray
        view.addSubview(squareView)
        // You can also pass any unique string value for key
        squareView.layer.add(animationFrame, forKey: nil)
        
        // circleLayer is only used to locate the circle animation path
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        //print("ANOTHERRRR \n", circlePath.cgPath)
        circleLayer.strokeColor = UIColor.black.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(circleLayer)
        
        
        
    }
    
    func createCircle(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        // x^2 + y^2 = r^2
        
        //cos(theta) = x / r ==> x = r * cos(theta)
        //sin(theta) = y / r ==> y = r * sin(theta)
        
        let radius = 100.0
        let center = CGPoint(x: rect.origin.x, y: rect.origin.y )
        
        
        path.move(to: CGPoint(x: Double(center.x) + radius, y: Double(center.y) ))
        
        for i in stride(from: 0, to: 380.0, by: 1){
            
            let theta = i * Double.pi / 180
            let x = Double(center.x) + radius * cos(theta)
            let y = Double(center.y) + radius * sin(theta)
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        //path.addLine(to: CGPoint(x: 100, y: 100))
        
        //Color
        UIColor.green.setFill()
        path.fill()
        
        //Stroke Color
        UIColor.red.setStroke()
        
        path.lineWidth = 5
        path.stroke()
        
        
       // path.close()
        
        return path
        
    }
    
}


// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
