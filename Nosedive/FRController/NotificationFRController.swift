//
//  NotificationFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class NotificationFRController {
    
    var notiRef: DatabaseReference!
    var ref: DatabaseReference!
    var uid: String?
    
    init() {
        notiRef = Database.database().reference().child("notifications")
        ref = Database.database().reference()
        uid = Auth.auth().currentUser?.uid
    }
    
    
    func fetchNotifications(completion: @escaping (NotificationModel)->())->(observeId: UInt, ref: DatabaseReference) {
        
        var observe:UInt = 0
        
        if let currentUser = self.uid {
        
        observe =  notiRef.child(currentUser).queryLimited(toLast: 25).observe(.childAdded, with: { (snap) in
            
            guard let dictionary = snap.value as? [String: Any] else{ return }
            let notificationId = snap.key
            
            guard let nts = dictionary["type"] as? String else { return }
            guard let notificationType = NotificationType(rawValue: nts) else { return }
            
            switch notificationType {
            case .comment:
                self.getComments(notificationId: notificationId, dictionary: dictionary, completion: { (notification) in
                    completion(notification)
                })
                break
                
            case .ratingPost:
                self.getRatingPost(notificationId: notificationId, dictionary: dictionary, completion: { (notification) in
                    completion(notification)
                })
                break
            case .userRating:
                self.getUserRating(notificationId: notificationId, dictionary: dictionary, completion: { (notification) in
                    completion(notification)
                })
                break
            case .follower:
                self.getFollower(notificationId: notificationId, dictionary: dictionary, completion: { (notification) in
                    completion(notification)
                })
                break
            }
            
       
        }, withCancel: { (error) in
            print("error trying to fetch comments", error)
        })
        }
        return (observe, ref)
        
    }
    
    fileprivate func getComments(notificationId: String, dictionary: [String: Any], completion: @escaping(NotificationModel)->()){
 
        guard let postId = dictionary["postId"] as? String else { return }
        guard let commentId = dictionary["commentId"] as? String else { return }
      

        ref.child("posts").child(postId).observeSingleEvent(of: .value, with: { (postSnap) in
            
           let json = JSON(postSnap.value ?? [:]).dictionaryValue
            self.ref.child("comments").child(postId).child(commentId).observeSingleEvent(of: .value, with: { (snap) in
                
            
            guard let commentData = snap.value as? [String: Any] else { return }
            guard let uid = commentData["uid"] as? String else { return }
            
            //Get user data
            self.ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (userSnap) in
                
                let userValues = JSON(userSnap.value ?? [:])
                let dataUser = (key: uid, value: userValues)
                let u = UserModel.User(userObject: dataUser)
                
                var notification = NotificationModel(notificationId: notificationId, dictionary: dictionary)
                
                let comment = Comment(user: u, commentId: commentId, dictionary: commentData)
                let post = Post(user: u, postId: postId, post: json)
                
                notification.comment = comment
                notification.post = post
                completion(notification)
                
                
            }, withCancel: { (error) in
                   print("error trying to get user info", error)
            })
            
        }) { (error) in
            print("error trying to get the comment post", error)
            
        }
        
        }) { (error) in
            print("error trying to fetch post id:\(postId)", error)
        }
    }
    
    
    
    fileprivate func getRatingPost(notificationId: String, dictionary: [String: Any], completion: @escaping(NotificationModel)->()){
        
        guard let postId = dictionary["postId"] as? String else { return }
        guard let uId = dictionary["fromUid"] as? String else { return }
        
        ref.child("posts").child(postId).observeSingleEvent(of: .value, with: { (postSnap) in
            
            let json = JSON(postSnap.value ?? [:]).dictionaryValue
        
            self.ref.child("rating-posts").child(postId).child(uId).observeSingleEvent(of: .value, with: { (ratingSnap) in
            
            let ratingData = JSON(ratingSnap.value ?? [:]).dictionaryValue
            guard let ratingValue = ratingData["value"]?.doubleValue else {return}
            
            //Get user data
            self.ref.child("users").child(uId).observeSingleEvent(of: .value, with: { (userSnap) in
                
                let userValues = JSON(userSnap.value ?? [:])
                let dataUser = (key: uId, value: userValues)
                let u = UserModel.User(userObject: dataUser)
                
                var notification = NotificationModel(notificationId: notificationId, dictionary: dictionary)
                let post = Post(user: u, postId: postId, post: json)
                notification.user = u
                notification.rating = ratingValue
                notification.post = post
                
                completion(notification)
                
            }, withCancel: { (error) in
                print("error trying to get user info", error)
            })
            
            
        }) { (error) in
            print("error trying to fetch post id:\(postId)", error)
        }
            
        }) { (error) in
            print("error trying to fetch post id:\(postId)", error)
        }
    }
    
    fileprivate func getUserRating(notificationId: String, dictionary: [String: Any], completion: @escaping(NotificationModel)->()){
        
        guard let ratingId = dictionary["ratingId"] as? String else { return }
        
        guard let currentUser = self.uid else {return}
        
        ref.child("user-rating").child(currentUser).child(ratingId).observeSingleEvent(of: .value, with: { (ratingSnap) in
            
            let ratingData = JSON(ratingSnap.value ?? [:]).dictionaryValue
            guard let uid = ratingData["from"]?.stringValue else {return}
            guard let ratingValue = ratingData["value"]?.doubleValue else {return}
            
            //Get user data
            self.ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (userSnap) in
                
                let userValues = JSON(userSnap.value ?? [:])
                let dataUser = (key: uid, value: userValues)
                let u = UserModel.User(userObject: dataUser)
                
                var notification = NotificationModel(notificationId: notificationId, dictionary: dictionary)
                notification.user = u
                notification.rating = ratingValue
                
                completion(notification)
                
            }, withCancel: { (error) in
                print("error trying to get user info", error)
            })
            
            
        }) { (error) in
            print("error trying to fetching user rating", error)
        }
    }
    
    
    fileprivate func getFollower(notificationId: String, dictionary: [String: Any], completion: @escaping(NotificationModel)->()){
        
         guard let uid = dictionary["uid"] as? String else { return }
        guard let currentUser = self.uid else {return}
        
        //Get user data
        self.ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (userSnap) in
            
            let userValues = JSON(userSnap.value ?? [:])
            let dataUser = (key: uid, value: userValues)
            let u = UserModel.User(userObject: dataUser)
        self.ref.child("followers").child(currentUser).child(uid).observeSingleEvent(of: .value, with: { (followerSnap) in
            
            let followValues = JSON(followerSnap.value ?? [:]).dictionaryValue
            
            let followingMe = followValues.count > 0 ? true : false
            
            var notification = NotificationModel(notificationId: notificationId, dictionary: dictionary)
            
            notification.user = u
            notification.followingMe = followingMe
            
            completion(notification)
                
            }, withCancel: { (error) in
                print("error fetching followes")
            })
            
        }, withCancel: { (error) in
            print("error trying to get user info", error)
        })
    }
    
    func addNotification(text: String, private pfb: Bool = false, completion: @escaping (Bool, String)->()){
        
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
    
    func updateNotificationStatus(notificationId: String){
        
        guard let currentUser = uid else { return }
        notiRef.child(currentUser).child(notificationId).updateChildValues(["isNew" : 0])
    }
    
    func countNotification(completion: @escaping(Int)->()){
         guard let currentUser = uid else { return }
        notiRef.child(currentUser).queryOrdered(byChild: "isNew").queryEqual(toValue: 1).observe(.value) { (snap) in
            
            completion(Int(snap.childrenCount))
        }
    }
    
}
