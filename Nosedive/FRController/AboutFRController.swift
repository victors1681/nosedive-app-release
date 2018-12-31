//
//  AboutFRController.swift
//  Nosedive
//
//  Created by Victor Santos on 3/3/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Firebase
import SwiftyJSON

class AboutFRController {
    
    
    var uid: String?
    var ref: DatabaseReference!
    
    init() {
        self.uid = Auth.auth().currentUser?.uid
        self.ref = Database.database().reference()
}

    func getAboutInfo(completion: @escaping (AboutModel)->()) {
        
        self.ref.child("about").observeSingleEvent(of: .value, with: { (aboutSnap) in
            
            let aboutInfo = JSON(aboutSnap.value ?? "")
            
            print(aboutInfo)
            
             let uid = aboutInfo["ownerId"].stringValue
            
            self.ref.child("users").child(uid).observeSingleEvent(of: DataEventType.value) { (snap) in
                
                let values = JSON(snap.value ?? "")
                let userData = (key: uid, value: values)
                let u = UserModel.User(userObject: userData)
                let aboutInfo = AboutModel(user: u, data: aboutInfo)
                
                completion(aboutInfo)
                
            }
            
        }, withCancel: { (error) in
            print("error trying to fetch about nosedive", error)
        });
        
}
}
