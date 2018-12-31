//
//  NotificationCommentCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//


import UIKit

class NotificationCommentCell: UICollectionViewCell {
    
    var notification: NotificationModel? {
        didSet {
            
            guard let n = notification else { return }
            guard let comment = n.comment else { return }
            guard let post = n.post else { return }
            guard let user = n.comment?.user else { return }
            
            let username = user.username
            let time = n.creationDate.timeAgoDisplay()
            
            if n.isNew {
                backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.20)
                NotificationFRController().updateNotificationStatus(notificationId: n.id)
            }

            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])

            attributedText.append(NSAttributedString(string: " commented your post", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))

            attributedText.append(NSAttributedString(string: "\n \( comment.text)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            attributedText.append(NSAttributedString(string: "  \(time)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))

            textView.attributedText = attributedText

            let photoUrl = user.photoUrl

            let url = URL(string: photoUrl)
            profileImageView.kf.setImage(with: url)
            
            let postImage = URL(string: post.imageUrl)
            postImageView.kf.setImage(with: postImage)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(postImageView)
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: postImageView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: textView.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        postImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 5, paddingBottom: 4, paddingRight: 8, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

