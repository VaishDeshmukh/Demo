//
//  CellWithTextView.swift
//  Demo
//
//  Created by Vaishu on 22/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class CellWithTextView: UITableViewCell {

    @IBOutlet var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionTextView.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
