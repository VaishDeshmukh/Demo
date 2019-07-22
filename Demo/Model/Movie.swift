//
//  Media.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import Gloss

struct Pager {
    let total_results: Int!
    let page: Int!
    let total_pages: Int!
}

struct Movie: Glossy {
    
    var vote_count: Int!
    var id: Int!
    var video: Bool!
    var vote_average: Double!
    var title: String!
    var popularity: Double!
    var poster_path: String!
    var original_language: String!
    var original_title: String!
    var genre_ids: [Int]!
    var backdrop_path: String!
    var adult: Bool!
    var overview: String!
    var release_date: String!
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "vote_count" ~~> self.vote_count,
            "id" ~~> self.id,
            "video" ~~> self.video,
            "vote_average" ~~> self.vote_average,
            "title" ~~> self.title,
            "popularity" ~~> self.popularity,
            "poster_path" ~~> self.poster_path,
            "original_language" ~~> self.original_language,
            "original_title" ~~> self.original_title,
            "genre_ids" ~~> self.genre_ids,
            "backdrop_path" ~~> self.backdrop_path,
            "adult" ~~> self.adult,
            "overview" ~~> self.overview,
            "release_date" ~~> self.release_date
            ])
    }
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        self.vote_count = "vote_count" <~~ json
        self.id = "id" <~~ json
        self.video = "video" <~~ json
        self.vote_average = "vote_average" <~~ json
        self.title = "title" <~~ json
        self.popularity = "popularity" <~~ json
        self.poster_path = "poster_path" <~~ json
        self.original_language = "original_language" <~~ json
        self.original_title = "original_title" <~~ json
        self.genre_ids = "genre_ids" <~~ json
        self.backdrop_path = "backdrop_path" <~~ json
        self.adult = "adult" <~~ json
        self.overview = "overview" <~~ json
        self.release_date = "release_date" <~~ json
    }
}

// Add network operations

extension Movie {
    
    static func fetch(data: [String : Any], completion:@escaping ([Movie]?, Pager?, Error?) -> Void) {
        Network.shared.request(endpoint: .getMovies(data)) { response in
            switch response.result {
            case .success(let data):
               if let JSON = data as? [String: AnyObject] {
                
                let total_results = JSON.valueForKeyPath(keyPath: "total_results")! as! NSNumber
                let total_pages = JSON.valueForKeyPath(keyPath: "total_pages")! as! NSNumber
                let page = JSON.valueForKeyPath(keyPath: "page")! as! NSNumber
                let pager = Pager(total_results: Int(truncating: total_results), page: Int(truncating: page), total_pages: Int(truncating: total_pages))
                
                let testMovie = JSON.valueForKeyPath(keyPath: "results")
                    if let JSONArray: Array = testMovie as? Array<[String: AnyObject]> {
                        let medium = [Movie].from(jsonArray: JSONArray)
                        if medium != nil {
                            completion(medium, pager, response.result.error)
                        } else {
                            completion(nil, nil, composeError(domain: Constants.domainData, code: 0, message: Constants.errorJSONParsingDescription))
                        }
                    }
               }
               else {
                completion(nil, nil, composeError(domain: Constants.domainData, code: 1, message: Constants.errorJSONParsingDescription))
               }
            
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }

    static func getMovie(data: [String: Any], completion:@escaping (Movie?, Error?) -> Void) {
        Network.shared.request(endpoint: .getSimilarMovies(data)) { response in
            switch response.result {
            case .success(let data):
                if let JSON = data as? [String: AnyObject] {
                    let movie = Movie(json: JSON)
                    if movie != nil {
                        completion(movie, nil)
                    }else {
                        completion(nil, composeError(domain: Constants.domainData, code: 0, message: Constants.errorJSONParsingDescription))
                    }
                }  else {
                    completion(nil, composeError(domain: Constants.domainData, code: 0, message: Constants.errorJSONParsingDescription))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    static func getSimilarMovies(data: [String : Any], completion:@escaping ([Movie]?, Pager?, Error?) -> Void) {
        Network.shared.request(endpoint: .getSimilarMovies(data)) { response in
            switch response.result {
            case .success(let data):
                if let JSON = data as? [String: AnyObject] {
                    
                    let total_results = JSON.valueForKeyPath(keyPath: "total_results")! as! NSNumber
                    let total_pages = JSON.valueForKeyPath(keyPath: "total_pages")! as! NSNumber
                    let page = JSON.valueForKeyPath(keyPath: "page")! as! NSNumber
                    let pager = Pager(total_results: Int(truncating: total_results), page: Int(truncating: page), total_pages: Int(truncating: total_pages))
                    
                    let testMovie = JSON.valueForKeyPath(keyPath: "results")
                    if let JSONArray: Array = testMovie as? Array<[String: AnyObject]> {
                        let medium = [Movie].from(jsonArray: JSONArray)
                        if medium != nil {
                            completion(medium, pager, response.result.error)
                        } else {
                            completion(nil, nil, composeError(domain: Constants.domainData, code: 0, message: Constants.errorJSONParsingDescription))
                        }
                    }
                }
                else {
                    completion(nil, nil, composeError(domain: Constants.domainData, code: 1, message: Constants.errorJSONParsingDescription))
                }
                
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
}
