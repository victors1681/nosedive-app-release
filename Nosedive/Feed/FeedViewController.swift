//
//  FeedViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/19/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedPostDelegate {

    
    // MARK: - Properties
    var lastPost: Post?
    let transition = CircularTransition()
    var adsToLoad = [GADBannerView]()
    var loadStateForAds = [GADBannerView: Bool]()
    let adUnitID = "ca-app-pub-9751546392416390/5048868041"
    
    // larger ad interval to avoid mutliple ads being on screen at the same time.
    let adInterval = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
    // The banner ad height.
    let adViewHeight =  CGFloat(250)
    
    
    let cellId = "cellId"
    var posts = [Any]()
    let feedFR = FeedFRController()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    lazy var cameraBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "camera-left"), for: .normal)
        btn.tintColor = UIColor.white
        btn.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        return btn
    }()
    
    lazy var homeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "home-right"), for: .normal)
        btn.tintColor = UIColor.white
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    //iOS9
    //let refreshControl = UIRefreshControl()
    
    lazy var topLogo: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "nosedive_logo_text"), for: .normal)
        btn.addTarget(self, action: #selector(gotoTop), for: .touchUpInside)
        return btn
    }()
    
    @objc func gotoTop(){
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transition.delegate = self
        setupNavigationItems()
        self.navigationItem.titleView = topLogo
        
        collectionView?.register(FeedPostCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(UINib(nibName: "BannerAd", bundle: nil), forCellWithReuseIdentifier: "BannerViewCell")
        
        
        self.setClearBackground(view: self.view)
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleCameraGesture))
        screenEdgeRecognizer.edges = .left
        view.addGestureRecognizer(screenEdgeRecognizer)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handelUpdateFeed), name: SharePhotoViewController.updateFeedNotificationName, object: nil)
        
        fetchAllPosts()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        collectionView?.showsVerticalScrollIndicator = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    func fetchAllPosts(){
        posts.removeAll()
        
        feedFR.fetchPostsPaginate { (posts, lastPost) in
            
            guard let lastPost = lastPost else {return}
            self.lastPost = lastPost
            for p in posts {
                self.posts.append(p)
            }
            
            self.addBannerAds()
            self.preloadNextAd()
            //self.posts.append(posts)
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    @objc func handelUpdateFeed(){
        
        fetchAllPosts()
    }
    
    @objc func handleRefresh(){
        fetchAllPosts()
    }
    
    @objc func handleClose(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCamera(){
       self.goToCamera()
    }
    @objc func handleCameraGesture(sender: UIGestureRecognizer){
        
        if(sender.state == .ended){
            self.goToCamera()
        }
    }
    
    func goToCamera(){
        self.performSegue(withIdentifier: "cameraView", sender: self)
    }
    
    
    func setupNavigationItems(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cameraBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: homeBtn)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let BannerView = posts[safe: UInt(indexPath.item)] as? GADBannerView {
            let reusableAdCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerViewCell",
                                                                    for: indexPath)
            
            // Remove previous GADBannerView from the content view before adding a new one.
            for subview in reusableAdCell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            reusableAdCell.contentView.addSubview(BannerView)
            // Center GADBannerView in the table cell's content view.
            BannerView.center = reusableAdCell.contentView.center
            
            return reusableAdCell
            
        } else {
            
            let currentPost = posts[safe: UInt(indexPath.item)] as? Post
            
            if indexPath.item == self.posts.count - 1 {
                loadMorePosts()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedPostCell
            
            //cell.post = posts[safe: UInt(indexPath.item)]
            cell.post = currentPost
            cell.indexPath = indexPath.item
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func loadMorePosts(){
        feedFR.fetchPostsPaginate(lastPost: self.lastPost) { (posts, lastPost) in
            
            guard let lastPost = lastPost else {return}
            self.lastPost = lastPost
            
            for p in posts {
                self.posts.append(p)
            }
            
            self.addBannerAds()
            self.preloadNextAd()
            self.collectionView?.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let currentPost = posts[indexPath.item] as? Post {
            
            if currentPost.imageWidth >= currentPost.imageHeight {
                //landscape mode
                return CGSize(width: view.frame.width, height: (view.frame.height / 2) + 20)
            }
            
        }
        else if let _  = posts[indexPath.item] as? GADBannerView {
            return CGSize(width: view.frame.width, height: adViewHeight)
        }
        return CGSize(width: view.frame.width, height: view.frame.height - 80)
    }
    
    
    func didTapComment(post: Post, for cell: FeedPostCell) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        commentsController.cell = cell
        commentsController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(commentsController, animated: true, completion: nil)
        
        
    }
    
    func didTapUsername(user: UserModel.User?) {
        let leaveRating = RatingMainViewController()
        leaveRating.userData = user
        
        leaveRating.transitioningDelegate = self
        leaveRating.modalPresentationStyle = .custom
        
        self.present(leaveRating, animated: true, completion: nil)
    }

    
    func didTapRating(post: Post) {
        
        let ratingList = RatingListController(collectionViewLayout: UICollectionViewFlowLayout())
        ratingList.modalPresentationStyle = .overCurrentContext
        ratingList.post = post
        self.present(ratingList, animated: true, completion: nil)
    }
    
    
    
    func didTapOpenRatingView(for cell: FeedPostCell){
        
        guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
        guard let currentPost = self.posts[safe: UInt(indexPath.item)] as? Post else { return }
        
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
                
                cell.setStateToStarBtn(true)
                
                ref.removeObserver(withHandle: observeId)
                
            })
            
            ratingModel.addPostRating(rating: vote, DestinationUser: userId, postId: post.postId)
        }
    }
    
    
    
    //MARK: Delete Post
    
    func didTapMoreOption(post: Post, index: Int) {
        self.confirmDelete(post: post, index: index)
    }
    
    func confirmDelete(post: Post, index: Int) {
        let alertController = UIAlertController(title: nil, message: "Report inappropriate photo or delete yours", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Report", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            PostFRController().reportPost(post: post, userReported: currentUser, completion: { (sucess) in
                
                if sucess {
                    let alert = UIAlertController(title: "Reported", message: "Post Reported to the administrator", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Reported", message: "Error trying to report this post please check your internet connection", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
            })
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            // Do some destructive action here.
            guard let userId = post.user?.id else { return }
            PostFRController().removePost(postId: post.postId, userId: userId, completion: { (success) in
                if success {
                    self.removeFromCollection(index)
                }else{
                    print("Post not removed")
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
            
            if post.user?.id == currentUserId || isAdmin {
                alertController.addAction(deleteAction)
            }
            
        })
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeFromCollection(_ i: Int) {
        
        if posts.indices.contains(i) {
            posts.remove(at: i)
            
            let indexPath = IndexPath(row: i, section: 0)
            
            self.collectionView?.performBatchUpdates({
                self.collectionView?.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView?.reloadItems(at: (self.collectionView?.indexPathsForVisibleItems)!)
            }
        }
    }
    
}



