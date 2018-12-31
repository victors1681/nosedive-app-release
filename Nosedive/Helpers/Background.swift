//
//  Background.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class Background {
    
    var view: UIView
    
    init(view : UIView = UIView()){
        
        self.view = view
        
    }
    
    func setBackgroundImage(photoUser: String, view: UIView) {
        
        let url = URL(string: photoUser)
        let imageView = UIImageView()
        imageView.kf.setImage(with: url)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.frame
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.frame
        
        blurEffectView.alpha = 0.9
        view.insertSubview(imageView, at: 0)
        view.insertSubview(blurEffectView, at: 1)
        
        
    }
    
    func applyBackground(currentBg: String, alpha: CGFloat){
        
        let backgroundKey = "backgroundColor";
        let userDefault = UserDefaults()
        
        let (topColor, bottomColor) = self.colorSelector(color: BackgroundColor(rawValue: currentBg)!, alpha: alpha)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]
        gradientLayer.frame = view.bounds
        
        gradientLayer.name = "bg"
        
        if let layers = view.layer.sublayers {
            
            for layer in layers {
                if(layer.name == "bg"){
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        //Save background color
        userDefault.set(currentBg, forKey: backgroundKey)
        
    }
    
    
    func colorSelector(color:BackgroundColor, alpha: CGFloat) -> (UIColor, UIColor) {
        
        switch color {
        case .pink:
            let topColor = UIColor(red:0.95, green:0.75, blue:0.75, alpha: alpha)
            
            let bottomColor = UIColor(red:0.87, green:0.71, blue:0.73, alpha:  alpha)
            
            return (topColor, bottomColor)
            
        case .blue:
            let topColor = UIColor(red: 192.0/255.0, green: 211.0/255.0, blue: 255.0/255.0, alpha: alpha)
            let bottomColor = UIColor(red: 62.0/255.0, green: 148.0/255.0, blue: 229.0/255.0, alpha: alpha)
            
            return (topColor, bottomColor)
            
        case .black:
            let topColor = UIColor(red: 65.0/255.0, green: 67.0/255.0, blue: 69.0/255.0, alpha: alpha)
            let bottomColor = UIColor(red: 35.0/255.0, green: 37.0/255.0, blue: 38.0/255.0, alpha: alpha)
            
            return (topColor, bottomColor)
            
        case .green:
            let topColor = UIColor(red: 56.0/255.0, green: 239.0/255.0, blue: 125.0/255.0, alpha: alpha)
            let bottomColor = UIColor(red: 17.0/255.0, green: 153.0/255.0, blue: 142.0/255.0, alpha: alpha)
            
            return (topColor, bottomColor)
            
        case .red:
            let topColor = UIColor(red: 239.0/255.0, green: 71.0/255.0, blue: 58.0/255.0, alpha: alpha)
            let bottomColor = UIColor(red: 203.0/255.0, green: 45.0/255.0, blue: 62.0/255.0, alpha: alpha)
            
            return (topColor, bottomColor)
            
        case .purple:
            let topColor = UIColor(red: 251.0/255.0, green: 211.0/255.0, blue: 233.0/255.0, alpha: alpha)
            let bottomColor = UIColor(red: 187.0/255.0, green: 55.0/255.0, blue: 125.0/255.0, alpha: alpha)
            
            return (topColor, bottomColor)
            
        case .baseBlack:
            let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            let bottomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            
            return (topColor, bottomColor)
        }
    }
    
}
