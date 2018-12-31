//
//  RatingFollow.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

extension RatingMainViewController {
    
    @objc func handleFollower(){
        followBtn.isEnabled = false
        guard let user = userData else {return }
        
        FollowFRController().followAction(following: user.id) { (isFollowing) in
            
            self.isFollowing(isFollowing)
            self.getTotalFollowers()
            self.followBtn.isEnabled = true
        }
    }
    
    
    func isFollowing(_ following: Bool){
        if following {
            self.followBtn.setImage(#imageLiteral(resourceName: "check_favorite"), for: .normal)
            //self.followBtn.imageView?.tintColor = UIColor.white
            //self.followBtn.layer.borderColor = UIColor(red:0.49, green:0.83, blue:0.13, alpha:1.00).cgColor
            //self.followBtn.backgroundColor = UIColor(red:0.49, green:0.83, blue:0.13, alpha:1.00)
        }else{
            self.followBtn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
            self.followBtn.layer.borderColor = UIColor.clear.cgColor
            self.followBtn.backgroundColor = UIColor.clear
        }
    }
    
    
}
