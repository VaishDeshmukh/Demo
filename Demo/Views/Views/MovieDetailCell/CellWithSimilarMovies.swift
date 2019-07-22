//
//  CellWithSimilarMovies.swift
//  Demo
//
//  Created by Vaishu on 22/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

protocol CellWithSimilarMoviesDelegate {
    func didSelectSimilarItem(atCollectionIndexPath indexPath:IndexPath, withPreviewImage previewImage:UIImage?)
}

class CellWithSimilarMovies: UITableViewCell {

    //MARK:- Actions
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK:- Properties
    
    fileprivate enum collectionCell: String {
        case module = "CellWithImageLabel"
        case identifier = "cell-with-image-label"
    }
    fileprivate var items:[Movie] = []
    var delegate: CellWithSimilarMoviesDelegate? = nil

    //MARK:- Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.dataSource = self
        collectionView.delegate = self
        registerCollectionViewComponents()

    }
    
    func registerCollectionViewComponents() {
        
        let cell = UINib(nibName: collectionCell.module.rawValue, bundle: Bundle.main)
        collectionView.register(cell, forCellWithReuseIdentifier: collectionCell.identifier.rawValue)
    }
    
    func populateItems(items:[Movie]) {
        self.items = items
        collectionView.reloadData()
    }
}

extension CellWithSimilarMovies: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCell.identifier.rawValue, for: indexPath) as! CellWithImageLabel
        if let imagePath = items[indexPath.row].poster_path {
            cell.setImage(posterPath: imagePath)
        }
        if let title = items[indexPath.row].title {
            cell.title.text = title
        }
        return cell
    }
}
extension CellWithSimilarMovies: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellWithImageLabel
        
        guard let image = cell?.imageView.image else {
            return
        }
        
        delegate?.didSelectSimilarItem(atCollectionIndexPath: indexPath, withPreviewImage: image)
    }
}

extension CellWithSimilarMovies: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 222, height: 175)
    }
}
