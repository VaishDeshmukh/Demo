//
//  MainTableViewController.swift
//  Demo
//
//  Created by Vaishu on 16/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import UIKit
import KeychainSwift

class MainTVC: UITableViewController {
    
    // MARK: Enumeration
    enum screen {
        enum movieCell: String {
            case identifier = "movie-cell"
            case module = "MovieTableViewCell"
        }
        enum controllers: String {
            case detail = "MovieDetailVC"
        }
    }
    
    //MARK:- Properties
    let detailView = MovieDetailVC()
    fileprivate var currentPage = 1
    fileprivate lazy var movies = {
        return [Movie]()
    }()
    internal var pager: Pager!
    internal var spinner: SpinnerView! = nil
    internal var isLoadingInProgress = false
    internal lazy var tableFooterSpinner = {
        return UIActivityIndicatorView(style: .gray)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = SpinnerView(frame: view.frame)
        view.addSubview(spinner)
        
        registerComponents()

        self.navigationItem.title = "HOOQ Demo"
        tableView.tableFooterView = UIView(frame: .zero)

        fetchMovie()
    }

    // MARK: - Private
    fileprivate func registerComponents() {
        let movieCell = UINib(nibName: screen.movieCell.module.rawValue, bundle: Bundle.main)
        tableView.register(movieCell, forCellReuseIdentifier: screen.movieCell.identifier.rawValue)
    }
    
    // MARK:- Actions
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        fetchMovie()
        refreshControl?.endRefreshing()
    }
}

// MARK: - Table view data source & delegates
extension MainTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: screen.movieCell.identifier.rawValue, for: indexPath) as! MovieTableViewCell
        if let title = movies[indexPath.row].title {
            cell.movieTitle.text = title
        }
        if let imagePath = movies[indexPath.row].poster_path {
            cell.setImage(posterPath: imagePath)
        } 
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: screen.controllers.detail.rawValue) as? MovieDetailVC {
            let cell = tableView.cellForRow(at: indexPath) as! MovieTableViewCell
            
            guard let image = cell.moviePoster.image else {
                return
            }
            vc.preview = image
            vc.movie = movies[indexPath.row]
            
             let nvc = TransparentNavigationController(rootViewController: vc)
            
            present(nvc, animated: true, completion: nil)
            
            
            /*
             let nvc = GradientNavigationController(rootViewController: vc)
             
             modalTransitioningDelegate = ModalTransitioningDelegate(
             viewController: self,
             presentingViewController: nvc
             )
             
             nvc.modalPresentationStyle = .custom
             nvc.transitioningDelegate = modalTransitioningDelegate
             
             vc.user = medium[at].user
             vc.delegate = self
             
             present(nvc, animated: true, completion: nil)
             */
        }
    }
}

// MARK:- TableView Footer
extension MainTVC {
    internal func setTableFooterView() {
        tableFooterSpinner.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        tableFooterSpinner.hidesWhenStopped = true
        tableFooterSpinner.color = .black
        tableFooterSpinner.startAnimating()
        tableView.tableFooterView = tableFooterSpinner
    }
    
    internal func removeTableFooterView() {
        tableView.tableFooterView = UIView()
    }
}

// MARK:- Network Calls
extension MainTVC {
    fileprivate func fetchMovie() {
        spinner.startAnimating()
        self.currentPage = 1
        let payload = [
            "language":"en-US",
            "page":currentPage] as [String : Any]
        
        Movie.fetch(data: payload) { movies, pager, error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            if error != nil {
                print(error as Any)
            } else {
                self.movies = movies!
                self.pager = pager!
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func loadMoreItems(page:Int) {
        isLoadingInProgress = true
        self.setTableFooterView()
        
        let payload = [
            "language":"en-US",
            "page":page] as [String : Any]
        
        Movie.fetch(data: payload) { movies, pager, error in
            DispatchQueue.main.async {
                self.isLoadingInProgress = false
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.removeTableFooterView()
                }
            } else {
                self.currentPage = page
                var preserved = self.movies.count
                self.movies.append(contentsOf: movies!)
                
                DispatchQueue.main.async {
                    var indexPathSet = [IndexPath]()
                    
                    while preserved < self.movies.count {
                        let path = IndexPath(row: preserved, section: 0)
                        indexPathSet.append(path)
                        preserved += 1
                    }
                    
                    self.tableView.insertRows(at: indexPathSet, with: .fade)
                    
                    if self.currentPage >= self.pager.total_pages {
                        self.removeTableFooterView()
                    }
                }
            }
        }
    }
}

// MARK:- ScrollView Delegates
extension MainTVC {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentSize = Int(scrollView.contentSize.height)
        let contentOffset = Int(scrollView.contentOffset.y)
        let frameHeight = Int(scrollView.frame.size.height)
        
        if contentOffset + frameHeight >= contentSize {
            if let pager = pager {
                if currentPage < pager.total_pages && !self.isLoadingInProgress {
                    tableFooterSpinner.startAnimating()
                    loadMoreItems(page: self.currentPage + 1)
                }
            }
        }
    }
}
