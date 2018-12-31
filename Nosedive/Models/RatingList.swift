//
//  Rating.swift
//  Nosedive
//
//  Created by Victor Santos on 1/24/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Firebase

struct RatingList {
    var ratingId: String
    var creationDate: Date
    var value: Double
    var uid: String
    var user: UserModel.User
    
    init(user: UserModel.User, ratingId: String, dictionary: [String: Any]) {
        self.user = user
        self.ratingId = ratingId
        self.value  = dictionary["value"] as? Double ?? 0.0
        self.uid = dictionary["uid"] as? String ?? ""
        let creationDate = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationDate / 1000)
    }
}

