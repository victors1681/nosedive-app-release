//
//  RatingCell.swift
//  Nosedive
//
//  Created by Victor Santos on 1/24/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

class RatingCell: UICollectionViewCell {
    
    var rating: RatingList? {
        didSet {
            
            guard let r = rating else { return }
            
            let username = r.user.username
            let time = r.creationDate.timeAgoDisplay()
            
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            attributedText.append(NSAttributedString(string: "  \(time)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            cosmosView.rating = r.value
            cosmosView.settings.updateOnTouch = false
            
            textView.attributedText = attributedText
            textView.centerVertically()
            
            let photoUrl = r.user.photoUrl
            
            let url = URL(string: photoUrl)
            profileImageView.kf.setImage(with: url)
        }
    }
    
    lazy var cosmosView: CosmosView = {
        let cosmos = CosmosView()
        cosmos.settings.starSize = 30
        cosmos.settings.filledColor = UIColor(red:1.00, green:0.98, blue:0.21, alpha:1.00)
        cosmos.settings.emptyColor = UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.filledBorderColor = .clear
        cosmos.settings.emptyBorderColor =  UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.updateOnTouch = false
        cosmos.settings.starMargin = 5
        cosmos.settings.updateOnTouch = true
        cosmos.settings.fillMode = .half
        return cosmos
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "AvenirNext-Regular", size: 13)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isSelectable = false
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(cosmosView)
        
        cosmosView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        cosmosView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

