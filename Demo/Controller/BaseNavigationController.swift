//
//  BaseNavigationController.swift
//  Demo
//
//  Created by Vaishu on 23/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Private
    
    private func setDefaults() -> Void {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationBar.tintColor = .black
        navigationBar.barTintColor = UIColor(red:0.89, green:0.82, blue:0.00, alpha:0.85)
        navigationBar.isTranslucent = true
        navigationBar.backItem?.backBarButtonItem?.title = ""
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }
}
