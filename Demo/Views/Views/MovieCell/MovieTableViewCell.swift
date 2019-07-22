//
//  MovieCell.swift
//  Demo
//
//  Created by Vaishu on 16/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet weak var spinner: SpinnerView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        moviePoster.image = nil
    }
}

// MARK:- Exposed Methods - AlamofireImage

extension MovieTableViewCell {
    func setImage(posterPath: String) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        
        let path = Constants.imageBaseUrl + posterPath
        let imageURL = try! URLRequest(url: path, method: .get, headers: nil)
        
        moviePoster.af_setImage(
            withURLRequest: imageURL,
            imageTransition: .crossDissolve(0.4),
            runImageTransitionIfCached: false){ response in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                switch response.result {
                case .success:
                    break
                case .failure:
                    break
                }
        }
    }
}
