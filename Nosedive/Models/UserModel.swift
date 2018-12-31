//
//  UserModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/13/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Firebase
import SwiftyJSON

class UserModel {
    
    
    public struct User {
        var id: String
        var firstName: String
        var lastName: String
        var username: String
        var email: String
        var photoUrl: String
        var rating: Double
        var votes: Int
        var isAdmin: Bool = false
        var photoUrlRegular: String
        var isDisable: Bool = false
        
        //For Victor Profile
        var profession: String?
        var biography: String?
        
        
        init(userObject: (key: String, value: JSON)){
            
            let dataUser = userObject.value
            
            self.id = userObject.key
            self.firstName = dataUser["firstName"].string ?? ""
            self.lastName = dataUser["lastName"].string ?? ""
            self.username = dataUser["username"].string ?? ""
            self.email = dataUser["email"].string ?? ""
            self.photoUrl = dataUser["photoUrl"].string ?? ""
            self.rating = dataUser["rating"].double ?? 0.0
            self.votes = dataUser["votes"].int ?? 0
            self.isAdmin = dataUser["isAdmin"].boolValue
            self.photoUrlRegular = dataUser["photoUrlRegular"].string ??  dataUser["photoUrl"].string ?? ""
            self.profession = dataUser["profession"].string ?? ""
            self.biography = dataUser["biography"].string ?? ""
            self.isDisable = dataUser["disabled"].boolValue
        }
    }
    
    var ref: DatabaseReference!
    var reportUserRef: DatabaseReference!
    var blockUserRef: DatabaseReference!
    var refFollowing: DatabaseReference!
    var refFollowers: DatabaseReference!
    let table = "users"
    var currenUser: String?
    var userNameReference: DatabaseReference!
    
    init() {
        self.ref = Database.database().reference().child(table)
        self.refFollowing = Database.database().reference().child("following")
        self.refFollowers = Database.database().reference().child("followers")
        self.currenUser = Auth.auth().currentUser?.uid
        self.userNameReference = Database.database().reference().child("usernames")
        self.reportUserRef = Database.database().reference().child("report-user")
        self.blockUserRef = Database.database().reference().child("block-user")
    }
    func fetchUsers(completion: @escaping ([User]?)->()){
        ref.observeSingleEvent(of: .value) { (snapshot) in
           
            guard let u = JSON(snapshot.value ?? [:]).dictionary else {
                return
            }
            
            let users = self.decodeUsers(json: u)
            
            //Select 30
            let limitTo = 25
            var selectedUsers: [UserModel.User] = [UserModel.User]()
            if users.count > limitTo {
                
                let selected:[Int] = self.generateRandomUniqueNumbers3(forLowerBound: 0, andUpperBound: users.count, andNumNumbers: limitTo)
                
                for index in selected {
                    guard let uselected = users[safe: UInt(index)] else {return}
                    selectedUsers.append(uselected)
                }
                completion(selectedUsers)
            }
            
            completion(users)
        }
        
    }
    
    func generateRandomUniqueNumbers3(forLowerBound lower: Int, andUpperBound upper:Int, andNumNumbers iterations: Int) -> [Int] {
        guard iterations <= (upper - lower) else { return [] }
        var numbers: Set<Int> = Set<Int>()
        (0..<iterations).forEach { _ in
            let beforeCount = numbers.count
            repeat {
                numbers.insert(randomNumber(between: lower, and: upper))
            } while numbers.count == beforeCount
        }
        return numbers.map{ $0 }
    }
    
    func randomNumber(between lower: Int, and upper: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upper - lower))) + lower
    }
    
    func decodeUsers(json: [String: JSON]) ->[User]{
        var users = [User]()
        
        for user in json {
            
            let u = User(userObject: user)
           
            users.append(u)
        }
        
        return users
    }
    
    func updateUserImageUserInfo(url: String, imageName: String, urlThumbnail: String, imageNameThumbnail: String) {
        
        guard let currenUser = Auth.auth().currentUser?.uid else { return }
        let photoData = ["photoUrl": urlThumbnail,
                         "fileName": imageNameThumbnail,
                         "photoUrlRegular": url,
                         "fileNameRegular": imageName]
        self.ref.child(currenUser).updateChildValues(photoData)
        
    }
    
    
    func storeUser(newUid: String, username: String, fullname: String, firstName: String, lastName: String, email: String, fcmToken: String) {
        
        let userInfo = ["username": username.lowercased(),
                        "fullname": "\(firstName.lowercased()) \(lastName.lowercased())",
                        "firstName": firstName.lowercased(),
                        "lastName": lastName.lowercased(),
                        "email": email.lowercased(),
                        "created": [".sv": "timestamp"],
                        "fcmToken": fcmToken,
                        ] as [String : Any]
 
        self.ref.child(newUid).setValue(userInfo, andPriority: nil) { (err, ref) in
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
            
            print("Successfully saved user info to db")
            //Saving username
            self.userNameReference.child(username.lowercased()).setValue(newUid)
        }
       
    }
    
    func updateUserRating(rating: Double, userId: String, votes: Int){
        let dataUser: [String: Any] = ["rating": rating, "votes": votes]
        ref.child(userId).updateChildValues(dataUser)
    }
    
    func updateFcmToken(){
         guard let fcmToken = Messaging.messaging().fcmToken else { return }
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let dataUser: [String: Any] = ["fcmToken": fcmToken]
        ref.child(currentUser).updateChildValues(dataUser)
    }
    
    
    func updateUserAccount(fistName: String, lastName: String){
        let userId = Auth.auth().currentUser!.uid;
        
        let userInfo = ["fullname": "\(fistName.lowercased()) \(lastName.lowercased())",
            "firstName": fistName.lowercased(),
            "lastName": lastName.lowercased(),
        ]
        
        ref.child(userId).updateChildValues(userInfo)
    }
    
    
    func getUserById(uid: String, completion: @escaping (User?)->()){
       
        ref.child(uid).observeSingleEvent(of: DataEventType.value) { (snap) in
            
             let values = JSON(snap.value ?? "")
            
            let userData = (key: uid, value: values)
                let u = User(userObject: userData)
                completion(u)
            
        }
    }
    
    func fetchFollowing(completion: @escaping (User)->())->(observeId: UInt, ref: DatabaseReference) {
        
        var observe:UInt = 0
        
        if let currentUser = self.currenUser  {
            
            observe =  self.refFollowing.child(currentUser).observe(.childAdded, with: { (snap) in
                
                let followerId = snap.key
                
                //Get user data
                self.ref.child(followerId).observeSingleEvent(of: .value, with: { (userSnap) in
                    
                    let userValues = JSON(userSnap.value ?? [:])
                    let dataUser = (key: followerId, value: userValues)
                    let u = UserModel.User(userObject: dataUser)
                    
                    completion(u)
                    
                }, withCancel: { (error) in
                    print("error trying to get user info", error)
                })
                
            }, withCancel: { (error) in
                print("error trying to fetch comments", error)
            })
        }
        return (observe, ref)
        
    }
    
    func fetchTotalFollowers(userId: String, completion: @escaping (_ total: UInt)->()) {
        
        self.refFollowers.child(userId).observe(.value, with: { (snap) in
                
                let total = snap.childrenCount
                
                completion(total)
                
            }, withCancel: { (error) in
                print("error trying to fetch comments", error)
            })
    }
    
    
    func reportUser(user: User, userReported: String, completion: @escaping(_ sucess: Bool)->() ){
        
        
        let reportPostData = ["timestamp": [".sv": "timestamp"],
                              "reportedBy": userReported] as [String : Any]
        
        reportUserRef.child(user.id).child(userReported).updateChildValues(reportPostData) { (err, ref) in
            
            if let err = err {
                print("error reporting this post", err)
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func blockUser(blockTo: String, block:Bool = true, completion: @escaping(_ sucess: Bool)->() ){
        
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
     
        let blockUser = [blockTo: block]
        blockUserRef.child(currentUser).updateChildValues(blockUser) { (err, ref) in
            
            if let err = err {
                print("error blocking user", err)
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func disableUser(uIdTo: String, completion: @escaping(_ sucess: Bool)->() ){
        
        let disable = ["disabled": true]
        self.ref.child(uIdTo).updateChildValues(disable) { (err, ref) in
            
            if let err = err {
                print("error to desactivate user", err)
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func isBloked(uId: String, invert: Bool = false, completion: @escaping(_ blcok: Bool)->()){
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
       
        var ref = blockUserRef!
        if invert {
             ref = ref.child(currentUser).child(uId)
        }else{
             ref = ref.child(uId).child(currentUser)
        }
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            
            guard let blockData = snap.value as? Bool else {
                completion(false)
                return
            }
            completion(blockData)
            
        }) { (error) in
             print("error trying to fetch block user", error)
        }
    }
    
    
    
}
