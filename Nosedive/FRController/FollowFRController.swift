//
//  FollowFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/10/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//


import UIKit
import Firebase
import SwiftyJSON

class FollowFRController {
    
    var ref: DatabaseReference!
    var uid: String?
    
    init() {
        ref = Database.database().reference()
        uid = Auth.auth().currentUser?.uid
    }
    
    func checkFollowing(following to: String, completion: @escaping (Bool)->()) {
        guard let uid = self.uid else { return }
        
        ref.child("following").child(uid).child(to).observeSingleEvent(of: .value) { (snap) in
            
            let data = JSON(snap.value ?? [:]).dictionaryValue
            if let follow = data["follow"]?.stringValue, follow == "1" {
                completion(true)
            }else{
                completion(false)
            }
            
        }
        
    }
    
    func followAction(following to: String, completion: @escaping (Bool)->()){
        
        //Check if user is following
        guard let uid = self.uid else { return }
        
        self.checkFollowing(following: to) { (following) in
            
            if following {
                self.ref.child("following").child(uid).child(to).removeValue(completionBlock: { (err, ref) in
                    
                    self.ref.child("followers").child(to).child(uid).removeValue(completionBlock: { (err, ref) in
                        completion(false)
                    })
                })
                
            }else{
                
                //No following, start following
                let followingTo = ["follow": 1,
                                   "creationDate": [".sv": "timestamp"]
                    ] as [String : Any]
                
                let follower = ["follow": 1,
                                "creationDate": [".sv": "timestamp"]
                    ] as [String : Any]
                
                
                let childUpdates = ["/following/\(uid)/\(to)": followingTo,
                                    "/followers/\(to)/\(uid)": follower]
                
                
                self.ref.updateChildValues(childUpdates) { (error, ref) in
                    if let error = error {
                        print("Errror trying to add post", error)
                        completion(false)
                        return
                    }
                    
                    completion(true)
                    
                }
            }
            
        }
        
    }
    
}
