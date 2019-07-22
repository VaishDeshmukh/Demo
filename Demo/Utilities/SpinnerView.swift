//
//  SpinnerView.swift
//  Demo
//
//  Created by Vaishu on 21/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import UIKit

class SpinnerView: UIActivityIndicatorView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hidesWhenStopped = true
        self.adjust()
    }
    
    func adjust() {
        guard let superView = superview else {
            return
        }
        
        center = CGPoint(
            x: superView.frame.width / 2,
            y: superView.frame.height / 2
        )
        self.color = .black
    }
    
    func setColor(color: UIColor) {
        self.color = color
    }
}
