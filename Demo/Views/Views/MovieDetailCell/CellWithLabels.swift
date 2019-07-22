//
//  MovieDetailTableViewCell.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class CellWithLabels: UITableViewCell {

    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var releaseYearTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
