//
//  FeedbackHeaderCell.swift
//  Nosedive
//
//  Created by Victor Santos on 2/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

protocol FeedbackHeaderDelegate {
    func didSendFeedback(text: String, privateFeedback: Bool, header: FeedbackHeaderCell)
}
class FeedbackHeaderCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        
        let attributedText = NSMutableAttributedString(string: "App Feedback\n", attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 21) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        let text =  "Use the form below to send me your comments or report any problems you experienced on the app. I read all feedback carefully. Thanks!\n Victor Santos"
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.backgroundColor = UIColor.clear
        tv.attributedText = attributedText
        return tv
    }()
    
    let feedbackText: UITextView = {
        let f = UITextView()
        f.textColor = UIColor.white
        f.backgroundColor = UIColor.clear
        f.layer.borderColor = UIColor.white.cgColor
        f.font = UIFont(name: "AvenirNext-Regular", size: 15)
        f.layer.borderWidth = 0.8
        f.layer.cornerRadius = 4
        
        return f
    }()
    
    lazy var sendFeedbackBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("send feedback", for: .normal)
        btn.layer.borderWidth = 0.8
        btn.layer.cornerRadius = 4
        btn.layer.borderColor = UIColor.white.cgColor
        btn.addTarget(self, action: #selector(handleFeedback), for: .touchUpInside)
        return btn
    }()
    
    lazy var switchPrivate: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .white
        s.setOn(false, animated: true)
        return s
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Send in private"
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        label.centerVertically()
        return label
    }()
    
    
    
    var delegate: FeedbackHeaderDelegate?
    
    @objc func handleSwitch(s: UISwitch){
        
        print(s.isOn)
    }
    
    @objc func handleFeedback(){
        
        if feedbackText.text.count > 0 {
            sendFeedbackBtn.isEnabled = false
            
            let privateFeedback = switchPrivate.isOn
            
            delegate?.didSendFeedback(text: feedbackText.text, privateFeedback: privateFeedback, header: self)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        addSubview(textView)
        addSubview(feedbackText)
        addSubview(sendFeedbackBtn)
        
        textView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 120)
        
        feedbackText.anchor(top: textView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 60)
        
        sendFeedbackBtn.anchor(top: feedbackText.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 35)
        
        
        
        let container = UIView()
        addSubview(container)
        container.addSubview(switchPrivate)
        container.addSubview(label)
        switchPrivate.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 30)
        
        label.anchor(top: container.topAnchor, left: switchPrivate.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 10, paddingBottom: 4, paddingRight: 0, width: 160, height: 25)
        
        
        container.anchor(top: sendFeedbackBtn.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        let division = UIView()
        addSubview(division)
        division.backgroundColor = .white
        division.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.8)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
