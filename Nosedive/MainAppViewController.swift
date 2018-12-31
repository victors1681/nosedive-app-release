//
//  MainAppViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Spring
import Kingfisher
import Lottie
import Firebase
import Crashlytics

class MainAppViewController: UIViewController, CircularTransitionDelegate {
    //Delegate called after transition finish, resume the userProfile animation circle
    func transitionDismissCallBack(controller: CircularTransition) {
        userProfileView?.resumeAnimation()
        systemUsersGraph?.startUpdateFrame()
    }
    
    var rewardBasedVideo: GADRewardBasedVideoAd?
    var adRequestInProgress = false

    var isViewSetup = false
    
    let accountBtn : UIButton = {
       let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "setting"), for: .normal)
        btn.addTarget(self, action: #selector(usersActionBtn), for: .touchUpInside)
        return btn
    }()
    let ratingBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "star-icon"), for: .normal)
        btn.addTarget(self, action: #selector(openPost), for: .touchUpInside)
        return btn
    }()
    let searchBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        btn.addTarget(self, action: #selector(searchActionBtn), for: .touchUpInside)
        return btn
    }()
    
    let notificationBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "notiIcon"), for: .normal)
        btn.addTarget(self, action: #selector(handleNotification), for: .touchUpInside)
        return btn
    }()
    
    let photoUser: UIImageView = {
       let iv = UIImageView()
        iv.layer.cornerRadius = 100 / 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 0.5
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let menu: UIButton = {
       let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        btn.addTarget(self, action: #selector(accountActionBtn), for: .touchUpInside)
        return btn
    }()
    
    let smallScreen : Bool = {
        let size =  Device.IS_3_5_INCHES_OR_SMALLER()
        return size
    }()
 
    lazy var rewardBtn: LOTAnimationView = {
       let l = LOTAnimationView(name: "get5star")
        l.contentMode = .scaleToFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleVideoReward))
        l.addGestureRecognizer(tap)
        l.isUserInteractionEnabled = true
        l.backgroundColor = .clear
        
       return l
    }()
    
    let photoContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    let nameAndUsername: UITextView = {
        let t = UITextView()
        t.isEditable = false
        t.isScrollEnabled = false
        t.textAlignment = .center
        t.backgroundColor = .clear
        return t
    }()
    let rating: CountingRating = {
        let t = CountingRating()
        t.textAlignment = .right
        t.backgroundColor = .clear
        t.tintColor = .white
        t.textColor = .white
        t.adjustsFontSizeToFitWidth = true
        t.font = UIFont(name: "AvenirNext-UltraLight", size: 50)
        return t
    }()
    
    let ratingCaunting: UILabel = {
        let t = UILabel()
        t.textAlignment = .right
        t.backgroundColor = .clear
        t.tintColor = .white
        t.textColor = .white
        t.font = UIFont(name: "AvenirNext-UltraLightItalic", size: 19)
        return t
    }()
    let countingContainer: UIView = {
       let c = UIView()
        c.backgroundColor = .clear
        return c
    }()
    
    var userInfo: UserModel.User? {
        didSet {
            guard let user = userInfo else { return }
            
            let attributedText = NSMutableAttributedString(string: "\(user.firstName) \(user.lastName)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-Regular", size: 18) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            let fontSize: CGFloat = smallScreen ? 10 : 14
            attributedText.append(NSAttributedString(string: "\n@\(user.username)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            nameAndUsername.attributedText = attributedText
            nameAndUsername.textAlignment = .center
            
            let ratingFormat = String(format: "%.2f", user.rating)
            let votesFormat = String(format: "\n%d", user.votes)
            
            rating.text = ratingFormat
            ratingCaunting.text = votesFormat
            
            rating.textAlignment = .right
            ratingCaunting.textAlignment = .right
        }
    }
 
    
    let transition = CircularTransition()
    var systemUsersGraph: SystemUsersGraph?
    var userProfileView: UserProfileImageView?
    var fiendInfoFromNotification: UserModel.User?
    var ratingModel = RatingModel()
    var circularAnimation: LOTAnimationView?
    static var userWhoRated: NSNotification.Name = NSNotification.Name("userWhoRated")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       initRewardVideo()
        
        systemUsersGraph = SystemUsersGraph()
        systemUsersGraph?.delegate = self
        self.view.addSubview(systemUsersGraph!)
        
        //Reset badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        transition.delegate = self

        NotificationCenter.default.addObserver(self, selector:#selector(self.reloadAfterBackground), name:NSNotification.Name.UIApplicationWillEnterForeground, object:UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reloadAfterBackground), name:NSNotification.Name.UIApplicationDidBecomeActive, object:UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotToUser(_:)), name: MainAppViewController.userWhoRated, object: nil)
        
 
        self.view.getBackgroundColor()
        self.view.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadUsers()
        self.openInitialMsg()
        
        self.loadUserProfile()
        
        if !isViewSetup {
            
            setupView()
            circularAnimation = self.view.profileAnimation(containerView: photoContainer, profilePhoto:  photoUser)
            
            isViewSetup = true
        }
        updateNotification()
        
        rewardBtn.play()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.systemUsersGraph?.stopUpdateFrame()
    }
    
    func openInitialMsg(){
        if(Helpers().getInitialNotification()){
            let tips = TipsViewController()
            tips.modalPresentationStyle = .overCurrentContext
            self.present(tips, animated: true, completion: nil)
        }
    }
    
    @objc func handleVideoReward(){
        self.startRewardVideo()
    }
    
    @objc func gotToUser(_ notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        
        if let userId = userInfo["fromUserId"] as? String {
            print(userId)
            UserModel().getUserById(uid: userId, completion: { (userData) in
              
                guard let ud = userData else { return }
                self.fiendInfoFromNotification = ud
                self.performSegue(withIdentifier: "ratingView", sender: NotificationCenter())
            })
           
        }
    }
    
    
    @objc func willResignActive(_ notification: Notification) {
        setupView()
        circularAnimation = self.view.profileAnimation(containerView: photoContainer, profilePhoto:  photoUser)

    }
    
    func updateNotification(){
        NotificationFRController().countNotification { (notifications) in
            if notifications  > 0 {
                self.notificationBtn.setImage(#imageLiteral(resourceName: "notiIconAlert"), for: .normal)
            }else{
                self.notificationBtn.setImage(#imageLiteral(resourceName: "notiIcon"), for: .normal)
            }
        }
    }
    
    func setupView(){
        view.addSubview(photoContainer)
        photoContainer.addSubview(photoUser)
        view.addSubview(nameAndUsername)
        countingContainer.addSubview(rating)
        countingContainer.addSubview(ratingCaunting)
        view.addSubview(countingContainer)
        view.addSubview(menu)
        
        view.addSubview(accountBtn)
        view.addSubview(ratingBtn)
        view.addSubview(searchBtn)
        
        
         photoContainer.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, safeArea: true, view: self.view)
        
        photoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let photoUserSize: CGFloat = smallScreen ? 60.0 : 100.0
        photoUser.layer.cornerRadius = photoUserSize / 2
        photoUser.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: photoUserSize, height: photoUserSize)
        
        photoUser.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor).isActive = true
        photoUser.centerYAnchor.constraint(equalTo: photoContainer.centerYAnchor).isActive = true
        
        
        nameAndUsername.anchor(top: photoUser.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        nameAndUsername.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        rating.anchor(top: countingContainer.topAnchor, left: countingContainer.leftAnchor, bottom: nil, right: countingContainer.rightAnchor, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45, safeArea: true, view: self.view)
        
        ratingCaunting.anchor(top: rating.bottomAnchor, left: countingContainer.leftAnchor, bottom: countingContainer.bottomAnchor, right: countingContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        countingContainer.anchor(top: view.topAnchor, left: photoUser.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 15, paddingBottom: 0, paddingRight: 30, width: 0, height: 0, safeArea: true, view: self.view)
        
        menu.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 30, safeArea: true, view: self.view)
        
        //Btns
        self.view.bringSubview(toFront: accountBtn)
        self.view.bringSubview(toFront: searchBtn)
        self.view.bringSubview(toFront: ratingBtn)

        let stack = UIStackView(arrangedSubviews: [accountBtn, ratingBtn, searchBtn])
        view.addSubview(stack)
        stack.distribution = .fillProportionally
        stack.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0, safeArea: true, view: self.view)
        
      
        self.view.addSubview(notificationBtn)
        notificationBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 40, height: 30, safeArea: true, view: self.view)
       
      
        
        view.addSubview(rewardBtn)
        rewardBtn.backgroundColor = .clear
        rewardBtn.anchor(top: menu.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 90 , height: 90)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func searchActionBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "searchView", sender: nil)
    }
    @objc func accountActionBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "accountView", sender: nil)
    }
    @objc func openPost(_ sender: Any) {
        self.performSegue(withIdentifier: "FeedView", sender: true)
    }
    @objc func usersActionBtn(_ sender: Any) {
        let usersController = UsersController(collectionViewLayout: UICollectionViewFlowLayout())
        usersController.modalPresentationStyle = .overCurrentContext
        self.present(usersController, animated: true, completion: nil)
    }
    
}

extension MainAppViewController: UIViewControllerTransitioningDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        self.systemUsersGraph?.stopUpdateFrame()
        
        if segue.identifier!.description == "ratingView" {
            if let userProfile = sender as? UserProfileImageView {
                
                userProfileView = userProfile
                
                transition.startingPoint = (userProfileView?.center)!
                
                let ratingView = segue.destination as! RatingMainViewController
                ratingView.transitioningDelegate = self
                ratingView.modalPresentationStyle = .custom
                ratingView.userData = userProfileView?.userData
            
            }else if let _ =  sender as? NotificationCenter {
                let ratingView = segue.destination as! RatingMainViewController
                ratingView.transitioningDelegate = self
                ratingView.modalPresentationStyle = .custom
                ratingView.userData = self.fiendInfoFromNotification
                
            }
    }
        
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .present
        transition.circleColor = .clear
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }
    
    func logout(){
        
        let alert = UIAlertController(title: "Your ccount is not longer available", message: "User has been disabled", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: gotologin))
        
        self.present(alert, animated: true)
        
    }
    
    func gotologin(alert: UIAlertAction!){
        try! Auth.auth().signOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        self.present(controller, animated: true, completion: nil)
    }
    
}

//User Profile

extension MainAppViewController: SystemUserGraphDelegate {
    func didTapCenterReload() {
        loadUsers()
    }
    
    @objc func reloadAfterBackground(){
        loadUsers()
        circularAnimation?.play()
        circularAnimation?.loopAnimation = true
    }
    
   func loadUsers(){
        
        circularAnimation?.play()
        circularAnimation?.loopAnimation = true
    
    systemUsersGraph?.delegateProtocol = self
    
    guard let currentUser = Auth.auth().currentUser?.uid else  { return }
        
        let users = UserModel()
        users.fetchUsers { (result) in
            self.systemUsersGraph?.removeAllUsers()
            self.systemUsersGraph?.startUpdateFrame()
            
            if let r = result {
                for us in r {
                    
                    if us.isDisable {
                        self.logout()
                    }
                    
                    //Add users
                    if us.id != currentUser {
                        
                        if us.rating > 4.2 && us.votes > 10 {
                         self.systemUsersGraph?.createUserBubble(level: .three, userData: us)
                        }else if us.rating > 4.0 {
                          self.systemUsersGraph?.createUserBubble(level: .two, userData: us)
                        }else{
                            self.systemUsersGraph?.createUserBubble(level: .one, userData: us)
                        }
                    }
                }
            }
        }
    }
    
   @objc func loadUserProfile() {
    if let currentUser = Auth.auth().currentUser?.uid {
        UserModel().getUserById(uid: currentUser, completion: { (userResult) in
            if let user = userResult {
                
                let url = URL(string: user.photoUrl)
                self.photoUser.kf.indicatorType = .activity
                self.photoUser.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
                
                self.userInfo = user
                
                //Run rating observe
                self.updateRating()
                
                Background().setBackgroundImage(photoUser: user.photoUrl, view: self.view)
            }
        })
        
    }else{
        try? Auth.auth().signOut()
    }
    }
    
    @objc func handleNotification(){
        let notificationView = NotificationController(collectionViewLayout: UICollectionViewFlowLayout())
        notificationView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(notificationView, animated: true, completion: nil)

    }
    
    func updateRating(){
        let currentUser = Auth.auth().currentUser?.uid
        let rating = RatingModel()
            rating.getTotalRatingObserve(userId: currentUser!) { (ratingCalculated, votes, lastRating, userRating) in
            
            if self.userInfo != nil {
                
            self.rating.count(fromValue: Float(self.userInfo!.rating), toValue: Float(ratingCalculated), withDuration: 2, andAnimationType: CountingRating.CounterAnimationType.EaseIn, andCounterType: .Float)
                
                self.ratingCaunting.text = String(format: "%d", votes)
                
            }
        }
    }
    
   
}



