//
//  NotificationController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let reuseIdentifierComment = "CellComment"
private let reuseIdentifierRating = "CellRating"
private let reuseIdentifierFollower = "CellFollower"

class NotificationController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NotificationFollowerCellDelegate, NotificationRatingDelegateCell {
    
    let transition = CircularTransition()
    var observeId: UInt = 0
    var currentRef: DatabaseReference!
    var notifications: [NotificationModel] = [NotificationModel]()
    
    
    func fetchAllNotification(){
        let observeInfo =  NotificationFRController().fetchNotifications { (notification) in
            self.notifications.append(notification)
            self.notifications.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            self.noData.isHidden = true
        }
        
        self.observeId = observeInfo.observeId
        self.currentRef = observeInfo.ref
    }
    
    
    lazy var noData: UILabel = {
        let lb = UILabel()
        lb.text = "There not notifications available"
        lb.textColor = .white
        lb.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        return lb
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setClearBackground(view: self.view)
        
        // Register cell classes
        self.collectionView!.register(NotificationCommentCell.self, forCellWithReuseIdentifier: reuseIdentifierComment)
        self.collectionView!.register(NotificationRatingCell.self, forCellWithReuseIdentifier: reuseIdentifierRating)
        self.collectionView!.register(NotificationFollowerCell.self, forCellWithReuseIdentifier: reuseIdentifierFollower)
        
        self.collectionView?.register(NotificationHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        view.addSubview(closeBtn)
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 35, height: 35, safeArea: true, view: self.view)
        
        fetchAllNotification()
        transition.delegate = self
        
        let dismissControl = UIRefreshControl()
        dismissControl.tintColor = UIColor.clear
        dismissControl.addTarget(self, action: #selector(handleDismissView), for: .valueChanged)
        collectionView?.refreshControl = dismissControl
        
        
        self.view.addSubview(noData)
        noData.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        noData.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        noData.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 50)
        
    }
    
    @objc func handleDismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.currentRef.removeObserver(withHandle: self.observeId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! NotificationHeaderCell
        
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 60)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = self.notifications[indexPath.item].type
        
        switch type {
        case .comment:
            
            
            let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierComment, for: indexPath) as! NotificationCommentCell
            currentCell.notification = self.notifications[indexPath.item]
            
            return currentCell
            
        case .userRating:
            let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierRating, for: indexPath)  as!  NotificationRatingCell
            currentCell.notification = self.notifications[indexPath.item]
            currentCell.delegate = self
            return currentCell
            
        case .follower:
            let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierFollower, for: indexPath)  as!  NotificationFollowerCell
            currentCell.notification = self.notifications[indexPath.item]
            currentCell.delegate = self
            
            return currentCell
            
        case .ratingPost:
            let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierRating, for: indexPath)  as!  NotificationRatingCell
            currentCell.notification = self.notifications[indexPath.item]
            currentCell.delegate = self
            return currentCell
        }
    }
    
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let type = self.notifications[indexPath.item].type
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        var estimatedSize: CGSize?
        
        switch type {
        case .comment:
            let dummyCell = NotificationCommentCell(frame: frame)
            dummyCell.notification = notifications[indexPath.item]
            dummyCell.layoutIfNeeded()
            estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
            
        case .ratingPost:
            let dummyCell = NotificationRatingCell(frame: frame)
            dummyCell.notification = notifications[indexPath.item]
            dummyCell.layoutIfNeeded()
            estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        case .userRating:
            let dummyCell = NotificationRatingCell(frame: frame)
            dummyCell.notification = notifications[indexPath.item]
            dummyCell.layoutIfNeeded()
            estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        case .follower:
            let dummyCell = NotificationFollowerCell(frame: frame)
            dummyCell.notification = notifications[indexPath.item]
            dummyCell.layoutIfNeeded()
            estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        }
        
        guard let s = estimatedSize else { return CGSize(width: view.frame.width, height: 0) }
        
        let height = max(60, s.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func didTapFollowBtn(cell: NotificationFollowerCell) {
        
        cell.followBtn.isEnabled = false
        guard let user = cell.notification?.user else {return }
        
        FollowFRController().followAction(following: user.id) { (isFollowing) in
            
            if isFollowing {
                cell.followBtn.setImage(#imageLiteral(resourceName: "check_favorite"), for: .normal)
            }else{
                cell.followBtn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
            }
            
            cell.followBtn.isEnabled = true
        }
    }
    
    func didRateBack(cell: NotificationRatingCell) {
        
        let leaveRating = RatingMainViewController()
        leaveRating.userData = cell.notification?.user
        
        leaveRating.transitioningDelegate = self
        leaveRating.modalPresentationStyle = .custom
        
        self.present(leaveRating, animated: true, completion: nil)
        
    }
    
    
}

extension NotificationController: CircularTransitionDelegate, UIViewControllerTransitioningDelegate {
    func transitionDismissCallBack(controller: CircularTransition) {
        self.dismiss(animated: true, completion: nil)
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
}
