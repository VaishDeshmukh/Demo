//
//  MovieDetailTVC.swift
//  Demo
//
//  Created by Vaishu on 21/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class MovieDetailTVC: UITableViewController {

    @IBOutlet var headerView: UIView!
    //MARK:- Enumerations
    
    fileprivate enum screen {
        enum titleCell: String {
            case module = "CellWithLabels"
            case identifier = "cell-with-labels"
        }
        enum descriptionCell: String {
            case module = "CellWithTextView"
            case identifier = "cell-with-textView"
        }
        enum similarMoviesCell: String {
            case module = "CellWithSimilarMovies"
            case identifier = "cell-with-similarMovies"
        }
        enum controllers: String {
            case detail = "MovieDetailTVC"
        }
    }
    
    fileprivate enum SectionIndex: Int {
        case Title = 0
        case Description
        case SimilarMovies
    }
    
    //MARK:- Properties
    
    var movie:Movie? = nil
    var movie_id = -1
    fileprivate var similarMovies:[Movie] = []
    fileprivate var headerTitle = "SimilarMovies"
    
    //MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerComponents()
        
        guard let movie = movie else {
            return
        }
        if let id = movie.id {
            getSimilarMovies(movie: movie, movieId: id)
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        self.navigationController?.navigationBar.prefersLargeTitles = trueA
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    // MARK: - Private
    
    fileprivate func registerComponents() {
        let titleCell = UINib(nibName: screen.titleCell.module.rawValue, bundle: Bundle.main)
        tableView.register(titleCell, forCellReuseIdentifier: screen.titleCell.identifier.rawValue)
        
        let descriptionCell = UINib(nibName: screen.descriptionCell.module.rawValue, bundle: Bundle.main)
        tableView.register(descriptionCell, forCellReuseIdentifier: screen.descriptionCell.identifier.rawValue)
        
        
        let similarMoviesCell = UINib(nibName: screen.similarMoviesCell.module.rawValue, bundle: Bundle.main)
        tableView.register(similarMoviesCell, forCellReuseIdentifier: screen.similarMoviesCell.identifier.rawValue)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SectionIndex.Title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: screen.titleCell.identifier.rawValue, for: indexPath) as! CellWithLabels
            if let movie = movie {
                cell.movieTitle.text = movie.title
                cell.releaseYearTitle.text = movie.release_date
            }
            return cell
        case SectionIndex.Description.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: screen.descriptionCell.identifier.rawValue, for: indexPath) as! CellWithTextView
            if let movie = movie {
                cell.descriptionTextView.text = movie.overview
            }
            return cell
        case SectionIndex.SimilarMovies.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: screen.similarMoviesCell.identifier.rawValue, for: indexPath)
                as! CellWithSimilarMovies
            cell.delegate = self
            cell.populateItems(items: similarMovies)
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionIndex.SimilarMovies.rawValue {
            return 200.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SectionIndex.SimilarMovies.rawValue {
            return headerTitle
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionIndex.SimilarMovies.rawValue {
            return 40.0
        }
        return CGFloat.leastNormalMagnitude
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

//MARK:- Network calls

extension MovieDetailTVC {
    fileprivate func getSimilarMovies(movie: Movie?, movieId: Int) {
        
        self.movie = movie

        if let movie = self.movie {
            guard let id = movie.id else { return }
            let payload = ["id": id] as [String: Any]

            // Get similar movies
            Movie.getSimilarMovies(data: payload, completion: {(similarMovies, pager, error) in
                
                if error != nil {
                    
                } else {
                    DispatchQueue.main.async {

                    if let similarMoviesArray = similarMovies {
                        self.similarMovies = Array(similarMoviesArray.prefix(10))//limit to 10 similar Medias
                        self.tableView.reloadSections(NSIndexSet(index: SectionIndex.SimilarMovies.rawValue) as IndexSet, with: .none)
                        }
                    }
                }
            })
        }
    }
}

//MARK: - CellWithSimilarMoviesDelegate

extension MovieDetailTVC: CellWithSimilarMoviesDelegate {
    internal func didSelectSimilarItem(atCollectionIndexPath indexPath: IndexPath, withPreviewImage previewImage: UIImage?) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: screen.controllers.detail.rawValue) as? MovieDetailTVC {
//            vc.preview = previewImage
            vc.movie = similarMovies[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

