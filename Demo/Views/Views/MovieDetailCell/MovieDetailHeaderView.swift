//
//  MovieDetailHeaderView.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class MovieDetailHeaderView: UITableViewHeaderFooterView {
  
    var heightLayoutConstraint = NSLayoutConstraint()
    var bottomLayoutConstraint = NSLayoutConstraint()

    var containerView = UIView()
    var containerLayoutConstraint = NSLayoutConstraint()

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
