//
//  Feedback.swift
//  Nosedive
//
//  Created by Victor Santos on 2/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

struct Feedback {
    
    var id: String
    var user: UserModel.User
    var text: String
    var creationDate: Date
    var isPrivate: Bool
    
    init(user: UserModel.User, feedbackId: String, dictionary: [String: Any]) {
        self.user = user
        self.id = feedbackId
        self.text  = dictionary["text"] as? String ?? ""
        let creationDate = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationDate / 1000)
        let privateFeedback = dictionary["private"] as? Int
        self.isPrivate = privateFeedback == 1 ? true : false
    }
}

