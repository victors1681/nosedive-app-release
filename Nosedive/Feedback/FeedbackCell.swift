//
//  FeedbackCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class FeedbackCell: UICollectionViewCell {
    
    var feedback: Feedback? {
        didSet {
            
            guard let c = feedback else { return }
            
            let username = c.user.username
            let time = c.creationDate.timeAgoDisplay()
            
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            attributedText.append(NSAttributedString(string: "    \(time)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            attributedText.append(NSAttributedString(string: "\n \( c.text)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            textView.attributedText = attributedText
            
            let photoUrl = c.user.photoUrl
            
            let url = URL(string: photoUrl)
            profileImageView.kf.setImage(with: url)
        }
    }
    
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
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
