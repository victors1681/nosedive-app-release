//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport


enum StarColor {
    case yellow
    case white
}
class MyViewController : UIViewController {
    
    var ovalPath: UIBezierPath?
    var addBubbleBtn : UIButton!
    
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        view.frame = CGRect(x: 0, y: 0, width: 365, height: 667)
        self.view = view
       
        
        //Star 1
        let starSize = CGSize(width: 45, height: 45)
        let starPath = self.createStar()
        let starLayerYellow = self.createStarShapeLayer(start: starPath.cgPath, color: .yellow)
        let starLayerWhite = self.createStarShapeLayer(start: starPath.cgPath)
        
        //Star2
        let star2Pos = CGPoint(x: 50, y: 0)
        let star2LayerYellow = self.createStarShapeLayer(start: starPath.cgPath, color: .yellow)
        let star2LayerWhite = self.createStarShapeLayer(start: starPath.cgPath)
        star2LayerWhite.frame = CGRect(origin: star2Pos, size: starSize)
        star2LayerYellow.frame = CGRect(origin: star2Pos, size: starSize)
        
        //Star3
        let star3Pos = CGPoint(x: 100, y: 0)
        let star3LayerYellow = self.createStarShapeLayer(start: starPath.cgPath, color: .yellow)
        let star3LayerWhite = self.createStarShapeLayer(start: starPath.cgPath)
        star3LayerWhite.frame = CGRect(origin: star3Pos, size: starSize)
        star3LayerYellow.frame = CGRect(origin: star3Pos, size: starSize)
        
        //Star4
        let star4Pos = CGPoint(x: 150, y: 0)
        let star4LayerYellow = self.createStarShapeLayer(start: starPath.cgPath, color: .yellow)
        let star4LayerWhite = self.createStarShapeLayer(start: starPath.cgPath)
        star4LayerWhite.frame = CGRect(origin: star4Pos, size: starSize)
        star4LayerYellow.frame = CGRect(origin: star4Pos, size: starSize)
        
        //Star5
        let star5Pos = CGPoint(x: 200, y: 0)
        let star5LayerYellow = self.createStarShapeLayer(start: starPath.cgPath, color: .yellow)
        let star5LayerWhite = self.createStarShapeLayer(start: starPath.cgPath)
        star5LayerWhite.frame = CGRect(origin: star5Pos, size: starSize)
        star5LayerYellow.frame = CGRect(origin: star5Pos, size: starSize)
        
        
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 45, height: 45), cornerRadius: 0)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillColor = UIColor(red:0.99, green:0.05, blue:0.11, alpha:5.00).cgColor
        maskLayer.frame = CGRect(x: 25, y: starLayerYellow.frame.origin.y, width: 200, height: 45)
        
        starLayerYellow.mask = maskLayer
        star2LayerYellow.mask = maskLayer
        star3LayerYellow.mask = maskLayer
//        star4LayerYellow.mask = maskLayer
//        star5LayerYellow.mask = maskLayer
        
        view.layer.addSublayer(starLayerWhite)
        view.layer.addSublayer(starLayerYellow)
        
        view.layer.addSublayer(star2LayerWhite)
        view.layer.addSublayer(star2LayerYellow)
        
        view.layer.addSublayer(star3LayerWhite)
        view.layer.addSublayer(star3LayerYellow)
        
        view.layer.addSublayer(star4LayerWhite)
        view.layer.addSublayer(star4LayerYellow)
        
        view.layer.addSublayer(star5LayerWhite)
        view.layer.addSublayer(star5LayerYellow)
        
         view.layer.addSublayer(maskLayer)
        
    }
    
    func createStarShapeLayer(start:CGPath, color: StarColor = .white) -> CAShapeLayer {
        
        var colorToLayer: UIColor
        
        switch color {
        case .yellow:
            colorToLayer = UIColor(red:0.97, green:0.91, blue:0.11, alpha:1.00)
        default:
            colorToLayer = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.60)
        }
        
        let layer = CAShapeLayer()
        layer.path = start
        layer.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        layer.fillColor = colorToLayer.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        return layer
    }
    
    func createStar() -> UIBezierPath {
        
        let startPath = UIBezierPath()
        startPath.move(to: CGPoint(x: 8.09, y: 42.01))
        startPath.addLine(to: CGPoint(x: 13.48, y: 25.98))
        startPath.addLine(to: CGPoint(x: 0, y: 16.04))
        startPath.addLine(to: CGPoint(x: 16.75, y: 15.19))
        startPath.addLine(to: CGPoint(x: 21.86, y: 0))
        startPath.addLine(to: CGPoint(x: 27.34, y: 15.84))
        startPath.addLine(to: CGPoint(x: 44, y: 16.18))
        startPath.addLine(to: CGPoint(x: 30.62, y: 27.03))
        startPath.addLine(to: CGPoint(x: 35.91, y: 42.15))
        startPath.addLine(to: CGPoint(x: 22.06, y: 33.3))
        startPath.addLine(to: CGPoint(x: 8.09, y: 42.01))
        startPath.close()
        
        return startPath
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
    
   
}

//
//let gradientLayer = CAGradientLayer()
//gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
//gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
//gradientLayer.frame = CGRect(x:0, y:0, width:500, height:500);
//
//
//let gradientColor = UIColor(red: 255.000, green: 1.000, blue: 1.000, alpha: 1)
//let gradientColor2 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.080)
//
//
//gradientLayer.colors = [gradientColor.cgColor, gradientColor2.cgColor]
//
//gradientLayer.mask = circleShapeLayer



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()


