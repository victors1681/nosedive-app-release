//
//  PhotoContainer.swift
//  Nosedive
//
//  Created by Victor Santos on 1/28/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher
import Spring
import Lottie

class ProfilePhotoContainer: SpringView {
    
    var animationAlpha: CGFloat = 1.0 {
        didSet {
            circularAnimation?.alpha = animationAlpha
        }
    }
    var hideNameAndUsername: Bool = false {
        didSet {
             nameAndUsername.isHidden = hideNameAndUsername
        }
    }
    
    var user: UserModel.User? {
        didSet{
        guard let u = user else { return }
        
        let url = URL(string: u.photoUrl  )
        photoUser.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        
        
        let attributedText = NSMutableAttributedString(string: "\(u.firstName) \(u.lastName)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-Regular", size: 18) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: "\n@\(u.username)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        nameAndUsername.attributedText = attributedText
        nameAndUsername.textAlignment = .center
        }
    }
    
    var circularAnimation: LOTAnimationView?
    
    fileprivate lazy var photoUser: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 100 / 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
   fileprivate let photoContainer: UIView = {
        let v = UIView()
        return v
    }()
    
  fileprivate  let nameAndUsername: UITextView = {
        let t = UITextView()
        t.isEditable = false
        t.isScrollEnabled = false
        t.textAlignment = .center
        t.backgroundColor = .clear
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   fileprivate func setupView() {
    
        let size = self.frame.height
    
        photoUser.layer.cornerRadius = (size - 70) / 2
    
        circularAnimation = self.profileAnimation(containerView: self, profilePhoto:  photoUser)
   
    
        self.addSubview(circularAnimation!)
        self.addSubview(photoUser)
        self.addSubview(nameAndUsername)
    
    
        circularAnimation?.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
        photoUser.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: (size - 70), height: (size - 70))
        
        photoUser.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        photoUser.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        photoUser.layer.borderWidth = 1
        
        nameAndUsername.anchor(top: photoUser.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        nameAndUsername.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
    
    
    
        
    }
}
