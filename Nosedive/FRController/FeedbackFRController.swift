//
//  FeedbackFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

class FeedbackFRController {
    
    var ref: DatabaseReference!
    var uid: String?
    
    init() {
        ref = Database.database().reference().child("feedbacks")
        uid = Auth.auth().currentUser?.uid
    }
    
    
    func fetchFeedbacks(completion: @escaping (Feedback)->())->(observeId: UInt, ref: DatabaseReference) {
        
        var observe:UInt = 0
      
        observe =  ref.observe(.childAdded, with: { (snap) in
            
            guard let dictionary = snap.value as? [String: Any] else{ return }
            
            guard let userId = dictionary["uid"] as? String else { return }
            
            UserModel().getUserById(uid: userId, completion: { (user) in
                
                guard let u = user else { return }
                let comment = Feedback(user: u, feedbackId: snap.key, dictionary: dictionary)
                
                completion(comment)
            })
            
            
        }, withCancel: { (error) in
            print("error trying to fetch comments", error)
        })
        
        return (observe, ref)
        
    }
    
    func addRating(text: String, private pfb: Bool = false, completion: @escaping (Bool, String)->()){
        
        guard let uid = self.uid else { return }
    
        let value = ["text": text,
                     "creationDate": [".sv": "timestamp"],
                     "private": pfb ? 1 : 0,
                     "uid": uid] as [String : Any]
        
        
        ref.childByAutoId().updateChildValues(value) { (error, ref) in
            if let error = error {
                print("Errror trying to add post", error)
                completion(false, error.localizedDescription)
                return
            }
            
            print("Successfully inserted feedback")
            completion(true, "")
        }
        
    }
    
}
