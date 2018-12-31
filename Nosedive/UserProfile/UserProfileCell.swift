//
//  UserProfileCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/10/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher

class UserProfileCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var post: Post? {
        didSet {
            guard let p = post else { return }
            let url =  URL(string: p.imageUrl)
            imageView.kf.setImage(with: url)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        imageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
