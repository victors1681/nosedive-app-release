//
//  RatingOptions.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

extension RatingMainViewController {
 
    func closeView (alert: UIAlertAction!){
        self.dismiss(animated: true, completion: nil)
    }
    
    func userOptions() {
        let alertController = UIAlertController(title: nil, message: "Report or block user", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Report", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            guard let user = self.userData else { return }
            UserModel().reportUser(user: user, userReported: currentUser, completion: { (sucess) in
                
                if sucess {
                    let alert = UIAlertController(title: "Reported", message: "This user has been reported to the administrator. Thank You", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Reported", message: "Error trying to report this post please check your internet connection", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
            })
        })
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            
            guard let uid = self.userData?.id else {return}
            UserModel().blockUser(blockTo: uid, completion: { (isBlock) in
                if isBlock {
                    let alert = UIAlertController(title: "User Blocked", message: "This user is no longer available to see your profile", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Blocked", message: "Error blocking this user, please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        let unBlockAction = UIAlertAction(title: "Unblocking", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
            guard let uid = self.userData?.id else {return}
            UserModel().blockUser(blockTo: uid, block: false, completion: { (isBlock) in
                if isBlock {
                    let alert = UIAlertController(title: "User Unblocked", message: "This user is allow to see your profile", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Unbloked", message: "Error unblocking this user, please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        let removeAction = UIAlertAction(title: "Disable User", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            // Do some destructive action here.
            guard let uid = self.userData?.id else {return}
            UserModel().disableUser(uIdTo: uid, completion: { (success) in
                if success {
                    let alert = UIAlertController(title: "User Disabled", message: "User has been disabled", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Disabled", message: "Error Disabling this user", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        
        UserModel().getUserById(uid: currentUserId, completion: { (userData) in
            
            guard let isAdmin = userData?.isAdmin else { return }
            
            if isAdmin {
                alertController.addAction(removeAction)
            }
            
        })
        
        guard let uid = self.userData?.id else {return}
        UserModel().isBloked(uId: uid, invert: true) { (isBloked) in
            if isBloked {
                alertController.addAction(unBlockAction)
            }else{
                alertController.addAction(blockAction)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
