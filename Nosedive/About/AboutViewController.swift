//
//  AboutViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import YouTubePlayer
import Kingfisher

class AboutViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var photoProfile: UIImageView!
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    @IBOutlet weak var aboutNosedive: UITextView!
    @IBOutlet weak var leaveFeedBackBtn: UIButton!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var netflixUrl: UIButton!
    @IBOutlet weak var ownerAbout: UITextView!
    @IBOutlet weak var ownerProfession: UILabel!
    
    let transition = CircularTransition()
    var linkedin: String?
    var mailTo: String?
    var twitter: String?
    var netUrl: String?
    var userData: UserModel.User?
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadVictorProfile(){
        
        AboutFRController().getAboutInfo { (about) in
            
            let photoUrl = URL(string: about.user.photoUrl)
            self.photoProfile.kf.setImage(with: photoUrl)
            
            self.ownerName.text = "\(about.user.firstName.firstUppercased) \(about.user.lastName.firstUppercased)"
            self.ownerProfession.text = about.user.profession
            self.ownerAbout.text = about.user.biography
            
            self.aboutNosedive.text = about.nosedive
            
            self.videoPlayer.loadVideoID(about.youtubeId)
            
            
            self.linkedin = about.linkedin
            self.mailTo = about.mailTo
            self.twitter = about.twitter
            self.netUrl = about.netfixUrl
            self.userData = about.user
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        self.view.backgroundColor = .clear
        transition.delegate = self
        setupStyling()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadVictorProfile()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupStyling(){
        
        photoProfile.layer.cornerRadius = photoProfile.frame.width/2
        photoProfile.layer.borderWidth = 1
        photoProfile.layer.borderColor = UIColor.white.cgColor
        photoProfile.contentMode = .scaleAspectFit
        photoProfile.layer.masksToBounds = true
        
        leaveFeedBackBtn.layer.borderColor = UIColor.white.cgColor
        leaveFeedBackBtn.layer.borderWidth = 0.7
        leaveFeedBackBtn.layer.cornerRadius = leaveFeedBackBtn.frame.height / 2
        leaveFeedBackBtn.layer.backgroundColor =  UIColor(red: 1, green:1, blue: 1, alpha: 0.15).cgColor
        
        netflixUrl.layer.cornerRadius = netflixUrl.frame.height / 2
        netflixUrl.layer.borderColor = UIColor.white.cgColor
        netflixUrl.layer.borderWidth = 0.7
        netflixUrl.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15).cgColor
        netflixUrl.setTitleColor(.white, for: .normal)
        
        view.addSubview(closeBtn)
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 35, height: 35, safeArea: true, view: self.view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 || scrollView.contentOffset.x<0 {
            scrollView.contentOffset.x = 0.0
        }
    }
    @IBAction func sendEmail(_ sender: Any) {
        guard let email = self.mailTo else {return}
        if let url = NSURL(string: "mailto:\(email)") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    @IBAction func linkedin(_ sender: Any) {
        guard let linkedin = self.linkedin else { return }
        if let url = NSURL(string: linkedin) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func twitter(_ sender: Any) {
       guard let twitter = self.twitter else { return }
        if let url = NSURL(string: twitter) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func gotoNetflix(_ sender: Any) {
        guard let netflix = self.netUrl else { return }
        if let url = NSURL(string: netflix) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func leaveFeedback(_ sender: Any) {
        let feedback = FeedbackController(collectionViewLayout: UICollectionViewFlowLayout())
        
        self.present(feedback, animated: true, completion: nil)
    }
    
    @IBAction func rateMeAction(_ sender: Any) {
        let leaveRating = RatingMainViewController()
        
        leaveRating.userData = userData
        
        leaveRating.transitioningDelegate = self
        leaveRating.modalPresentationStyle = .custom
        
        self.present(leaveRating, animated: true, completion: nil)
        
    }
    
}

extension AboutViewController: CircularTransitionDelegate, UIViewControllerTransitioningDelegate {
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

