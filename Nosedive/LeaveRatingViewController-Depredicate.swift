//
//  LeaveRatingViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher
import Spring
import Lottie
import SwiftyJSON
import Firebase

class LeaveRatingViewControllerDepredicate: UIViewController {
    
    let counter: CountingRating = {
        let c = CountingRating()
        c.font = UIFont(name: "AvenirNext-UltraLight", size: 95)
        c.textColor = UIColor.white
        return c
    }()
    let votes: SpringLabel = {
        let label = SpringLabel()
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 24)
        label.textColor = UIColor.white
        return label
    }()
    
    let helpText: SpringLabel = {
        let label = SpringLabel()
        label.text = "select and swipe up"
        label.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
        label.font = UIFont(name: "AvenirNext-Reguar", size: 15)
        return label
    }()
    
    let isSmallScreen : Bool = {
        let size =  Device.IS_4_INCHES_OR_SMALLER()
        return size
    }()
    
    var userData: UserModel.User?
    let userModel = UserModel()
    let ratingModel = RatingModel()
    var swipeControl = false
    var observeId: UInt = 0
    var userRef: DatabaseReference!
    
    let closeBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    let followBtn: SpringButton = {
        let btn = SpringButton()
        btn.setTitle("favorite", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        btn.imageEdgeInsets =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
 
        btn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
        btn.layer.cornerRadius = 3
        
        btn.addTarget(self, action: #selector(handleFollower), for: .touchUpInside)
        return btn
    }()
    
    let photosBtn: SpringButton = {
        let btn = SpringButton()
        btn.setTitle("photos", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        btn.imageEdgeInsets =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
          btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "photo-icon-profile"), for: .normal)
        return btn
    }()
    
    let optinons: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        btn.addTarget(self, action: #selector(optinonsActionBtn), for: .touchUpInside)
        return btn
    }()
    
    var photoContainer: ProfilePhotoContainer?
    var swipeUpAnimation: LOTAnimationView?
    var favoriteAdded: LOTAnimationView?
    
    
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
    
    var didRate = false
    
    @objc func optinonsActionBtn(){
        self.userOptions()
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
      
        photoContainer?.alpha = 0
        super.viewDidLoad()
        cosmosView.settings.fillMode = .half
        cosmosView.contentMode = .scaleAspectFit
        cosmosView.layer.masksToBounds = true
        cosmosView.rating = 0
        
        
         initSwipe()
        
        followBtn.alpha = 0
       
        let photoSize = isSmallScreen ? 160 : 220
        let containerSize = CGRect(x: 0, y: 0, width: photoSize, height: photoSize)
        photoContainer = ProfilePhotoContainer(frame: containerSize)
        
        cosmosView.didTouchCosmos = { rating in
            self.ratingModel.vibrationIntensity(rating: rating)
        }
        
        swipeUpAnimation = LOTAnimationView(name: "accept_arrows")
        favoriteAdded = LOTAnimationView(name: "favorite-star")
        favoriteAdded?.contentMode = .scaleAspectFit
        
        setupView()
       
        observeUserRating()
        
       
        
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
    
    
    var initialAnimation = true
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if initialAnimation {
            followBtn.animation = "slideLeft"
            followBtn.animate()
        
            photosBtn.animation = "slideRight"
            photosBtn.animate()
            initialAnimation = false
            
            swipeUpAnimation?.contentMode = .scaleAspectFit
            swipeUpAnimation?.play()
            swipeUpAnimation?.loopAnimation = true
            
            guard let ud = userData else { return }
            loadUser(user: ud)
        }
        
        observeUserRating()
        checkIsBloked()
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        userRef.removeObserver(withHandle: self.observeId)
 
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
    func closeView (alert: UIAlertAction!){
        self.dismiss(animated: true, completion: nil)
    }
    //Set Icon stile to following or not
    
    func isFollowing(_ following: Bool){
        if following {
            self.followBtn.setImage(#imageLiteral(resourceName: "check_favorite").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            self.followBtn.imageView?.tintColor = UIColor.white
            self.followBtn.layer.borderColor = UIColor(red:0.49, green:0.83, blue:0.13, alpha:1.00).cgColor
            self.followBtn.backgroundColor = UIColor(red:0.49, green:0.83, blue:0.13, alpha:1.00)
        }else{
            self.followBtn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
            self.followBtn.layer.borderColor = UIColor.clear.cgColor
            self.followBtn.backgroundColor = UIColor.clear
        }
    }
    
    @objc func goToUserProfile(){
        let userProfile = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfile.userData = self.userData
        self.present(userProfile, animated: true, completion: nil)
    }
    
    @objc func handleFollower(){
        followBtn.isEnabled = false
        guard let user = userData else {return }
        
        FollowFRController().followAction(following: user.id) { (isFollowing) in
          
            self.isFollowing(isFollowing)
            
            if isFollowing {
                self.favoriteAdded?.isHidden = false
                self.favoriteAdded?.alpha = 1
                self.favoriteAdded?.play(completion: { (success) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.favoriteAdded?.alpha = 0
                    }, completion: { (complete) in
                        self.favoriteAdded?.isHidden = true
                    })
                })
                
            }
            
            self.followBtn.isEnabled = true
        }
    }
    
    func setupView(){
        
        view.addSubview(counter)
        view.addSubview(votes)
        view.addSubview(closeBtn)
        view.addSubview(optinons)
        
        optinons.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 30, safeArea: true, view: self.view)
        
        let cosmosStarSize: Double = isSmallScreen ? 40 : 60
        cosmosView.settings.starSize = cosmosStarSize
        
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 30, height: 30, safeArea: true, view: self.view)
        
        view.addSubview(photoContainer!)
       
        let photoContainerSize: CGFloat = isSmallScreen ? 170 : 240
        photoContainer?.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: photoContainerSize, height: photoContainerSize)
        
      photoContainer?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let photoContainerContant: CGFloat = isSmallScreen ? -10 : -50
        photoContainer?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: photoContainerContant).isActive = true
       
 
        self.view.addSubview(swipeUpAnimation!)
        
        let swipeUpSize: CGFloat = isSmallScreen ? 20: 50
        swipeUpAnimation?.anchor(top: photoContainer?.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: swipeUpSize, height: swipeUpSize)
        
        let angle = CGFloat(Double.pi / 2)
        swipeUpAnimation?.transform = CGAffineTransform.identity.rotated(by: -angle)
        swipeUpAnimation?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(cosmosView)
        cosmosView.anchor(top: swipeUpAnimation?.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cosmosView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let counterFont: CGFloat = isSmallScreen ? 70 : 95
        let counterPadding: CGFloat = isSmallScreen ? 10 : 20
        counter.font = UIFont(name: "AvenirNext-UltraLight", size: counterFont)
        counter.anchor(top: nil, left: view.leftAnchor, bottom: photoContainer?.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: counterPadding, paddingRight: 20, width: 0, height: 80)
        counter.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        counter.textAlignment = .center
        
        votes.anchor(top: nil, left: view.leftAnchor, bottom: photoContainer?.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 120, width: 50, height: 30)
  
        votes.textAlignment = .right
        
        view.addSubview(followBtn)
        followBtn.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 80, height: 20)
        
        followBtn.centerYAnchor.constraint(equalTo: (photoContainer?.centerYAnchor)!).isActive = true
        
        view.addSubview(photosBtn)
        photosBtn.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 28, width: 80, height: 20)
        photosBtn.centerYAnchor.constraint(equalTo: (photoContainer?.centerYAnchor)!).isActive = true
        
        self.view.addSubview(favoriteAdded!)
        favoriteAdded?.isHidden = true
        favoriteAdded?.anchor(top: photoContainer?.topAnchor, left: photoContainer?.leftAnchor, bottom: photoContainer?.bottomAnchor, right: photoContainer?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0 )
        favoriteAdded?.centerXAnchor.constraint(equalTo: (photoContainer?.centerXAnchor)!).isActive = true
        
        favoriteAdded?.centerYAnchor.constraint(equalTo: (photoContainer?.centerYAnchor)!).isActive = true
        
        view.addSubview(helpText)
        
        helpText.anchor(top: cosmosView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
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
        photoContainer?.user = user
        
        photoContainer?.animation = "slideUp"
        photoContainer?.damping = 1
        photoContainer?.animate()
     
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    

    
    func initSwipe() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeViewUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
         let swipeViewDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        swipe.direction = UISwipeGestureRecognizerDirection.up
        swipeViewUp.direction = UISwipeGestureRecognizerDirection.up
        swipeViewDown.direction = UISwipeGestureRecognizerDirection.down
        
        self.view.addGestureRecognizer(swipeViewUp)
        self.view.addGestureRecognizer(swipeViewDown)
        
        cosmosView.addGestureRecognizer(swipe)
     
        
    }
    
    
    @objc func respondeToSwipeGesture(gesture: UIGestureRecognizer) {
        
        
        if let swipe = gesture as? UISwipeGestureRecognizer {
            
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.up:
                if(animationTimer != nil ) {return}
                let vote = cosmosView.rating
                if Int(vote) == 0 {  self.animationHelper(); return }
                
                 ratingModel.evaluateRating(RatingNumber: vote)
                print("Swipe Detected", vote)
                 
                 ratingModel.restartRating(ratingView: cosmosView)
                
                //Post Vote
                ratingModel.addRating(rating: vote, DestinationUser: userData!.id)
                didRate = true
                
            default:
                break
            }
           
        }
    }
    
    func observeUserRating(){
        
        guard let dataUser = self.userData else { return }
        userRef = userModel.ref.child(dataUser.id)
   
        observeId = userRef.observe(.value, with: { (snap) in
            
            let values = JSON(snap.value ?? "")
            
            let userData = (key: dataUser.id, value: values)
      
            let u = UserModel.User(userObject: userData)
            guard let currentRating = self.userData?.rating else { return }
            
        self.counter.count(fromValue: Float(currentRating), toValue: Float(u.rating), withDuration: 2, andAnimationType: CountingRating.CounterAnimationType.EaseIn, andCounterType: .Float)
            
         self.votes.text = String(u.votes)
            
            if(self.didRate){
                self.dismiss(animated: true, completion: nil)
            }
        })
        
    }
    
    
    //MARK: TUTORIAL ANIMATION
    
    var animationTimer:Timer?
    func animationHelper(){
        helpText.animation = "shake"
        helpText.animate()
        
        if(animationTimer == nil){
            animationTimer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(animateStar), userInfo: nil, repeats: true)
        }
    }
    
    var starTest = 0.0
    @objc func animateStar(){
        if(starTest < 5.0) {
            self.cosmosView.rating = Double(starTest)
            starTest += 0.5
        }else{
            animationTimer?.invalidate()
            animationTimer = nil
            animationTimer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(animateStarOut), userInfo: nil, repeats: true)
        }
    }
    
    @objc func animateStarOut(){
        
        if(starTest > 0){
            starTest -= 0.5
            self.cosmosView.rating = Double(starTest)
        }else{
            animationTimer?.invalidate()
            animationTimer = nil
            starTest = 0.0
        }
    }
    
    
    
    func userOptions() {
        let alertController = UIAlertController(title: nil, message: "Report or block user", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Report", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            guard let user = self.userData else { return }
            UserModel().reportUser(user: user, userReported: currentUser, completion: { (sucess) in
                
                if sucess {
                    let alert = UIAlertController(title: "Reported", message: "This user has been reported to the administrator. Thank You", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Reported", message: "Error trying to report this post please check your internet connection", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
            })
        })
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
           
            guard let uid = self.userData?.id else {return}
            UserModel().blockUser(blockTo: uid, completion: { (isBlock) in
                if isBlock {
                    let alert = UIAlertController(title: "User Blocked", message: "This user is no longer available to see your profile", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Blocked", message: "Error blocking this user, please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        let unBlockAction = UIAlertAction(title: "Unblocking", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
            guard let uid = self.userData?.id else {return}
            UserModel().blockUser(blockTo: uid, block: false, completion: { (isBlock) in
                if isBlock {
                    let alert = UIAlertController(title: "User Unblocked", message: "This user is allow to see your profile", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Unbloked", message: "Error unblocking this user, please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        let removeAction = UIAlertAction(title: "Disable User", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            // Do some destructive action here.
            guard let uid = self.userData?.id else {return}
            UserModel().disableUser(uIdTo: uid, completion: { (success) in
                if success {
                    let alert = UIAlertController(title: "User Disabled", message: "User has been disabled", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "User Disabled", message: "Error Disabling this user", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            })
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        
        UserModel().getUserById(uid: currentUserId, completion: { (userData) in
            
            guard let isAdmin = userData?.isAdmin else { return }
            
            if isAdmin {
                alertController.addAction(removeAction)
            }
            
        })
        
         guard let uid = self.userData?.id else {return}
        UserModel().isBloked(uId: uid, invert: true) { (isBloked) in
            if isBloked {
                 alertController.addAction(unBlockAction)
            }else{
                alertController.addAction(blockAction)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

