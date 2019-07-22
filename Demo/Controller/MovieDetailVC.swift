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
    var preview:UIImage? = nil
    fileprivate lazy var headerView:BaseHeaderView = {
        return BaseHeaderView()
    }()
    
    //MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavBar()
        registerComponents()
        
        //load data and image
        guard let movie = movie else {
            return
        }
        reloadData(withMovie: movie, withPreviewImage: self.preview)
       
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.hideBottomHairline()
        navigationController?.navigationBar.setGradientBackground(colors: [
            UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
            UIColor.clear
            ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        headerView.removeFromSuperview()
        
        // reset navbar if controller is pushed via storyboard
        navigationController?.navigationBar.barTintColor = .magenta
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private
    
    fileprivate func prepareNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    fileprivate func registerComponents() {
        let titleCell = UINib(nibName: screen.titleCell.module.rawValue, bundle: Bundle.main)
        tableView.register(titleCell, forCellReuseIdentifier: screen.titleCell.identifier.rawValue)
        
        let descriptionCell = UINib(nibName: screen.descriptionCell.module.rawValue, bundle: Bundle.main)
        tableView.register(descriptionCell, forCellReuseIdentifier: screen.descriptionCell.identifier.rawValue)
        
        
        let similarMoviesCell = UINib(nibName: screen.similarMoviesCell.module.rawValue, bundle: Bundle.main)
        tableView.register(similarMoviesCell, forCellReuseIdentifier: screen.similarMoviesCell.identifier.rawValue)
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
        }
        return CGFloat.leastNormalMagnitude
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
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
            navigationController?.pushViewController(vc, animated: true)
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
