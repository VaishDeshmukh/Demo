//
//  BaseHeaderVIew.swift
//  Demo
//
//  Created by Vaishu on 23/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class BaseHeaderView: UIView {

    
    var heightLayoutConstraint = NSLayoutConstraint()
    var bottomLayoutConstraint = NSLayoutConstraint()
    
    var containerView = UIView()
    var containerLayoutConstraint = NSLayoutConstraint()
    
    var imageView: UIImageView = UIImageView()
    var spinner: SpinnerView! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.red
        
        addSubview(containerView)
        
        spinner = SpinnerView(frame: self.frame)
        addSubview(spinner)
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[containerView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["containerView" : containerView])
        )
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[containerView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["containerView" : containerView])
        )
        
        containerLayoutConstraint = NSLayoutConstraint(
            item: containerView,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 1.0,
            constant: 0.0
        )
        
        addConstraint(containerLayoutConstraint)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        containerView.addSubview(imageView)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[imageView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["imageView" : imageView])
        )
        
        bottomLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0
        )
        
        containerView.addConstraint(bottomLayoutConstraint)
        
        heightLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .height,
            multiplier: 1.0,
            constant: 0.0
        )
        
        containerView.addConstraint(heightLayoutConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerLayoutConstraint.constant = scrollView.contentInset.top
        
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        containerView.clipsToBounds = offsetY <= 0
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        
        heightLayoutConstraint.constant = max(
            offsetY + scrollView.contentInset.top,
            scrollView.contentInset.top
        )
    }

}
