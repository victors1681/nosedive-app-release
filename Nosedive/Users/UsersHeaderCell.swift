//
//  NotificationHeaderCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit


class UsersHeaderCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        
        let attributedText = NSMutableAttributedString(string: "My Favorite Users\n", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 21) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.backgroundColor = UIColor.clear
        tv.attributedText = attributedText
        return tv
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        addSubview(textView)
        
        textView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 120)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


