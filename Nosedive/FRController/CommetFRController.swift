//
//  CommetsFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/24/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

class CommentFRController {
    
    var ref: DatabaseReference!
    var uid: String?
    
    init() {
        ref = Database.database().reference().child("comments")
        uid = Auth.auth().currentUser?.uid
    }
    
    
    func fetchComments(post: Post, completion: @escaping (Comment)->())->(observeId: UInt, ref: DatabaseReference) {
    
        var observe:UInt = 0
        let currentRef = ref.child(post.postId);
      observe =  currentRef.observe(.childAdded, with: { (snap) in
           
            guard let dictionary = snap.value as? [String: Any] else{ return }
            
            guard let userId = dictionary["uid"] as? String else { return }
            
            UserModel().getUserById(uid: userId, completion: { (user) in
                
                guard let u = user else { return }
                let comment = Comment(user: u, commentId: snap.key, dictionary: dictionary)
                
                completion(comment)
            })
            
            
            }, withCancel: { (error) in
                print("error trying to fetch comments", error)
        })
        
        return (observe, currentRef)
       
    }
    
    func addComment(text: String, post: Post, completion: @escaping (Bool, String)->()){
        
        guard let uid = self.uid else { return }
        let postId = post.postId
        let value = ["text": text,
                     "creationDate": [".sv": "timestamp"],
                     "uid": uid] as [String : Any]
        
        
        ref.child(postId).childByAutoId().updateChildValues(value) { (error, ref) in
            if let error = error {
                print("Errror trying to add post", error)
                completion(false, error.localizedDescription)
                return
            }
            
            print("Successfully inserted comment")
            completion(true, "")
        }
        
    }
    
}
