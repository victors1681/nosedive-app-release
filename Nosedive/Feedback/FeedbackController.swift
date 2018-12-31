//
//  FeedbackController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedbackController: UICollectionViewController, FeedbackHeaderDelegate, UICollectionViewDelegateFlowLayout {

    var observeId: UInt = 0
    var currentRef: DatabaseReference!
    var feedbacks: [Feedback] = [Feedback]()
    
    
    func fetchAllFeedback(){
     let observeInfo =  FeedbackFRController().fetchFeedbacks { (feedback) in
        
        if !feedback.isPrivate {
            self.feedbacks.append(feedback)
            self.feedbacks.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
           }
        }
        self.observeId = observeInfo.observeId
        self.currentRef = observeInfo.ref
    }
    
    
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
        self.collectionView!.register(FeedbackCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.register(FeedbackHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")

        view.addSubview(closeBtn)
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 35, height: 35, safeArea: true, view: self.view)
        
        fetchAllFeedback()
        collectionView?.keyboardDismissMode = .interactive
       
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
      
         let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! FeedbackHeaderCell
        
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 320)
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedbacks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedbackCell
        
        cell.feedback = self.feedbacks[indexPath.item]
       
        return cell
    }
    
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = FeedbackCell(frame: frame)
        dummyCell.feedback = feedbacks[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func didSendFeedback(text: String, privateFeedback: Bool, header: FeedbackHeaderCell) {
        
        FeedbackFRController().addRating(text: text, private: privateFeedback, completion: { (success, error) in
            
            //perform
            if success {
                header.feedbackText.text = ""
                header.sendFeedbackBtn.isEnabled = true
                header.switchPrivate.setOn(false, animated: true)
                 self.view.showDoneAnimation()
            }
        })
    }
    
    

}
