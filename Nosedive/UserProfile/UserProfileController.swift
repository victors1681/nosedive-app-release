//
//  UserProfileControllerCollectionViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/10/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let feedCell = "FeedCell"

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, UIViewControllerTransitioningDelegate {
    
    var lastPost: Post?
    var posts = [Post]()
    var userData: UserModel.User?
    var isGridView = true
    
    let backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return btn
    }()
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        self.setClearBackground(view: self.view, style: .light)
        self.collectionView!.register(UserProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(FeedPostCell.self, forCellWithReuseIdentifier: feedCell)
        
        collectionView?.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        
        fetchUserPost()
        
        view.addSubview(backBtn)
        backBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        
        collectionView?.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)
        
    }
    
    func refreshBottom() {
        //api call for loading more data
        print("refreshing")
        //collectionView.bottomRefreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didChangeGrid() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeList() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func fetchUserPost(){
        guard let userId = userData?.id else { return }
        
        FeedFRController().fetchPostsPaginate(filter: FeedFRController.PostType.user, uid: userId) { (posts, lastPost) in
            self.posts = posts
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeaderCell
        
        header.delegate = self
        header.userData = self.userData
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == posts.count - 1 {
            //refreshing
            if let userId = self.userData?.id   {
                
                if let lp = self.lastPost  {
                    FeedFRController().fetchPostsPaginate(lastPost: lp, filter: FeedFRController.PostType.user, uid: userId) { (posts, lastPost) in
                        self.posts.append(contentsOf: posts)
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
        
        if isGridView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserProfileCell
            cell.post = posts[safe: UInt(indexPath.item)]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCell, for: indexPath) as! FeedPostCell
            cell.post = posts[safe: UInt(indexPath.item)]
            cell.indexPath = indexPath.item
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let size = (self.view.frame.width - 2) / 3
            return CGSize(width: size, height: size)
        }
        
        let post = posts[safe: UInt(indexPath.item)]
        
        if let currentPost = post {
            if currentPost.imageWidth >= currentPost.imageHeight {
                //landscape mode
                return CGSize(width: view.frame.width, height: (view.frame.height / 2) + 20)
            }
        }
        return CGSize(width: view.frame.width, height: view.frame.height - 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    var selectedFrame: CGRect?
    var postSelected: Post?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(isGridView){
            let post = posts[safe: UInt(indexPath.item)]
            let destinationController = PhotoDisplayController()
            destinationController.post = post
            postSelected = post
            destinationController.modalPresentationStyle = .custom
            destinationController.transitioningDelegate = self
            //destinationController.transitioningDelegate = self
            
            guard let cellAttr = collectionView.layoutAttributesForItem(at: indexPath) else {return}
            selectedFrame = collectionView.convert(cellAttr.frame, to: collectionView.superview)
            
            
            self.present(destinationController, animated: true, completion: nil)
            
            
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let photoTransition = PhotoTransitionPresented()
        photoTransition.selectedFrame = self.selectedFrame
        photoTransition.postSelected = self.postSelected
        return photoTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoTransition = PhotoTransitionDismissed()
        photoTransition.selectedFrame = self.selectedFrame
        photoTransition.postSelected = self.postSelected
        return photoTransition
    }
    
}



extension UserProfileController: FeedPostDelegate {
    func didTapUsername(user: UserModel.User?) {
        //noting
    }
    
    
    func didTapMoreOption(post: Post, index: Int) {
        // self.confirmDelete(post: post, index: index)
    }
    
    
    func didTapComment(post: Post, for cell: FeedPostCell) {
        //TODO: Fix show comments in modal view
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        commentsController.cell = cell
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapRating(post: Post) {
        
        let ratingList = RatingListController(collectionViewLayout: UICollectionViewFlowLayout())
        
        ratingList.post = post
        self.present(ratingList, animated: true, completion: nil)
    }
    
    
    
    func didTapOpenRatingView(for cell: FeedPostCell){
        
        guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
        guard let currentPost = self.posts[safe: UInt(indexPath.item)] else { return }
        
        
        let ratingToComment = RatingToCommentController()
        ratingToComment.post = currentPost
        ratingToComment.cell = cell
        ratingToComment.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(ratingToComment, animated: true, completion: nil)
        
        
    }
    
    func didDoubleTap(for cell: FeedPostCell, vote: Double, post: Post) {
        
        let ratingModel = RatingModel()
        var observeId:UInt = 0
        var ref: DatabaseReference = Database.database().reference()
        
        if post.hasRated == 0.0 {
            guard let userId = post.user?.id else { return }
            
            (observeId, ref) = ratingModel.ratingUpdatePostObserve(postId: post.postId, completion: { (rating, votes, indexPath) in

                if let r = rating {
                    cell.setPostRating(rating: r)
                }
                if let v = votes {
                    cell.setRatingVote(v)
                }
//                cell.setPostRating(rating: rating)
//                cell.setRatingVote(votes)
                cell.setStateToStarBtn(true)
                
                ref.removeObserver(withHandle: observeId)
                
            })
            
            ratingModel.addPostRating(rating: vote, DestinationUser: userId, postId: post.postId)
        }
    }
    
}
