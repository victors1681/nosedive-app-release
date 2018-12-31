//
//  FeedPosts.swift
//  Nosedive
//
//  Created by Victor Santos on 1/19/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftyJSON

struct Post {
    var postId: String
    var user: UserModel.User?
    var creationDate: Date
    var imageUrl: String
    var caption: String
    var imageHeight: CGFloat
    var imageWidth: CGFloat
    var rating: Double
    var ratings: [String: Double]?
    var hasRated: Double = 0.0
    var comments: Int = 0
    var votes: Int = 0
    var hasFace: Bool = false
    
    init(user: UserModel.User?, postId: String, post pv: [String: JSON] ){
       
        self.postId = postId
      //  let pv = post.value.dictionaryValue
        
        if let u = user {
            self.user = u
        }
        self.caption = pv["caption"]?.stringValue ?? ""
        let creationDate = pv["creationDate"]?.doubleValue ?? 0.0
        self.imageHeight = CGFloat(pv["imageHeight"]?.floatValue ?? 0.0)
        self.imageWidth = CGFloat(pv["imageWidth"]?.floatValue ?? 0.0)
        
        let creationDateDate = Date(timeIntervalSince1970: creationDate/1000)
        self.creationDate = creationDateDate
        
        self.imageUrl = pv["imageUrl"]?.stringValue ?? ""
        self.rating = pv["rating"]?.doubleValue ?? 0
        self.votes = pv["votes"]?.intValue ?? 0
        self.hasFace = pv["hasFace"]?.boolValue ?? false
        
    }
}

