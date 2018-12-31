//
//  RatingModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Cosmos
import Firebase
import SwiftyJSON

class RatingModel {
    
    struct Rating {
        var timestamp: Int
        var toUid: String
        var fromUid: String
        var value: Double
    }
    
    var ref: DatabaseReference!
    var ratingRef: DatabaseReference!
    var postRatingRef: DatabaseReference!
    let table = "user-rating"
    var ratingObserved = 0
    
    
    init() {
        self.ref = Database.database().reference()
        self.ratingRef = Database.database().reference().child(table)
        self.postRatingRef = Database.database().reference().child("posts")
    }
    
    func evaluateRating(RatingNumber number: Double) {
        
        let soundEffect = SoundEffects()
        
        switch number {
        case let r where r < 2:
            soundEffect.playRatingSound(ratingSound: .oneStar)
        case let r where r < 3 && r > 1:
            soundEffect.playRatingSound(ratingSound: .twoStars)
        case let r where r < 4 && r > 2:
            soundEffect.playRatingSound(ratingSound: .threeStars)
        case let r where r < 5 && r > 3:
            soundEffect.playRatingSound(ratingSound: .fourStars)
        case let r where r < 6:
            soundEffect.playRatingSound(ratingSound: .fiveStars)
        default:
            return
        }
        
    }
    
    func restartRating(ratingView: CosmosView) {
        
        UIView.animate(withDuration: 5, animations: {
            ratingView.rating = 0
        }, completion: nil)
    }
    
    func addRating(rating: Double, DestinationUser userId: String) {
        
        
        if  let uid = Auth.auth().currentUser?.uid {
            let key = ref.childByAutoId().key
            
            let ratingSent = ["timestamp": [".sv": "timestamp"],
                              "to": userId,
                              "value": rating] as [String : Any]
            
            let ratingReceived  = ["timestamp": [".sv": "timestamp"],
                                   "from": uid,
                                   "value": rating] as [String : Any]
            
            
            let childUpdates = ["/user-rating/\(userId)/\(key)": ratingReceived, //who receive the rating
                "/rating-sent/\(uid)/\(key)/": ratingSent]  //Who send the rating
            
            ref.updateChildValues(childUpdates)
            
        }
    }
    
    func addRatingFromLacie(rating: Double) {
         
        let lacieUid = "ckTjfQPwrjfeBVWfwNS1Q4k1KLi1"
        guard let destinationUser = Auth.auth().currentUser?.uid else {return}

            let key = ref.childByAutoId().key
            
            let ratingSent = ["timestamp": [".sv": "timestamp"],
                              "to": destinationUser,
                              "value": rating] as [String : Any]
            
            let ratingReceived  = ["timestamp": [".sv": "timestamp"],
                                   "from": lacieUid,
                                   "value": rating] as [String : Any]
            
            
            let childUpdates = ["/user-rating/\(destinationUser)/\(key)": ratingReceived, //who receive the rating
                "/rating-sent/\(lacieUid)/\(key)/": ratingSent]  //Who send the rating
            
            ref.updateChildValues(childUpdates)
        
    }
    
    func addPostRating(rating: Double, DestinationUser userId: String, postId: String ) {
        
        
        if  let uid = Auth.auth().currentUser?.uid {
            let key = ref.childByAutoId().key
            
            let ratingSent = ["timestamp": [".sv": "timestamp"],
                              "to": userId,
                              "value": rating,
                              "postId": postId] as [String : Any]
            
            let ratingReceived  = ["timestamp": [".sv": "timestamp"],
                                   "from": uid,
                                   "value": rating,
                                   "postId": postId] as [String : Any]
            
            let postRating  = ["timestamp": [".sv": "timestamp"],
                               "from": uid,
                               "value": rating,
                               "postId": postId] as [String : Any]
            
            
            let childUpdates = ["/user-rating/\(userId)/\(key)": ratingReceived, //who receive the rating
                "/rating-sent/\(uid)/\(key)/": ratingSent, //Who send the rating
                "/rating-posts/\(postId)/\(uid)/": postRating ]
            
            ref.updateChildValues(childUpdates)
            
        }
    }
    
    
    /*
     METHOD DEPRECATED. IT WAS MOVED TO THE SERVER
     */
    
    private func ratingCalculator(json: JSON) -> (Review: Double, Votes:Int){
        
        if json.count == 0 {
            return(0.0, 0)
        }
        
        let ratings = json.dictionaryValue
        
        var ratingArr = [Double]()
        
        for rating in ratings {
            
            let point = rating.value.dictionaryValue
            ratingArr.append(point["value"]?.double ?? 0.0)
            
        }
        
        let mergedKeysAndValues = Dictionary(zip(ratingArr, repeatElement(1, count: ratingArr.count)), uniquingKeysWith: +)
        
        let pointsTotal = ratingArr.reduce(0, +)
        
        //Rating Formula
        //5*cant + 4*cant + 3*cant + 2*cant + 1*cant / totalPoints
        
        
        let sumPoints = mergedKeysAndValues.reduce(into: 0) { (result, data) in
            result +=  Double(data.value)
        }
        
        let reviewComputed = pointsTotal / sumPoints
        
        return (reviewComputed, Int(sumPoints))
    }
    
    func getTotalRatingPerUser(userId: String , completion: @escaping (_ rating: Double, _ votes: Int)->()){
        
        //let observeId =  ratingRef.child(userId).observe(of: .value) { (snap) in
        
        //Update Rating in the user profile
        //Updating happening on the server side. Fixed
        //UserModel().updateUserRating(rating: rating , userId: userId, votes: votes)
        //let (rating, votes) = self.ratingCalculator(json: JSON(snap.value ?? [:]))
        
        //completion(rating, votes)
        //    }
        
    }
    
    func ratingUpdatePostObserve(postId: String, indexPath: IndexPath? = nil, completion: @escaping(_ rating: Double?, _ votes: Int?, _ currentIndexPath: IndexPath?)->())->( UInt,  DatabaseReference){
        
        var observeId:UInt = 0
        let currentRef = postRatingRef.child(postId)
        
        observeId = currentRef.queryLimited(toLast: 5).observe(.childChanged) { (snap) in
            
            if snap.key == "votes" {
                guard let v  = snap.value as? Int else { return }
                    completion(nil, v, indexPath)
            }
            
            if snap.key == "rating" {
                guard let v  = snap.value as? Double else { return }
                    completion(v, nil, indexPath)
              }
        }
        
        return(observeId, currentRef)
    }
    
    private func parseRating(snap: DataSnapshot)->Rating?{
        
        if let lastOne = JSON(snap.value ?? [:]).dictionary {
            
            let value = lastOne["value"]?.double ?? 0
            let fromUser = lastOne["from"]?.string ?? ""
            let time = lastOne["timestamp"]?.intValue ?? 0
            let toUser = lastOne["to"]?.string ?? ""
            
            
            return Rating(timestamp: time, toUid: toUser, fromUid: fromUser, value: value)
            
        }
        return nil
    }
    
    /*
     Observe the last rating inserted
     */
    
    func getTotalRatingObserve(userId: String , completion: @escaping (_ rating: Double, _ votes: Int, _ lastRating: Double, _ userRating: String)->()){
        
        ratingRef.child(userId).queryLimited(toLast: 1).observe(DataEventType.childAdded) { (snap) in
            
            if let dataRating = self.parseRating(snap: snap) {
                //let lastRating = lastOne[userRating]?.double ?? 0
                
                //Get the last value inserted and update the rating
                
                //UpdateRating second query
                
                let ratingRef =  UserModel().ref.child(userId);
                var userObserveId: UInt = 0
                
                userObserveId = ratingRef.observe(DataEventType.value, with: { (snap) in
                    
                    let values = JSON(snap.value ?? "")
                    
                    let userData = (key: userId, value: values)
                    
                    let u = UserModel.User(userObject: userData)
                    
                    //Play Sound
                    if self.ratingObserved != 0 {
                        self.evaluateRating(RatingNumber: dataRating.value)
                    }
                    
                    //Remove observe
                    ratingRef.removeObserver(withHandle: userObserveId)
                    
                    completion(u.rating, u.votes, dataRating.value, dataRating.fromUid)
                    self.ratingObserved += 1
                    
                })
                
            }
        }
    }
    
    
    @objc func vibrationIntensity(rating: Double) {
        
        
        switch rating {
        case let r where r < 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case let r where r > 1 && r<3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case let r where r > 2 && r<4:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case let r where r > 3 && r<5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case let r where r > 4:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        default:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
    
    
    
    func fetchRatings(post: Post, completion: @escaping (RatingList)->())->(observeId: UInt, ref: DatabaseReference) {
        
        var observe:UInt = 0
        let currentRef = ref.child("rating-posts").child(post.postId);
        observe =  currentRef.observe(.childAdded, with: { (snap) in
            
            guard let dictionary = snap.value as? [String: Any] else{ return }
            
            guard let userId = dictionary["from"] as? String else { return }
            
            UserModel().getUserById(uid: userId, completion: { (user) in
                
                guard let u = user else { return }
                let rating = RatingList(user: u, ratingId: snap.key, dictionary: dictionary)
                
                completion(rating)
            })
            
            
        }, withCancel: { (error) in
            print("error trying to fetch comments", error)
        })
        
        return (observe, currentRef)
        
    }
    
}



