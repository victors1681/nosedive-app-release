//
//  SearchTableViewCell.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var votes: UILabel!
    
    @IBInspectable var selectionColor: UIColor = .gray {
        didSet {
            configureSelectedBackgroundView()
        }
    }
    
    func configureSelectedBackgroundView() {
        let view = UIView()
        view.backgroundColor = selectionColor
        selectedBackgroundView = view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.layer.borderColor = UIColor.white.cgColor
        fullName.textColor = UIColor.white
        username.textColor = UIColor.white
        rating.textColor = UIColor.white
        votes.textColor = UIColor.white
        
        photo.layer.cornerRadius = photo.frame.height / 2
        photo.layer.borderColor = UIColor.white.cgColor
        photo.layer.borderWidth = 1
        photo.frame.size = CGSize(width: 45, height: 45)
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFill
        
    }
    
    func setCellFrame(tableview: UITableView){
        self.frame.size = CGSize(width: tableview.frame.width, height: 30)
    }
    
    func setPhotoProfile(path: String){
        let url = URL(string: path)
        photo.kf.setImage(with: url)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
