//
//  UserProfileHeaderCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/10/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher

protocol UserProfileHeaderDelegate {
    func didChangeGrid()
    func didChangeList()
}

class UserProfileHeaderCell: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    var photoContainer: ProfilePhotoContainer?
    var userData: UserModel.User? {
        didSet {
            guard let u = userData else { return }
            self.loadUser(user: u)
            
           
            let attributedText = NSMutableAttributedString(string: "\(u.firstName) \(u.lastName)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-Regular", size: 18) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            attributedText.append(NSAttributedString(string: "\n@\(u.username)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            nameAndUsername.attributedText = attributedText
            nameAndUsername.textAlignment = .center
            
            let imageProfile = UIImageView()
            let url = URL(string: u.photoUrlRegular)
            imageProfile.kf.setImage(with: url)
            imageProfile.contentMode = .scaleAspectFill
            imageProfile.layer.masksToBounds = true
            let filterView = UIView()
            filterView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            filterView.frame = self.frame
            self.backgroundView = imageProfile
            self.backgroundView?.addSubview(filterView)
           
        }
    }
    
    fileprivate  let nameAndUsername: UITextView = {
        let t = UITextView()
        t.isEditable = false
        t.isScrollEnabled = false
        t.textAlignment = .center
        t.backgroundColor = .clear
        return t
    }()
    
    let menuBarContainer: UIView = {
        let m = UIView()
        m.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return m
    }()
    
    lazy var gridBtn: UIButton = {
       let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "gridView"), for: .normal)
        btn.addTarget(self, action: #selector(handleGrid), for: .touchUpInside)
        return btn
    }()
    
    lazy var listBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "listView"), for: .normal)
        btn.addTarget(self, action: #selector(handleList), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleGrid(){
        delegate?.didChangeGrid()
    }
    
    @objc func handleList(){
        delegate?.didChangeList()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerSize = CGRect(x: 0, y: 0, width: 150, height: 150)
        photoContainer = ProfilePhotoContainer(frame: containerSize)
        photoContainer?.animationAlpha = 0.5
        photoContainer?.hideNameAndUsername = true
        
        photoContainer?.animation = "slideUp"
        photoContainer?.damping = 1
        photoContainer?.animate()
        
        setupLayout()
    }
    
    func loadUser(user: UserModel.User){
        
        //Loading Name
        photoContainer?.user = user
        
    }
    
    func setupLayout(){
        let stack = UIStackView(arrangedSubviews: [gridBtn, listBtn])
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        let dividerTop = UIView()
        let dividerBottom = UIView()
        
        self.addSubview(photoContainer!)
        self.addSubview(menuBarContainer)
         menuBarContainer.addSubview(stack)
        
        menuBarContainer.addSubview(dividerTop)
        menuBarContainer.addSubview(dividerBottom)
        
        photoContainer?.anchor(top:  nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 120, height: 120)
        
        photoContainer?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
       
        stack.anchor(top: menuBarContainer.topAnchor, left: menuBarContainer.leftAnchor, bottom: menuBarContainer.bottomAnchor, right: menuBarContainer.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        
        menuBarContainer.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        dividerTop.backgroundColor = .white
        dividerTop.anchor(top: menuBarContainer.topAnchor, left: menuBarContainer.leftAnchor, bottom: nil, right: menuBarContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.7)
        
        dividerBottom.backgroundColor = .white
        dividerBottom.anchor(top: nil, left: menuBarContainer.leftAnchor, bottom: menuBarContainer.bottomAnchor, right: menuBarContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.7)
        
       // photoContainer?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
         self.addSubview(nameAndUsername)
        nameAndUsername.anchor(top: nil, left: photoContainer?.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameAndUsername.centerYAnchor.constraint(equalTo: (photoContainer?.centerYAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
