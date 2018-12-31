//
//  FeedFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/22/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import SwiftyJSON
import UIKit

class FeedFRController {
    
    enum SearchType: String {
        case username, fullname
    }
    
    enum PostType {
        case user
        case all
    }
    
    var ref:DatabaseReference!
    var userRef: DatabaseReference!
    var ratingPostRef: DatabaseReference!
    var commentRef: DatabaseReference!
    var userPostRef: DatabaseReference!
    
    init() {
        ref = Database.database().reference().child("posts")
        userRef = Database.database().reference().child("users")
        ratingPostRef = Database.database().reference().child("rating-posts")
        commentRef = Database.database().reference().child("comments")
        userPostRef = Database.database().reference().child("user-posts")
    }
    
    
    
    
    func fetchPostsPaginate(lastPost postInfo: Post? = nil, filter by: PostType = .all, uid: String? = nil, completion: @escaping ([Post], _ lastPost: Post?)->()){
        var posts = [Post]()
        
        var currentRef: DatabaseReference!
        
        if by == .all {
            currentRef = ref
        }else{
            guard let uid = uid else { return }
            currentRef = userPostRef.child(uid)
        }
        
        var query = currentRef.queryOrdered(byChild: "creationDate") 
        if (postInfo != nil) {
            guard  let value = postInfo?.creationDate.timeIntervalSince1970 else { return }
            query = query.queryEnding(atValue: value * 1000)
        }
        
        query.queryLimited(toLast: 15).observeSingleEvent(of: .value, with: { (snap) in
            
            guard var allObject = snap.children.allObjects as? [DataSnapshot] else { return }
            
            // allObject.reverse()
            
            if (postInfo != nil  && allObject.count > 0) {
                //allObject.removeFirst()
                allObject.removeLast()
            }
            
            let totalForCompletion = allObject.count
            if(totalForCompletion == 0){
                completion(posts, nil)
            }
            allObject.forEach({ (snap) in
                
                let postId = snap.key
                let json = JSON(snap.value ?? [:]).dictionaryValue
                
                
                let userId = json["uid"]?.stringValue ?? ""
                
                if !userId.isEmpty{
                    
                    
                    self.userRef.child(userId).observeSingleEvent(of: DataEventType.value) { (userSnap) in
                        
                        if !userSnap.exists() { return }
                        
                        let userValues = JSON(userSnap.value ?? [:])
                        let dataUser = (key: userId, value: userValues)
                        let u = UserModel.User(userObject: dataUser)
                        
                        var p = Post(user: u, postId: postId, post: json)
                        
                        guard let currentUser = Auth.auth().currentUser?.uid else { return }
                        
                        self.ratingPostRef.child(postId).child(currentUser).observeSingleEvent(of: .value, with: { (ratingSnap) in
                            
                            let ratingInfo = JSON(ratingSnap.value ?? [:]).dictionaryValue
                            
                            if !ratingInfo.isEmpty {
                                let value = ratingInfo["value"]?.doubleValue ?? 0.0
                                p.hasRated = value
                            } else {
                                p.hasRated = 0.0
                            }
                            
                            //Count commets
                            self.commentRef.child(postId).observeSingleEvent(of: .value, with: { (commentSnap) in
                                if commentSnap.exists() {
                                    let commentInfo = JSON(commentSnap.value ?? [:]).dictionaryValue
                                    p.comments = commentInfo.count
                                }
                                posts.append(p)
                                
                                if totalForCompletion == posts.count {
                                    
                                    //get the last element before order post.
                                    //Last element is the first in query
                                    let lastPost = posts.first
                                    posts.sort(by: {$0.creationDate > $1.creationDate})
                                    completion(posts, lastPost)
                                }
                            }, withCancel: { (err) in
                                print("Error to get comment per post, postId:\(postId), \(err)")
                            })
                            
                        }, withCancel: { (err) in
                            print("Error evaluating if the post \(snap.key) has been rated", err)
                            
                        })
                        
                    }
                }
                
            })
            
            
            
            
            
            
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    
    func findUser(text: String, type: SearchType = .username, completion: @escaping ([UserModel.User]?)->()) {
        
        let searchText = text.lowercased()
        
        ref.queryOrdered(byChild: type.rawValue)
            .queryStarting(atValue: searchText, childKey: type.rawValue)
            .queryEnding(atValue: searchText + "\u{f8ff}", childKey: type.rawValue)
            .queryLimited(toFirst: 20)
            .observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                
                guard let u = JSON(snapshot.value ?? [:]).dictionary else {
                    return
                }
                
                let users = UserModel().decodeUsers(json: u)
                
                completion(users)
                
            }) { (error) in
                
                completion(nil)
        }
        
    }
    
    
}
