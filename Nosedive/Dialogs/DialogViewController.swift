//
//  TipsViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 4/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController {
    
    let container: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let container = UIVisualEffectView(effect: effect)
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        return container
    }()
    
    var image: UIImage? {
        didSet {
            self.icon.image = image
        }
    }
    var background: Bool = false
    
    var textView: UITextView = {
        let t = UITextView()
        t.text = "No descriptions added"
        t.font = DefaultFont.regular.size(13)
        t.textColor = UIColor.white
        t.isScrollEnabled = false
        t.isEditable = false
        t.isSelectable = false
        t.backgroundColor = UIColor.clear
        return t
    }()
    
     private var icon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "idea"))
        iv.contentMode = .center
        return iv
    }()
    
    private var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return view
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout(){
        
        if background {
        
            view.addSubview(backgroundView)
            backgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        
        view.backgroundColor = UIColor.clear
        view.addSubview(container)
        container.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 180)
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive  = true
        
        container.contentView.addSubview(textView)
        
        view.addSubview(icon)
        icon.anchor(top: nil, left: nil, bottom: textView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 69, height: 69)
        icon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        container.contentView.addSubview(doneBtn)
        doneBtn.anchor(top: nil, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 0, height: 20)
        
        textView.anchor(top: nil, left: container.leftAnchor, bottom: doneBtn.topAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 15, paddingRight: 20, width: 0, height: 90)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
