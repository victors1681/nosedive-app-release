//
//  TipsViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 4/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController {
    
    let container: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let container = UIVisualEffectView(effect: effect)
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        return container
    }()
    
    let textView: UITextView = {
       let t = UITextView()
        t.text = "In order to start to increase your score, you must have to post at least once. Scores are based on users posts."
        t.font = DefaultFont.regular.size(13)
        t.textColor = UIColor.white
        t.isScrollEnabled = false
        t.isEditable = false
        t.isSelectable = false
        t.backgroundColor = UIColor.clear
        return t
    }()
    
    let icon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "idea"))
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    let doneBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Got it :)", for: .normal)
        let color = UIColor(red:0.98, green:0.25, blue:0.55, alpha:1.00)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = DefaultFont.demiBold.size(13)
        btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return btn
    }()
    
    @objc func doneAction(){
        self.dismiss(animated: true, completion: nil)
        Helpers().setInitialNotification(state: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout(){
        
        view.backgroundColor = UIColor.clear
        view.addSubview(container)
        container.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 150)
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive  = true

        container.contentView.addSubview(textView)
        
        view.addSubview(icon)
        icon.anchor(top: nil, left: nil, bottom: textView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 59, height: 69)
        icon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        container.contentView.addSubview(doneBtn)
        doneBtn.anchor(top: nil, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 0, height: 20)
        
        textView.anchor(top: nil, left: container.leftAnchor, bottom: doneBtn.topAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 15, paddingRight: 20, width: 0, height: 70)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
