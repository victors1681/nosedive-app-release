//
//  NotificationRatingCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Cosmos

protocol NotificationRatingDelegateCell {
    func didRateBack(cell: NotificationRatingCell)
}

class NotificationRatingCell: UICollectionViewCell {

    var delegate: NotificationRatingDelegateCell?
    
    var notification: NotificationModel? {
        didSet {
            
            guard let n = notification else { return }
           
            guard let user = n.user else { return }
            
            let username = user.username
            let time = n.creationDate.timeAgoDisplay()
            let ratingStr = String(format: "%.2f", n.rating)
            
            if n.isNew {
                backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.20)
                NotificationFRController().updateNotificationStatus(notificationId: n.id)
            }
            
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            if n.type == .ratingPost {
                 guard let post = n.post else { return }
                attributedText.append(NSAttributedString(string: " rated your post ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
                
                attributedText.append(NSAttributedString(string: " \(ratingStr) ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
                
                let postImage = URL(string: post.imageUrl)
                postImageView.kf.setImage(with: postImage)
                ratingBtn.isHidden = true
                postImageView.isHidden = false
                
            }else if n.type == .userRating {
                attributedText.append(NSAttributedString(string: " rated your ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
                
                attributedText.append(NSAttributedString(string: " \(ratingStr) ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
                
                postImageView.isHidden = true
            }
            
            
            cosmosView.rating = n.rating
            cosmosView.settings.updateOnTouch = false
            
            attributedText.append(NSAttributedString(string: "  \(time)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            textView.attributedText = attributedText
            
            let photoUrl = user.photoUrl
            
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
    
    let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()
    
    lazy var ratingBtn: UIButton = {
       let btn = UIButton()
        btn.setTitle("Rate Back", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 11)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 0.8
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(handleLeaveRating), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var cosmosView: CosmosView = {
        let cosmos = CosmosView()
        cosmos.settings.starSize = 25
        cosmos.settings.fillMode = .half
        cosmos.settings.filledColor = UIColor(red:1.00, green:0.98, blue:0.21, alpha:1.00)
        cosmos.settings.emptyColor = UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.filledBorderColor = .clear
        cosmos.settings.emptyBorderColor =  UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.updateOnTouch = false
        cosmos.settings.starMargin = 5
        cosmos.settings.updateOnTouch = true
        
        return cosmos
    }()
    
    @objc func handleLeaveRating(){
        delegate?.didRateBack(cell: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(postImageView)
        addSubview(cosmosView)
        addSubview(ratingBtn)
        
        cosmosView.anchor(top: textView.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: postImageView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: cosmosView.topAnchor, right: ratingBtn.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        ratingBtn.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 8, width: 70, height: 30)
        
        postImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

