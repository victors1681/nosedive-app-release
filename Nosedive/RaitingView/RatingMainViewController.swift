//
//  UserProfileViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher
import Spring
import Lottie
import SwiftyJSON
import Firebase
import AnimatedCollectionViewLayout

class RatingMainViewController: UIViewController {
    
    let counter: CountingRating = {
        let c = CountingRating()
        c.font = DefaultFont.ultraLight.size(60)
        c.textColor = UIColor.white
        c.textAlignment = .right
        c.adjustsFontSizeToFitWidth = true
        return c
    }()
    let votes: SpringLabel = {
        let label = SpringLabel()
        label.font = DefaultFont.ultraLight.size(20)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let helpText: SpringLabel = {
        let label = SpringLabel()
        label.text = "select and swipe up"
        label.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
        label.font = DefaultFont.regular.size(15)
        return label
    }()
    
    let isSmallScreen : Bool = {
        let size =  Device.IS_4_INCHES_OR_SMALLER()
        return size
    }()
    
    let menuBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        btn.addTarget(self, action: #selector(optinonsActionBtn), for: .touchUpInside)
        return btn
    }()
    
    let closeBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    let followBtn: SpringButton = {
        let btn = SpringButton()
        
        btn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
        btn.layer.cornerRadius =  27.0 / 2
        
        btn.addTarget(self, action: #selector(handleFollower), for: .touchUpInside)
        return btn
    }()
    
    let cosmosView: CosmosView = {
        let cosmos = CosmosView()
        cosmos.settings.starSize = 60
        cosmos.settings.filledColor = UIColor(red:1.00, green:0.98, blue:0.21, alpha:1.00)
        cosmos.settings.emptyColor = UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.filledBorderColor = .clear
        cosmos.settings.emptyBorderColor =  UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.starMargin = 15
        cosmos.settings.updateOnTouch = true
        
        return cosmos
    }()

    
    let userPhoto: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 62.0 / 2.0
        image.layer.borderWidth = 1.0
        image.layer.borderColor = UIColor.white.cgColor
        image.contentMode = .scaleToFill
        return image
    }()
    
    let followers: UITextView = {
        let f = UITextView()
        f.isEditable = false
        f.isSelectable = false
        f.backgroundColor = .clear
        f.textAlignment = .center
        
        return f
    }()
    
    let nameAndUsername: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.textAlignment = .left
        tv.backgroundColor = .clear
        return tv
    }()
    
    let divisionBlock: UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "separator"))
        return imgView
    }()
    
    let headerContainer: UIView = {
        let header = UIView()
        return header
    }()
    
    
    let collectionTitle: UILabel = {
        let l = UILabel()
        l.text = "LATEST  POSTS"
        l.font = DefaultFont.demiBold.size(10)
        l.textColor = UIColor.white
        l.textAlignment = NSTextAlignment.center
        l.centerHorizontally()
        return l
    }()
    
    
    
    var didRate = false
    var userData: UserModel.User?
    let userModel = UserModel()
    let ratingModel = RatingModel()
    var swipeControl = false
    var observeId: UInt = 0
    var userRef: DatabaseReference!
    var initialAnimation = true
    var animationTimer:Timer?
    var starTest = 0.0
    var collectionView: UICollectionView!
    var posts = [Post]()
    
    var previousOffset: CGFloat = 0
    var currentPage: Int = 0
    let space: CGFloat = 30
    let layout = AnimatedCollectionViewLayout()
    var currentPost: IndexPath? = IndexPath(item: 0, section: 0)
    
    //CollectionView
    var selectedFrame: CGRect?
    var postSelected: Post?
    
    
    @objc func optinonsActionBtn(){
        self.userOptions()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.initCosmos()
        self.initCollectionView()
        self.setupView()
        self.initGesture()
        self.observeUserRating()
        
        self.disableCosmos(rating: 0.0)
        
        followBtn.alpha = 1
        
        guard let ud = userData else { return }
        FollowFRController().checkFollowing(following: ud.id) { (following) in
            self.isFollowing(following)
        }
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        if currentUser == ud.id {
            cosmosView.settings.updateOnTouch = false
            followBtn.isHidden = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if initialAnimation {
            
            initialAnimation = false
            
            guard let ud = userData else { return }
            self.loadUser(user: ud)
            self.setFollowers(total: 0)
            self.getTotalFollowers()
        }
        
        observeUserRating()
        checkIsBloked()
        fetchUserPost()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        userRef.removeObserver(withHandle: self.observeId)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emptyPost(){
        guard let user = userData?.firstName else { return }
        let label: UILabel = UILabel()
        
        label.text = "\(user) has not posted"
        label.textAlignment = .center
        label.font = DefaultFont.regular.size(19)
        label.textColor = UIColor.white
        label.alpha = 0
        view.addSubview(label)
        label.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        label.frame.origin.y += 10
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1
            label.frame.origin.y -= 10
        }
        
        //Disable Rating
        cosmosView.settings.updateOnTouch = false
        cosmosView.alpha = 0.4
        
    }
    
    func getTotalFollowers(){
        guard let userId = userData?.id else { return }
        UserModel().fetchTotalFollowers(userId: userId) { (total) in
            self.setFollowers(total: total)
        }
    }
    
    func fetchUserPost(){
        guard let userId = userData?.id else { return }
        
        FeedFRController().fetchPostsPaginate(filter: FeedFRController.PostType.user, uid: userId) { (posts, lastPost) in
            self.posts = posts
            self.collectionView?.reloadData()
            if(posts.count == 0){
                self.emptyPost()
                self.collectionTitle.isHidden = true
            }else{
                self.evaluateFistPost()
            }
        }
    }
    
    func hasFaces(_ face: Bool){
        if face {
            self.cosmosView.settings.totalStars = 1
        }else{
            self.cosmosView.settings.totalStars = 5
        }
    }
    
    func setupView(){
        
        view.addSubview(closeBtn)
        view.addSubview(menuBtn)
        
        menuBtn.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 30, height: 30, safeArea: true, view: self.view)
        
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 30, height: 30, safeArea: true, view: self.view)
        
        //Header
        view.addSubview(headerContainer)
        headerContainer.addSubview(userPhoto)
        headerContainer.anchor(top: menuBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
        userPhoto.anchor(top: headerContainer.topAnchor, left: headerContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 62, height: 62)
        
        headerContainer.addSubview(nameAndUsername)
        nameAndUsername.anchor(top: userPhoto.bottomAnchor, left: headerContainer.leftAnchor, bottom: headerContainer.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: view.frame.width/2.0, height: 50)
        
        headerContainer.addSubview(followBtn)
        followBtn.anchor(top: headerContainer.topAnchor, left: userPhoto.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        headerContainer.addSubview(followers)
        headerContainer.addSubview(counter)
        
        followers.anchor(top: headerContainer.topAnchor, left: followBtn.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 65, height: 50)
        
        
        counter.anchor(top: headerContainer.topAnchor, left: followers.rightAnchor, bottom: nil, right: headerContainer.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 15, width: 0, height: 70)
        
        headerContainer.addSubview(votes)
        votes.anchor(top: counter.bottomAnchor, left: nil, bottom: headerContainer.bottomAnchor, right: headerContainer.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 95, height: 30)
        
        headerContainer.addSubview(divisionBlock)
        divisionBlock.anchor(top: nil, left: headerContainer.leftAnchor, bottom: headerContainer.bottomAnchor, right: headerContainer.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        
        view.addSubview(helpText)
        helpText.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 25, safeArea: true, view: view)
        
        helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        view.addSubview(cosmosView)
        view.addSubview(collectionView)
        
        let cosmosStarSize: Double = isSmallScreen ? 40 : 60
        let cosmosHeightContainer: CGFloat = isSmallScreen ? 50 : 90
        cosmosView.settings.starSize = cosmosStarSize
        
        cosmosView.anchor(top: nil, left: nil, bottom: helpText.topAnchor, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: cosmosHeightContainer)
        cosmosView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        collectionView.anchor(top: headerContainer.bottomAnchor, left: view.leftAnchor, bottom: cosmosView.topAnchor, right: view.rightAnchor, paddingTop: 18, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        
        view.addSubview(collectionTitle)
        collectionTitle.anchor(top: headerContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 75, height: 20)
    }
    
    func loadUser(user: UserModel.User){
        
        //Loading Rating
        counter.count(fromValue: 0, toValue: Float((userData?.rating)!), withDuration: 2, andAnimationType: CountingRating.CounterAnimationType.EaseIn, andCounterType: .Float)
        
        counter.animation = "slideLeft"
        counter.damping = 1
        counter.animate()
        
        //show votes
        votes.text = "\(userData!.votes)"
        votes.animation = "slideLeft"
        votes.damping = 1
        votes.delay = 0.5
        votes.animate()
        
        
        //Loading Name
        let url = URL(string: user.photoUrl)
        userPhoto.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        
        
        let userAttribute = NSMutableAttributedString(string: "\(user.firstName) \(user.lastName)", attributes: [NSAttributedStringKey.font: DefaultFont.regular.size(17), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        userAttribute.append(NSMutableAttributedString(string: "\n@\(user.username)", attributes: [NSAttributedStringKey.font: DefaultFont.regular.size(11), NSAttributedStringKey.foregroundColor: UIColor(red: 255.00, green: 255.0, blue: 255.0, alpha: 0.7)]))
        
        nameAndUsername.attributedText = userAttribute
        
    }
    
    func setFollowers(total: UInt){
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let followersAttribute = NSMutableAttributedString(string: "\(total)", attributes: [NSAttributedStringKey.font: DefaultFont.demiBold.size(15), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
        followersAttribute.append(NSMutableAttributedString(string: "\nFollowers", attributes: [NSAttributedStringKey.font: DefaultFont.regular.size(13), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle]))
        self.followers.attributedText = followersAttribute
        
    }
    
    func checkIsBloked(){
        guard let userId = self.userData?.id else { return }
        userModel.isBloked(uId: userId) { (isBlocked) in
            if isBlocked {
                let alert = UIAlertController(title: ":(", message: "You are no longer to see this profile", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: self.closeView))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    
    
    @objc func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func observeUserRating(){
        
        guard let dataUser = self.userData else { return }
        userRef = userModel.ref.child(dataUser.id)
        
        observeId = userRef.observe(.value, with: { (snap) in
            
            let values = JSON(snap.value ?? "")
            
            let userData = (key: dataUser.id, value: values)
            
            let u = UserModel.User(userObject: userData)
            // guard let currentRating = self.userData?.rating else { return }
            
            //Float(currentRating)
            // Start from cero to see the animation
            self.counter.count(fromValue: 0.0, toValue: Float(u.rating), withDuration: 2, andAnimationType: CountingRating.CounterAnimationType.EaseIn, andCounterType: .Float)
            
            self.votes.text = String(u.votes)
            
        })
        
    }
    
    
}



