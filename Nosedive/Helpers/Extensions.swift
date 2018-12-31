//
//  Extensions.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}

extension Array {
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}

extension UISearchBar
{
    
    
    
    func setMagnifyingGlassColorTo(color: UIColor)
    {
        // Search Icon
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
    
    func setClearButtonColorTo(color: UIColor)
    {
        // Clear Button
        
        if let searchTextField = self.value(forKey: "searchField") as? UITextField,
            let clearButton = searchTextField.value(forKey: "clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = color
        }
        
    }
    
    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
}


extension String {
    func isEmailValid() -> Bool{
        let email = self
        let emailPattern = "[A-Za-z-0-9.-_]+@[A-Za-z0-9]+\\.[A-Za-z]{2,3}"
        do{
            let regex = try NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
            let foundPatters = regex.numberOfMatches(in: email, options: .anchored, range: NSRange(location: 0, length: email.count))
            if foundPatters > 0 {
                return true
            }
        }catch{
            //error
        }
        return false
    }
}

extension String {
    func getRanges(of string: String) -> [NSRange] {
        var ranges:[NSRange] = []
        if contains(string) {
            let words = self.components(separatedBy: " ")
            var position:Int = 0
            for word in words {
                if word.lowercased() == string.lowercased() {
                    let startIndex = position
                    let endIndex = word.count
                    let range = NSMakeRange(startIndex, endIndex)
                    ranges.append(range)
                }
                position += (word.count + 1) // +1 for space
            }
        }
        return ranges
    }
    func highlight(_ words: [String], this color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        let r = NSMakeRange(0, self.count)
        
        attributedString.addAttributes([NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white], range: r)
        
    
        for word in words {
            let ranges = getRanges(of: word)
            for range in ranges {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)], range: range)
            }
        }
        return attributedString
    }
    
    func highlightUsers()->NSMutableAttributedString{
        
        var users: [String] = [String]()
        let fields = self.components(separatedBy: .whitespaces).filter {!$0.isEmpty}
        
        for word in fields {
            if word.hasPrefix("@"){
                users.append(word) 
            }
        }
        
        // Highlight words and get back attributed string
       
        let attributedString = self.highlight(users, this: .white)
        
        return attributedString
    }
}


extension UITableViewController {
    
    func getBackgroundColor(){
        
        let backgroundKey = "backgroundColor";
        let userDefault = UserDefaults()
        
        if let currentBg = userDefault.string(forKey: backgroundKey){
            
            let (topColor, bottomColor) = Background().colorSelector(color: BackgroundColor(rawValue: currentBg)!, alpha: 0.8)
            
            let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
            let gradientLocations = [0.0,1.0]
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientBackgroundColors
            gradientLayer.locations = gradientLocations as [NSNumber]
            
            gradientLayer.frame = self.tableView.bounds
            
            
            let backgroundView = UIView(frame: self.tableView.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            self.tableView.backgroundView = backgroundView
            
        }
    }
    
    
}

extension UICollectionViewController {
    func setClearBackground (view: UIView, style: UIBlurEffectStyle = .dark){
        self.collectionView?.backgroundColor = .clear
        
        let effect = UIBlurEffect(style: style)
        let effectView = UIVisualEffectView(effect: effect)
        
        if style == .light {
            let darkView = UIView()
            darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.insertSubview(darkView, at: 0)
            
            darkView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        
        view.insertSubview(effectView, at: 0)
        
        effectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
}

extension UIView {
    
    func setClearBackground (view: UIView, style: UIBlurEffectStyle = .dark){
        self.backgroundColor = .clear
        
        let effect = UIBlurEffect(style: style)
        let effectView = UIVisualEffectView(effect: effect)
        
        if style == .light {
            let darkView = UIView()
            darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.insertSubview(darkView, at: 0)
            
            darkView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        
        view.insertSubview(effectView, at: 0)
        
        effectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    func profileAnimation(containerView: UIView, profilePhoto: UIImageView) -> LOTAnimationView{
        
        
        
        let circularAnimation = LOTAnimationView(name: "circle-animation")
        circularAnimation.alpha = 0.6
        
        let size = CGSize(width: profilePhoto.frame.width + 150, height: profilePhoto.frame.height + 150 )
        
        //circularAnimation.backgroundColor = .red
        //containerView.backgroundColor = .green
        
        containerView.addSubview(circularAnimation)
        circularAnimation.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        circularAnimation.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let point = CGPoint(x: containerView.frame.width/2, y: containerView.frame.height/2)
        
        
        circularAnimation.contentMode = .scaleAspectFill
        circularAnimation.frame = CGRect(origin: point, size: size)
        
        
        circularAnimation.play()
        circularAnimation.loopAnimation = true
        
        containerView.bringSubview(toFront: profilePhoto)
        
        
        return circularAnimation
        
    }
    
    
    
    func setBackgroundColor(color: BackgroundColor){
        let backgroundKey = "backgroundColor";
        let userDefault = UserDefaults()
        
        //Save background color
        userDefault.set(color.rawValue, forKey: backgroundKey)
        
        self.getBackgroundColor()
    }
    
    func getBackgroundColor(alpha:CGFloat = 0.8) {
        let backgroundKey = "backgroundColor";
        let userDefault = UserDefaults()
        
        let view = Background(view: self)
        
        if let currentBg = userDefault.string(forKey: backgroundKey){
            view.applyBackground(currentBg: currentBg, alpha: alpha)
        }else{
            //Applay Pink default background
            view.applyBackground(currentBg: "pink", alpha: alpha)
        }
        
    }
    
    
    
    func getOnlyBackgroundColors(alpha: CGFloat = 0.9)->(UIColor, UIColor){
        
        let backgroundKey = "backgroundColor";
        let userDefault = UserDefaults()
        
        if let currentBg = userDefault.string(forKey: backgroundKey){
            
            let (topColor, bottomColor) = Background().colorSelector(color: BackgroundColor(rawValue: currentBg)!, alpha: alpha)
            
            return (topColor, bottomColor)
        }
        
        return (UIColor.clear, UIColor.clear)
        
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat, safeArea: Bool = false, view: UIView? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            if safeArea {
                guard let view = view else {return}
                self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: paddingTop).isActive = true
            }else{
                self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
            }
           
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            if safeArea {
                guard let view = view else {return}
                self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -paddingBottom).isActive = true
            }else{
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "w"
        } else {
            quotient = secondsAgo / month
            unit = "m"
        }
        
        return "\(quotient)\(unit)"
       // return "\(quotient) \(unit)\(quotient == 1 ? "" : "s")"
        
    }
}

extension UIDeviceOrientation {
    func getUIImageOrientationFromDevice(cameraType: CameraController.CameraType) -> UIImageOrientation { 
        switch self {
        case UIDeviceOrientation.portrait, .faceUp:
            if(cameraType == .back){
                return UIImageOrientation.right
            }else{
                return UIImageOrientation.leftMirrored
            }
        case UIDeviceOrientation.portraitUpsideDown, .faceDown:
            if cameraType == .back {
                return UIImageOrientation.left
            }else{
                return UIImageOrientation.rightMirrored
            }
        case UIDeviceOrientation.landscapeLeft:
            if cameraType == .back {
                return UIImageOrientation.right // this is the base orientation
            }else{
                return UIImageOrientation.leftMirrored
            }
        case UIDeviceOrientation.landscapeRight:
            if cameraType == .back {
                return UIImageOrientation.right
            }else{
                return UIImageOrientation.leftMirrored
            }
        case UIDeviceOrientation.unknown:
            if cameraType == .back {
                return UIImageOrientation.up
            }else{
                return UIImageOrientation.downMirrored
            }
            
        }
    }
}

extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}


extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
