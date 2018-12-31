//
//  NotificationFollowerCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

protocol NotificationFollowerCellDelegate {
    func didTapFollowBtn(cell: NotificationFollowerCell)
}

class NotificationFollowerCell: UICollectionViewCell {
    
    var delegate: NotificationFollowerCellDelegate?
    
    var notification: NotificationModel? {
        didSet {
            
            guard let n = notification else { return }
            
            guard let user = n.user else { return }
            
            if n.isNew {
                backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.20)
                NotificationFRController().updateNotificationStatus(notificationId: n.id)
            }
            
            let username = user.username
            let time = n.creationDate.timeAgoDisplay()
            
            let attributedText = NSMutableAttributedString(string: "@\(username)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            attributedText.append(NSAttributedString(string: " started following you! ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            
            attributedText.append(NSAttributedString(string: "  \(time)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            textView.attributedText = attributedText
            
            if n.followingMe {
                followBtn.setImage(#imageLiteral(resourceName: "check_favorite"), for: .normal)
            }
            
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
    
    lazy var followBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
        btn.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleFollow(){
        delegate?.didTapFollowBtn(cell: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(followBtn)
        
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: followBtn.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        followBtn.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 60, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


