//
//  Comments.swift
//  Nosedive
//
//  Created by Victor Santos on 1/24/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    var commentId: String
    var creationDate: Date
    var text: String
    var uid: String
    var user: UserModel.User
    
    init(user: UserModel.User, commentId: String, dictionary: [String: Any]) {
        self.user = user
        self.commentId = commentId
        self.text  = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        let creationDate = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationDate / 1000)
    }
}
