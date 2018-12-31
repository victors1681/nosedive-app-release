//
//  Notification.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case comment
    case ratingPost
    case userRating
    case follower
}

struct NotificationModel {
    
    var id: String
    var type: NotificationType
    var isNew: Bool
    var creationDate: Date
    var user: UserModel.User?
    var comment: Comment?
    var post: Post?
    var rating: Double = 0.0
    var followingMe = false

    
    init(notificationId: String, dictionary: [String: Any]) {
       
        self.id = notificationId
        let typeStr  = dictionary["type"] as? String ?? ""
        
        let creationDate = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationDate / 1000)
        let privateFeedback = dictionary["isNew"] as? Int
        self.isNew = privateFeedback == 1 ? true : false
        
        if let type =  NotificationType(rawValue: typeStr) {
             self.type = type
        }else{
            self.type = .comment
        }
       
    }
}


