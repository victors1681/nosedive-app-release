//
//  FeedPostCell.swift
//  Nosedive
//
//  Created by Victor Santos on 1/19/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos
import Lottie

protocol FeedPostDelegate {
    func didTapComment(post:Post, for cell: FeedPostCell)
    func didTapRating(post: Post)
    func didTapOpenRatingView(for cell: FeedPostCell)
    func didTapMoreOption(post: Post, index: Int)
    func didDoubleTap(for cell: FeedPostCell, vote: Double, post: Post)
    func didTapUsername(user: UserModel.User?)
}

class FeedPostCell: UICollectionViewCell {
   

    var delegate: FeedPostDelegate?
    var starAnimation: LOTAnimationView?
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let userProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = iv.frame.width / 2
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.90).cgColor
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.text = "2m"
        label.textColor = .white
        return label
    }()
    
    let viewContainer: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let ve = UIVisualEffectView(effect: effect)
        return ve
    }()
    
    lazy var usernameAndRating: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.tintColor = .white
        tv.isSelectable = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goToLeaveRating))
        gesture.numberOfTapsRequired = 1
        tv.addGestureRecognizer(gesture)
        tv.isUserInteractionEnabled = true
        return tv
    }()
    
    @objc func goToLeaveRating(){
        guard let user = post?.user else { return }
        delegate?.didTapUsername(user: user)
    }
    
    
    //Footer containers
    let ratingContainer: UIView = {
        let v =  UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    lazy var starBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "star-empty"), for: .normal) 
        btn.addTarget(self, action: #selector(openRatingView), for: .touchUpInside)
        return btn
    }()
    
    lazy var moreOptionBtn : UIButton = {
        let btn = UIButton()
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 25)
        btn.setImage(#imageLiteral(resourceName: "options"), for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.contentVerticalAlignment = .center
        btn.addTarget(self, action: #selector(handleMoreOption), for: .touchUpInside)
        return btn
    }()
    
    lazy var starRatedBtn : UIButton = {
        let btn = UIButton()
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        btn.setTitle("42 rated", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return btn
    }()
    
    lazy var commentBtn : UIButton = {
        let btn = UIButton()
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        btn.setTitle("10 comments", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return btn
    }()
    
    lazy var ratingCalculated : UIButton = {
        let btn = UIButton()
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "AvenirNext-UltraLight", size: 16)
        btn.setTitle("2.43", for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(handleListOfRating), for: .touchUpInside)
        return btn
    }()
    
    
    let caption: UITextView = {
        let tv = UITextView()
        tv.text = ""
        tv.font = UIFont(name: "AvenirNext-Regular", size: 13)
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.tintColor = .white
        tv.isSelectable = false
        return tv
    }()
    
    @objc func handleListOfRating(){
        guard let currentPost = post else { return }
        delegate?.didTapRating(post: currentPost)
    }
    
    @objc func openRatingView(){
        delegate?.didTapOpenRatingView(for: self)
    }
    
    @objc func handleRating(){
        guard let currentPost = post else { return }
        delegate?.didTapRating(post: currentPost)
    }
    
    
    @objc func handleComment (){
        guard let currentPost = post else { return }
        delegate?.didTapComment(post: currentPost, for: self)
        
    }
    
    @objc func handleMoreOption (){
        guard let currentPost = post else { return }
        guard let index = indexPath else { return }
        delegate?.didTapMoreOption(post: currentPost, index: index)
        
    }
    
    
    
    var indexPath: Int?
    var post: Post? {
        didSet {
            
            guard let p  = post else { return }
            guard let userInfo = p.user else{ return }
            
            let postUrl  = p.imageUrl
            
            let hasRated = p.hasRated > 0.0 ? true : false
            self.setStateToStarBtn(hasRated)
            self.setCommentCount(p.comments)
            
            let attributedText = NSMutableAttributedString(string: userInfo.username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            
            attributedText.append(NSAttributedString(string: " \(p.caption)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            caption.text = p.caption
            timeLabel.text = p.creationDate.timeAgoDisplay()
            let url = URL(string: postUrl)
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: url)
            backgroundImageView.kf.setImage(with: url)
            let userUrl = URL(string: userInfo.photoUrl)
            userProfileImageView.kf.setImage(with: userUrl)
            
            setPostRating(rating: p.rating)
            
            setRatingVote(p.votes)
            caption.attributedText = attributedText
            
            //User and Rating
            
            let attr = NSMutableAttributedString(string: userInfo.username, attributes: [NSAttributedStringKey.font : UIFont.init(name: "AvenirNext-DemiBold", size: 14) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            let rating = String(format: "%.2f", userInfo.rating)
            
            attr.append(NSMutableAttributedString(string: "\n\(rating)", attributes: [NSAttributedStringKey.font : UIFont.init(name: "AvenirNext-Italic", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white ]))
            
            usernameAndRating.attributedText = attr
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        starAnimation = LOTAnimationView(name: "5star")
        
        
        insertSubview(backgroundImageView, at: 0)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        
        addSubview(viewContainer)
        viewContainer.contentView.addSubview(timeLabel)
        viewContainer.contentView.addSubview(usernameAndRating)
        viewContainer.contentView.addSubview(userProfileImageView)
        viewContainer.contentView.addSubview(photoImageView)
        viewContainer.contentView.addSubview(ratingContainer)
        viewContainer.contentView.addSubview(moreOptionBtn)
        
        
        userProfileImageView.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        
        viewContainer.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        timeLabel.anchor(top: viewContainer.topAnchor, left: nil, bottom: moreOptionBtn.topAnchor, right: viewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        
        moreOptionBtn.anchor(top: timeLabel.bottomAnchor, left: nil, bottom: photoImageView.topAnchor, right: viewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 10, width: 40, height: 18)
        
        usernameAndRating.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: viewContainer.leftAnchor, bottom: ratingContainer.topAnchor, right: viewContainer.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        
        //Footer
        
        ratingContainer.anchor(top: photoImageView.bottomAnchor, left: viewContainer.leftAnchor, bottom: viewContainer.bottomAnchor, right: viewContainer.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        ratingContainer.addSubview(caption)
        ratingContainer.addSubview(starBtn)
        ratingContainer.addSubview(starRatedBtn)
        ratingContainer.addSubview(commentBtn)
        ratingContainer.addSubview(ratingCalculated)
        
        caption.anchor(top: ratingContainer.topAnchor, left: ratingContainer.leftAnchor, bottom: nil, right: ratingContainer.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
        starBtn.anchor(top: caption.bottomAnchor, left: nil, bottom: ratingContainer.bottomAnchor, right: ratingContainer.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
        starRatedBtn.anchor(top: caption.bottomAnchor, left: ratingContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 100, height: 15)
        
        commentBtn.anchor(top: starRatedBtn.bottomAnchor, left: ratingContainer.leftAnchor, bottom: ratingContainer.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 100, height: 15)
        
        ratingCalculated.anchor(top: caption.bottomAnchor, left: nil, bottom: ratingContainer.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 40, height: 40)
        
        ratingCalculated.centerXAnchor.constraint(equalTo: ratingContainer.centerXAnchor).isActive = true
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(leaveFiveStar))
        tap.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(tap)
        photoImageView.isUserInteractionEnabled = true
        
    }
    
    @objc func leaveFiveStar(){
        addSubview(starAnimation!)
        starAnimation!.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        starAnimation?.contentMode = .scaleAspectFit
        SoundEffects().playRatingSound(ratingSound: SoundEffects.RatingSound.fiveStars)
        starAnimation?.play(completion: { (success) in
            UIView.animate(withDuration: 0.8, animations: {
                self.starAnimation?.alpha = 0
            }, completion: { (success) in
                self.starAnimation?.removeFromSuperview()
                self.starAnimation?.alpha = 1
            })
        })
        
        guard let post = post else { return }
        delegate?.didDoubleTap(for: self, vote: 5.0, post: post)
    }
    
    func setStateToStarBtn(_ state:Bool = false ){
        if state {
            self.starBtn.setImage(#imageLiteral(resourceName: "starts-filled"), for: .normal)
        }else{
            self.starBtn.setImage(#imageLiteral(resourceName: "star-empty"), for: .normal)
        }
    }
    
    func setCommentCount(_ count: Int){
        var title = "No comments"
        
        if count == 1 {
            title = "1 comment"
        }else if count > 1 {
            title = "\(count) comments"
        }
        
        commentBtn.setTitle(title, for: .normal)
    }
    
    func setRatingVote(_ count: Int){
        var title = ""
        
        if count > 0 {
            guard let currentPost = post else { return }
            if currentPost.hasFace {
                title = "\(count) likes"
            }else{
                title = "\(count) rated"
            }
        }
        
        starRatedBtn.setTitle(title, for: .normal)
    }
    
    func setPostRating(rating: Double){
        guard let currentPost = post else { return }
        if currentPost.hasFace {
            ratingCalculated.isHidden = true
        }else{
            let ratingCal = String(format: "%.2f", rating)
            ratingCalculated.setTitle(ratingCal, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
