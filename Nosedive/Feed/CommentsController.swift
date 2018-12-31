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

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate {

    var post: Post?
    var cell: FeedPostCell?
    var comments = [Comment]()
    var commentsFRController = CommentFRController()
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    var observeId: UInt = 0
    var currentRef: DatabaseReference!
 
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return btn
    }()
    
    var viewTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textAlignment = NSTextAlignment.center
        label.text = "Comments"
        label.textColor = UIColor.white
        return label
    }()
    
    var customNav: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let n = UIVisualEffectView(effect: effect)
        n.frame = CGRect(x: 0, y: 0, width: 320, height: 64)
        return n
    }()
    
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
         self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
      
        guard let post = self.post else { return }
        
        let observeInfo = commentsFRController.fetchComments(post: post) { (comment) in
           
            self.comments.append(comment)
            self.comments.sort(by: { (p1, p2) -> Bool in
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
        
        setupView()
        
        let dismissControl = UIRefreshControl()
        dismissControl.tintColor = UIColor.clear
        dismissControl.addTarget(self, action: #selector(handleDismissView), for: .valueChanged)
        collectionView?.refreshControl = dismissControl

    }
    
    @objc func handleDismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupView(){
        
        self.view.addSubview(customNav)
        
        customNav.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60 + Helpers().getSafeAreaSize().top)
        
        self.view.addSubview(closeBtn)
        closeBtn.anchor(top: nil, left: nil, bottom: customNav.bottomAnchor, right: customNav.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 10, width: 50, height: 30)
        
        
        self.view.addSubview(viewTitle)
        viewTitle.anchor(top: nil, left: nil, bottom: customNav.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 180, height: 25)
        
        viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.currentRef.removeObserver(withHandle: self.observeId)
        
        //update comment counter on cell
        guard let currentCell = cell  else { return }
         currentCell.setCommentCount(self.comments.count)
    }
    
    
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .white
        
        guard let font = UIFont(name: "AvenirNext-Italic", size: 13) else { return textField }
        textField.attributedPlaceholder = NSAttributedString(string:"Enter your comment", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: font ])

        return textField
    }()
    
    lazy var submitButton: UIButton = {
       let btn = UIButton()
        
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return btn
    }()
    
   
    
    lazy var containerView: UIVisualEffectView = {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let containerView = UIVisualEffectView(effect: blurEffect)
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        containerView.contentView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        containerView.contentView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor(red: 230, green: 230, blue: 230, alpha: 1.00)
        
        containerView.contentView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        
        return containerView
    }()
    
 
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func handleBack(){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSubmit(){
        if let comment = commentTextField.text,
            let post = self.post,
            comment.count > 0  {
            submitButton.isEnabled = false
            
            commentsFRController.addComment(text: comment, post: post, completion: { (success, err) in
                if success {
                    self.commentTextField.text = ""
                    self.submitButton.isEnabled = true
                }else{
                    //TODO: SHOW ERROR TO THE USER
                    
                    let alert = UIAlertController(title: "🙃", message: "Something wrong trying to post comment, please check your connection. \(err)", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.commentTextField.text = ""
                        self.submitButton.isEnabled = true
                    })
                    alert.addAction(action)
                    
                }
            })
            print("Handling submit", commentTextField.text ?? "")
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }
   
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
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


