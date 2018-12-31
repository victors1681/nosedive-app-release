//
//  NotificationFollowerCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

protocol UsersViewCellDelegate {
    func didTapFollowBtn(cell: UserViewCell)
    func didTapCell(cell: UserViewCell)
}

class UserViewCell: UICollectionViewCell {
    
    var delegate: UsersViewCellDelegate?
    
    var user: UserModel.User? {
        didSet {
            
            
            guard let user = user else { return }
            
            let username = user.username
            
            let attributedText = NSMutableAttributedString(string: "@\(username)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            let rating = String(format: "%.2f", user.rating)
            attributedText.append(NSAttributedString(string: "  \(rating) - \(user.votes) votes \n", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            
            attributedText.append(NSAttributedString(string: "  \(user.firstName) \(user.lastName)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            textView.attributedText = attributedText
            
          
            followBtn.setImage(#imageLiteral(resourceName: "check_favorite"), for: .normal) 
            
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
        
        addSubview(followBtn)
        
        let viewTap = UIView()
        
        addSubview(viewTap)
        viewTap.addSubview(textView)
        viewTap.addSubview(profileImageView)
        
        viewTap.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUserSelection))
        viewTap.addGestureRecognizer(tap)
        
        viewTap.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: followBtn.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        
        textView.anchor(top: viewTap.topAnchor, left: profileImageView.rightAnchor, bottom: viewTap.bottomAnchor, right: viewTap.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: viewTap.topAnchor, left: viewTap.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        followBtn.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 60, height: 50)
    }
    
    @objc func handleUserSelection(){
        delegate?.didTapCell(cell:self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


