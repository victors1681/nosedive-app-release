//
//  SearchViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Spring
import Lottie

class SearchViewController: UIViewController, CircularTransitionDelegate, UIViewControllerTransitioningDelegate {
    func transitionDismissCallBack(controller: CircularTransition) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var tableview: UITableView!
    
    let transition = CircularTransition()
    var searchModel = SearchModel()
    var users: [UserModel.User]?
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchContainer: DesignableView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    var searchAnimation:LOTAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.separatorColor = UIColor.white
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        searchBar.delegate = self
        transition.delegate = self
        showSearchAnimation()
        searchBar.becomeFirstResponder()
    }
    
    func showSearchAnimation(){
        
        searchAnimation = LOTAnimationView(name: "happy-face")
        searchAnimation?.frame = CGRect(x: 10, y: 20, width: 200, height: 200)
        
        
        searchAnimation?.center = self.view.center
        searchAnimation?.contentMode = .scaleToFill
        self.view.addSubview(searchAnimation!)
        
        //self.view.bringSubview(toFront: searchAnimation!)
       // searchAnimation?.play()
        searchAnimation?.play { (sucess: Bool) in
          
            UIView.animate(withDuration: 1, animations: {
                self.searchAnimation?.alpha = 0
            }, completion: { (sucess: Bool) in
                self.searchAnimation?.removeFromSuperview()
            })
        }
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchBar(_ sender: Any) {
        
        
        let searchText = searchBar.text!
        
        searchModel.findUser(text: searchText, type: SearchModel.SearchType.username) { (userResponse) in
            
            guard let users = userResponse else { return }
            
            self.users = users
            self.tableview.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ratingView", let destination = segue.destination as? RatingMainViewController {
            
            var indexPath : NSIndexPath
            
            if sender is UITableViewCell {
                indexPath = tableview.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            } else {
                indexPath = sender as! NSIndexPath
            }
            
            let user = users![indexPath.row]
            
            destination.transitioningDelegate = self
            destination.modalPresentationStyle = .custom
            destination.userData = user

            
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
    
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.borderColor = UIColor.white.cgColor
        cell.separatorInset = .init(top: 0, left: 70, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let users = self.users else{
            return 0
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SearchTableViewCell
        
        guard let users = self.users else{
            return cell
        }
        let user = users[indexPath.row]
        cell.setCellFrame(tableview: tableview)
        cell.fullName.text = "\(user.firstName.capitalized) \(user.lastName.capitalized)"
        cell.username.text = user.username
        cell.rating.text = String(format: "%.2f", user.rating)
        cell.votes.text = user.votes.withCommas()
        
        cell.setPhotoProfile(path: user.photoUrl)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        self.performSegue(withIdentifier: "ratingView", sender: indexPath)
        
    }
    
    
 
}

extension SearchViewController: UITextFieldDelegate {
   
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchBar.resignFirstResponder()
        return true
    }
  
}


