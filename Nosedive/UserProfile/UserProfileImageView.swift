//
//  UserProfileImageView.swift
//  Nosedive
//
//  Created by Victor Santos on 1/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class UserProfileImageView: UIImageView {

    var previewsAnimation: CAAnimation?
    open var userData: UserModel.User?
    open var path: CGPath? //help to resume animation after dismiss
    
    init(radio: CGFloat, userData: UserModel.User, path: CGPath) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.userData = userData
        self.layer.cornerRadius = CGFloat(radio / 2.0)
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.path = path
        
        return
    }
    
    
    func resumeAnimation()  {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    
    func stopAnimation() {
        
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
