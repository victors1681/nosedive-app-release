//
//  PhotoSelectedHeaderCell.swift
//  Nosedive
//
//  Created by Victor Santos on 1/20/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

import UIKit

class PhotoSelectedHeaderCell: UICollectionViewCell {
    
    var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

