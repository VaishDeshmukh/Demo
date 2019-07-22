//
//  CellWithImageLabel.swift
//  Demo
//
//  Created by Vaishu on 22/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class CellWithImageLabel: UICollectionViewCell {

    //MARK:- Actions
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    //MARK:- Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.af_cancelImageRequest()
        imageView.layer.removeAllAnimations()
        imageView.image = UIImage(imageLiteralResourceName: "placeholderImage")
    }
}

//MARK:- Private

extension CellWithImageLabel {
    internal func setImage(posterPath: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let path = Constants.imageBaseUrl + posterPath
        
        if let url = URL(string: path) {
            imageView.af_setImage(
                withURL: url,
                imageTransition: .crossDissolve(0.2),
                runImageTransitionIfCached: false) { response in
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    switch response.result {
                    case .success: break
                    case .failure: break
                    }
            }
        }
    }
}
