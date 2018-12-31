//
//  CommentsController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/23/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class RatingListController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    var ratings = [RatingList]()
    var ratingModel = RatingModel()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    var observeId: UInt = 0
    var currentRef: DatabaseReference!
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "left-arrow"), for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return btn
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    var viewTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textAlignment = NSTextAlignment.center
        label.text = "Ratings"
        label.textColor = UIColor.white
        return label
    }()
    
    var customNav: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let n = UIVisualEffectView(effect: effect)
        n.frame = CGRect(x: 0, y: 0, width: 320, height: 64)
        return n
    }()
    
    
    
    @objc func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        self.collectionView!.register(RatingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: backBtn)
        
        guard let post = self.post else { return }

        
        let observeInfo = ratingModel.fetchRatings(post: post) { (rating) in
            
                        self.ratings.append(rating)
                        self.ratings.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
            
                        self.collectionView?.reloadData()
        }
        
        self.observeId = observeInfo.observeId
        self.currentRef = observeInfo.ref
        
        self.setClearBackground(view: self.view, style: .light)
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBack))
        screenEdgeRecognizer.edges = .left
        view.addGestureRecognizer(screenEdgeRecognizer)
        
        let dismissControl = UIRefreshControl()
        dismissControl.tintColor = UIColor.clear
        dismissControl.addTarget(self, action: #selector(handleDismissView), for: .valueChanged)
        collectionView?.refreshControl = dismissControl
        
        setupView()
    }
    
    @objc func handleDismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupView(){
        
        self.view.addSubview(customNav)
       
        customNav.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 64)
        
        self.view.addSubview(closeBtn)
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 50, height: 50)
        
        
        self.view.addSubview(viewTitle)
        viewTitle.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 25)
        
        viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.currentRef.removeObserver(withHandle: self.observeId)
   
    }
    
    @objc func handleBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
 
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RatingCell
        cell.rating = self.ratings[indexPath.item]
        return cell
    }
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = RatingCell(frame: frame)
        dummyCell.rating = ratings[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

