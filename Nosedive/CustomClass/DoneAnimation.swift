//
//  DoneAnimation.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Lottie

extension UIView {
    func showDoneAnimation(){
        var submitAnimation: LOTAnimationView?
        let container: UIView = {
            let v = UIView()
            v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            return v
        }()
        
        submitAnimation = LOTAnimationView(name: "check-done");
        submitAnimation?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        submitAnimation?.center = self.center
        submitAnimation?.contentMode = .scaleToFill
        container.addSubview(submitAnimation!)
        container.alpha = 0
      
        self.addSubview(container)
        
        UIView.animate(withDuration: 0.5, animations: {
            container.alpha = 1
        }) { (done) in
            
            submitAnimation?.play(completion: { (done) in
                UIView.animate(withDuration: 0.5, animations: {
                    container.alpha = 0
                }, completion: { (done) in
                    container.removeFromSuperview()
                })
            })
        }
        
        container.anchor(top: self.topAnchor, left: self.leftAnchor
            , bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
}
