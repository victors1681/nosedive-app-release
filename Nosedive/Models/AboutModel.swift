//
//  AboutModel.swift
//  Nosedive
//
//  Created by Victor Santos on 3/3/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct AboutModel {
    var user: UserModel.User
    var nosedive: String
    var youtubeId: String
    var netfixUrl: String
    var linkedin: String
    var twitter: String
    var mailTo: String
    
    //For Victor Profile
    
    
    init(user: UserModel.User, data: JSON){
        
         
        self.nosedive = data["nosedive"].stringValue
        self.youtubeId = data["youtubeId"].stringValue
        self.netfixUrl = data["netfixUrl"].stringValue
        self.linkedin = data["linkedin"].stringValue
        self.twitter = data["twitter"].stringValue
        self.mailTo = data["mailTo"].stringValue
        self.user = user
        
    }
}
