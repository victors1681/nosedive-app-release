//
//  RatingMainPhotoCell.swift
//  Nosedive
//
//  Created by Victor Santos on 4/8/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher

protocol PhotoPostDelegate {
    func didTapRating(post: Post)
}

class RatingMainPhotoCell: UICollectionViewCell {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: PhotoPostDelegate?
    lazy var hasRated: Double = 0.0
    lazy var isFace: Bool = false
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var post: Post? {
        didSet {
            guard let p = post else { return }
            let url = URL(string: p.imageUrl)
            photoImageView.kf.indicatorType = .activity
            
            photoImageView.kf.setImage(with: url,  options: [.transition(.fade(0.2))]) { (_, _, _, _) in
                self.addBorder();
            }
            
            setPostRating(rating: Double(p.votes))
            hasRated = p.hasRated
            isFace = p.hasFace
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    lazy var ratingCalculated : UIButton = {
        let btn = UIButton()
        btn.tintColor = .white
        btn.titleLabel?.font = DefaultFont.regular.size(16)
        btn.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:0.60)
        btn.setTitle("0.00", for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.borderWidth = 0
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.layer.cornerRadius = 30
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(handleListOfRating), for: .touchUpInside)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    @objc func handleListOfRating(){
        guard let currentPost = post else { return }
        delegate?.didTapRating(post: currentPost)
    }
    
    private func addBorder(){
        self.layer.borderWidth  = 1
        self.layer.borderColor  = UIColor.white.cgColor
        
    }
    
    func setPostRating(rating: Double){
        guard let p = post else { return }
        if p.hasFace {
            var likes: String = ""
            if Int(rating) == 1 {
               likes = String(format: "%d\nLike", Int(rating))
            }else if Int(rating) > 1 {
                likes = String(format: "%d\nLikes", Int(rating))
            }else if Int(rating) == 0 {
                ratingCalculated.isHidden = true
            }
            
            ratingCalculated.titleLabel?.lineBreakMode = .byWordWrapping
            ratingCalculated.titleLabel?.textAlignment = .center
            ratingCalculated.setTitle(likes, for: .normal)
            ratingCalculated.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }else{
            let ratingCal = String(format: "%.2f", rating)
            ratingCalculated.setTitle(ratingCal, for: .normal)
            ratingCalculated.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.ratingCalculated.alpha = 1
            self.ratingCalculated.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }, completion: { (success) in
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                 self.ratingCalculated.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
         
        })
    }

    
    func setup() {
        self.ratingCalculated.alpha = 0
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width * 0.03
        
        
        self.layer.shadowColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        
        self.addSubview(photoImageView)
        photoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.addSubview(ratingCalculated)
        ratingCalculated.anchor(top: nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 60, height: 60)
    }
    
}
