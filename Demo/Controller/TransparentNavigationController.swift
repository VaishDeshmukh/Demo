//
//  TransparentNavigationController.swift
//  Demo
//
//  Created by Vaishu on 23/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class TransparentNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideDefaults()
    }
    
    private func overrideDefaults() -> Void {
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

}
