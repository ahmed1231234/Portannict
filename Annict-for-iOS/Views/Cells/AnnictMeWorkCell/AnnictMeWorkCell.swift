//
//  AnnictMeWorkCell.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2017/02/12.
//  Copyright © 2017年 Yuto Akiba. All rights reserved.
//

import UIKit
import Kingfisher


// MARK: - AnnictMeWorkCell

class AnnictMeWorkCell: UITableViewCell {
    
    @IBOutlet dynamic fileprivate weak var baseView: UIView!
    @IBOutlet dynamic fileprivate weak var titleLabel: UILabel!
    @IBOutlet dynamic fileprivate weak var iconImageView: UIImageView!
    
    @IBOutlet weak var tag1: UILabel!
    @IBOutlet weak var tag2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initBaseView()
        self.initTags()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.iconImageView.image = nil
    }
    
    func set(work: AnnictWorkResponse) {
        self.titleLabel.text = work.title
        self.setTwitterIcon(imageView: iconImageView, username: work.twitterUserName)
//        self.setAnimeIcon(imageView: iconImageView, title: work.title)
        self.tag1.text = "  \(work.mediaText)  "
        self.tag1.alpha = 1
        if let seasonNameText = work.seasonNameText {
            self.tag2.text = "  \(seasonNameText)  "
            self.tag2.alpha = 1
        }
    }
    
    fileprivate func setTwitterIcon(imageView: UIImageView!, username: String?) {
        if let username = username {
            if let url = URL(string: "http://furyu.nazo.cc/twicon/\(username)/original") {
                imageView.kf.setImage(with: url)
            }
        }
    }
    
//    fileprivate func setAnimeIcon(imageView: UIImageView!, title: String) {
//        let request = RakutenAPI.GetRakutenItems(keyword: title)
//        RakutenAPIClient.send(request) { response in
//            switch response {
//            case .success(let value):
//                guard let items = value.items else { return }
//                guard let imageURL = items.first?.mediumImageURLs?.first else { return }
//                let url = URL(string: imageURL)!
//                imageView.kf.setImage(with: url)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    fileprivate func initBaseView() {
        self.baseView.layer.masksToBounds = true
        self.baseView.layer.cornerRadius = 4
    }
    
    fileprivate func initTags() {
        let tagLabels = [tag1, tag2]
        
        for tagLabel in tagLabels {
            tagLabel?.alpha = 0
            tagLabel?.textColor = UIColor.white
            tagLabel?.backgroundColor = UIColor.annictPink
            tagLabel?.layer.masksToBounds = true
            tagLabel?.layer.cornerRadius = 2
        }
    }
}