//
//  HomeTitleTableViewCell.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2019/03/13.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

final class HomeTitleTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
