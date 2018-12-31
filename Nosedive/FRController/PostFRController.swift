//
//  PostModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//


import UIKit
import Firebase

class PostFRController {
    
    
    var uid: String?
    var ref: DatabaseReference!
    
    init() {
        self.uid = Auth.auth().currentUser?.uid
        self.ref = Database.database().reference()
    }
    
    func writeNewPost(withCaption caption: String, imageWidth: CGFloat, imageHeight: CGFloat, imageUrl: String, fileName: String, faces: Int) {
        
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
      
        let key = ref.childByAutoId().key
        
        let post = ["uid": self.uid!,
                    "creationDate": [".sv": "timestamp"],
                    "caption": caption,
                    "imageWidth": imageWidth,
                    "imageHeight": imageHeight,
                    "imageUrl": imageUrl,
                    "fileName": fileName,
                    "rating": 0.00,
                    "votes": 0,
                    "faces": faces,
                    "hasFace": false,  // Objectify people activate.  -- faces > 0 ? true : false
            ] as [String : Any]
        
        let childUpdates = ["/posts/\(key)": post,
                            "/user-posts/\(self.uid!)/\(key)/": post]
        
        ref.updateChildValues(childUpdates)

    }
    
    func removePost(postId: String, userId: String, completion: @escaping (_ success: Bool)->()){
        //there are observe on the server in charge to remove from posts, comments, and the file
        
        ref.child("user-posts").child(userId).child(postId).removeValue { (err, databaseRef) in
            if  let err = err {
                print("Error trying to remove post", err)
                completion(false)
                return
            }
            
            self.ref.child("posts").child(postId).removeValue { (err, ref) in
                if  let err = err {
                    print("Error trying to remove post", err)
                    completion(false)
                    return
                }
            
            completion(true)
            }
        }  
    }
    
    func reportPost(post: Post, userReported: String, completion: @escaping(_ sucess: Bool)->() ){
        
        let postId = post.postId
        guard let postOwner = post.user?.id else { return }
        
        let reportPostData = ["postId": postId,
                              "imageUrl": post.imageUrl,
                              "uid": postOwner,
                              "timestamp": [".sv": "timestamp"],
                              "reportedBy": userReported] as [String : Any]
        
        ref.child("report-post").child(postId).childByAutoId().updateChildValues(reportPostData) { (err, ref) in
           
            if let err = err {
                print("error reporting this post", err)
                completion(false)
            }else{
                completion(true)
            }
        }
   
        
    }
    
    
    
}

