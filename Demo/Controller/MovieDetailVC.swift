//
//  MovieDetailVC.swift
//  Demo
//
//  Created by Vaishu on 21/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit

class MovieDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Enumerations
    @IBOutlet var tableView: UITableView!
    
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
            case detail = "MovieDetailVC"
        }
    }
    
    fileprivate enum SectionIndex: Int {
        case Title = 0
        case Description
        case SimilarMovies
    }
    
    fileprivate enum Threshold: CGFloat {
        case header = -64
        case top = 0
    }
    
    //MARK:- Properties
    var movie:Movie? = nil
    var movie_id = -1
    fileprivate var similarMovies:[Movie] = []
    fileprivate var headerTitle = "Similar Movies"
    fileprivate let bulletPointer =  " \u{2022} "
    var preview:UIImage? = nil
    fileprivate lazy var headerView:BaseHeaderView = {
        return BaseHeaderView()
    }()
   
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        registerComponents()
        prepareNavBarItems()
        
        //load data and image
        guard let movie = movie else {
            return
        }
        reloadData(withMovie: movie, withPreviewImage: self.preview)
       
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0.01
        tableView.estimatedSectionFooterHeight = 0.01
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //adjust header view based on aspect ratio
        var height = view.frame.height * 0.5
        if let previewImg = preview {
            let tmpHeight = (previewImg.size.height / previewImg.size.width) * view.frame.width
            if tmpHeight > height {
                height = tmpHeight * 0.7
            } else {
                height = tmpHeight
            }
        }
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        view.addSubview(headerView)
        
        let origin = CGPoint(x: 0, y: -height)
        tableView.contentOffset = origin
        tableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
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

    fileprivate func prepareNavBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "cross"),
            style: .plain, target: self,
            action: #selector(didPressCloseButton)
        )
    }

    // MARK:- Actions
    @IBAction func didPressCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated:true, completion:nil)
    }
    
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionIndex.Title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: screen.titleCell.identifier.rawValue, for: indexPath) as! CellWithLabels
            
            if let movie = movie, let release_date = movie.release_date {
                cell.movieTitle.text = movie.title
                
                let date = dateFromString(string: release_date)
                if let date = date, let language = movie.original_language {
                    let calendar = Calendar.current
                    let release_year = calendar.component(.year, from: date)
                    cell.releaseYearTitle.text = bulletPointer + language + bulletPointer + String(release_year)
                }
                
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
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionIndex.SimilarMovies.rawValue {
            return 200.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SectionIndex.SimilarMovies.rawValue {
            return headerTitle
        } else {
            return nil
        }
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionIndex.SimilarMovies.rawValue {
            return 40.0
        } else {
            return 0.01
        }
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

//MARK:- Network calls
extension MovieDetailVC {
    fileprivate func reloadData(withMovie similarMovie: Movie?, withPreviewImage previewImage:UIImage?) {

        //set default image & details
        preview = previewImage
        headerView.imageView.image = previewImage

        self.movie = similarMovie

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
                        let indexPath = IndexPath(row: 0, section: SectionIndex.SimilarMovies.rawValue)
                        if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                            self.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                        }
                    }
                }
            })
        }
    }
}

//MARK: - CellWithSimilarMoviesDelegate
extension MovieDetailVC: CellWithSimilarMoviesDelegate {
    internal func didSelectSimilarItem(atCollectionIndexPath indexPath: IndexPath, withPreviewImage previewImage: UIImage?) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: screen.controllers.detail.rawValue) as? MovieDetailVC {
            vc.preview = previewImage
            vc.movie = similarMovies[indexPath.row]
            let nvc = TransparentNavigationController(rootViewController: vc)
            present(nvc, animated: true, completion: nil)
        }
    }
}


// MARK: - UIScrollViewDelegate
extension MovieDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
            if scrollView.contentOffset.y >= Threshold.header.rawValue {
                navigationController?.navigationBar.topItem?.title = movie?.title
            } else {
                navigationController?.navigationBar.topItem?.title = nil
            }
        }
        
        if scrollView.contentOffset.y < Threshold.top.rawValue {
            headerView.frame.size.height = -scrollView.contentOffset.y
        } else {
            headerView.frame.size.height = 0
        }
    }
}
