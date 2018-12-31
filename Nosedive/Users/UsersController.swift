//
//  NotificationController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/17/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifierFollower = "CellFollower"

class UsersController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UsersViewCellDelegate {
    
    let transition = CircularTransition()
    var observeId: UInt = 0
    var currentRef: DatabaseReference!
    var users = [UserModel.User]()
    
    
    func fetchAllFollowers(){
    
        let observeInfo = UserModel().fetchFollowing { (user) in
            self.users.append(user)
            self.collectionView?.reloadData()
            self.noData.isHidden = true
        }
        
        self.observeId = observeInfo.observeId
        self.currentRef = observeInfo.ref
    }
    
    lazy var noData: UILabel = {
       let lb = UILabel()
        lb.text = "You do not have favorite people yet"
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
        self.collectionView!.register(UserViewCell.self, forCellWithReuseIdentifier: reuseIdentifierFollower)
        
        self.collectionView?.register(UsersHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        view.addSubview(closeBtn)
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 35, height: 35, safeArea: true, view: self.view)
        
        fetchAllFollowers()
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
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UsersHeaderCell
        
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 60)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
            let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierFollower, for: indexPath)  as!  UserViewCell
            currentCell.user = self.users[indexPath.item]
            currentCell.delegate = self
        
            return currentCell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierFollower, for: indexPath) as! UserViewCell
        
        didTapCell(cell: currentCell)
    }
    
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        var estimatedSize: CGSize?
        
        let dummyCell = UserViewCell(frame: frame)
            dummyCell.user = users[indexPath.item]
            dummyCell.layoutIfNeeded()
            estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        
        guard let s = estimatedSize else { return CGSize(width: view.frame.width, height: 0) }
        
        let height = max(60, s.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func didTapFollowBtn(cell: UserViewCell) {
        
        cell.followBtn.isEnabled = false
        guard let user = cell.user else {return }
        
        FollowFRController().followAction(following: user.id) { (isFollowing) in
            
            if isFollowing {
                cell.followBtn.setImage(#imageLiteral(resourceName: "check_favorite"), for: .normal)
            }else{
                cell.followBtn.setImage(#imageLiteral(resourceName: "add_favorite"), for: .normal)
            }
            
            cell.followBtn.isEnabled = true
        }
    }
    
    func didTapCell(cell: UserViewCell) {
        
        let leaveRating = RatingMainViewController()
        leaveRating.userData = cell.user
        
        leaveRating.transitioningDelegate = self
        leaveRating.modalPresentationStyle = .custom
        
        self.present(leaveRating, animated: true, completion: nil)
        
    }

}

extension UsersController: CircularTransitionDelegate, UIViewControllerTransitioningDelegate {
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
