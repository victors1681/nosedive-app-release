//
//  SeachModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class SearchModel {
    
    enum SearchType: String {
        case username, fullname
    }
    
    let table = "users"
    var ref:DatabaseReference! 
    
    init() {
        ref = Database.database().reference().child(table)
        
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
